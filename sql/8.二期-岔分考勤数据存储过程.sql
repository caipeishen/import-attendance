USE scm_main;
-- 需要先创建拆分字符串存储过程（split_str）
if exists (select 1
          from sysobjects
          where  id = object_id('proc_bd_analysis_doorRecord_attendance')
          and type in ('P','PC'))
DROP PROCEDURE proc_bd_analysis_doorRecord_attendance
GO
CREATE PROCEDURE proc_bd_analysis_doorRecord_attendance
as
BEGIN

-- 关闭打印受影响行数
SET NOCOUNT ON;


	/*
		手动 - 正常 + 加班 - 调休
		思路：岔分那些需要拆分的数据（就是前后时间包在了分界时间点）
	*/

  -- 首先更新用户姓名
  update i set i.user_name = u.user_lname,i.user_serial = u.user_serial
  from bd_analysis_import_attendance i
  inner join dt_user u on  i.user_no = u.user_no
  where i.is_exec = '未执行' and (isnull(i.user_name,'') = '' or isnull(i.user_serial,'') = '')

	-- （系统默认 - 手动排班）
	-- 取交集（正常排班替换成手动排班,这里我们将正常排班的修改为已执行就可以）
	--update a set a.is_exec = '已执行'
	--from bd_analysis_import_attendance a 
	--inner join (select user_serial,CONVERT(varchar(100),begin_date,111) as date from bd_analysis_import_attendance where work_status = '正常'	Intersect select user_serial,CONVERT(varchar(100),begin_date,111) as date from bd_analysis_import_attendance where work_status = '手动' or work_status ='手调') b on a.user_serial = b.user_serial and CONVERT(varchar(100),a.begin_date,111) = b.date
	--where a.work_status = '正常'
	
	-- （系统默认 - 手动排班）
	-- 删除交集（这里直接删除了，这样不容易混淆）
	delete from a
	from bd_analysis_import_attendance a 
	inner join (select user_serial,CONVERT(varchar(100),real_date,111) as real_date from bd_analysis_import_attendance where work_status = '正常'	Intersect select user_serial,CONVERT(varchar(100),real_date,111) as real_date from bd_analysis_import_attendance where work_status = '手动') b on a.user_serial = b.user_serial and CONVERT(varchar(100),a.real_date,111) = b.real_date
	where a.work_status = '正常'

	-- （(系统默认 - 手动排班) - 手调排班）
	-- 删除交集（这里直接删除了，这样不容易混淆）
	delete from a
	from bd_analysis_import_attendance a 
	inner join (select user_serial,CONVERT(varchar(100),real_date,111) as real_date from bd_analysis_import_attendance where work_status = '正常' or work_status = '手动'	Intersect select user_serial,CONVERT(varchar(100),real_date,111) as real_date from bd_analysis_import_attendance where work_status ='手调') b on a.user_serial = b.user_serial and CONVERT(varchar(100),a.real_date,111) = b.real_date
	where a.work_status = '正常' or a.work_status = '手动'



	declare @sum bigint;
	declare @index bigint = 0;
	select @sum = count(0) from bd_analysis_import_attendance where is_exec = '未执行'

	declare @id bigint;
	declare @user_no varchar(255);
	declare @user_serial bigint;
	declare @begin_date datetime;
	declare @end_date datetime;
	declare @work_status varchar(50);

	--------------------------------------------------

	declare @date date = CONVERT(varchar(100),@begin_date,110);

	declare @id_start bigint;
	declare @begin_date_start datetime;
	declare @end_date_start datetime;

	declare @id_finish bigint;
	declare @begin_date_finish datetime;
	declare @end_date_finish datetime;





	WHILE @index < @sum BEGIN

				-- 这里是每次取第一个（因为每次都会执行一个，所以一直取第一个就可以）
				select @id = isnull(id,0),@user_no = isnull(user_no,''),@user_serial = isnull(user_serial,0),@begin_date = isnull(begin_date,null),@end_date = isnull(end_date,null),@work_status = isnull(work_status,'')
				from bd_analysis_import_attendance
				where is_exec = '未执行'
				order by work_status desc offset 0 rows fetch next 1 rows only


				-- 注意：循环如果没有找到该数据，会保留上次的数据，所以我们要清除变量
				set @id_start = 0;
				set @begin_date_start = null;
				set @end_date_start = null;


				-- 查询找出需要修改的数据
				select @id_start = isnull(id,0),@begin_date_start = isnull(begin_date,null),@end_date_start = isnull(end_date,null)
				from bd_analysis_doorRecord
				where 1=1
				and work_type like 'In%'
				and user_serial = @user_serial
				--and CONVERT(varchar(25),begin_date,120) < CONVERT(varchar(25),@begin_date,120) and CONVERT(varchar(10),begin_date,120) = CONVERT(varchar(10),@begin_date,120)  and CONVERT(varchar(25),end_date,120) > CONVERT(varchar(25),@begin_date,120)
				and begin_date < @begin_date and end_date > @begin_date -- and CONVERT(varchar(100),begin_date,23) = CONVERT(varchar(100),@begin_date,23)
				order by begin_Date desc offset 0 rows fetch next 1 rows only


				-- 复制数据
				insert into bd_analysis_doorRecord(user_serial,user_card,user_name,dept_name,work_type,begin_date,begin_door_serial,begin_door_name,end_date,end_door_serial,end_door_name,duration,date,time,user_exception_count)
				select user_serial,user_card,user_name,dept_name,work_type,@begin_date,'--------------','开始统计考勤',@end_date_start,end_door_serial,end_door_name,CONVERT(DECIMAL(18, 8), DATEDIFF(SECOND, @begin_date, @end_date_start)) / 60 / 60 / 24,CONVERT(VARCHAR(100), begin_date, 23),CONVERT(VARCHAR(100), @begin_date, 24),user_exception_count from bd_analysis_doorRecord
				where 1=1
				and id = @id_start
				--order by begin_Date desc offset 0 rows fetch next 1 rows only

				-- 更新上一条数据
				update bd_analysis_doorRecord set end_door_serial = '--------------',end_door_name = '开始统计考勤',end_date = @begin_date,duration = CONVERT(DECIMAL(18, 8), DATEDIFF(SECOND, begin_date, @begin_date)) / 60 / 60 / 24,time = CONVERT(VARCHAR(100), begin_date, 24) where id = @id_start


				-------------------------


				-- 注意：循环如果没有找到该数据，会保留上次的数据，所以我们要清除变量
				set @id_finish = 0;
				set @begin_date_finish = null;
				set @end_date_finish = null;

				-- 查询找出需要修改的数据
				select @id_finish = isnull(id,0),@begin_date_finish = isnull(begin_date,null),@end_date_finish = isnull(end_date,null) from bd_analysis_doorRecord
				where 1=1
				and work_type like 'In%'
				and user_serial = @user_serial
				--and CONVERT(varchar(25),begin_date,120)  < CONVERT(varchar(25),@end_date,120)  and CONVERT(varchar(25),begin_date,120) > CONVERT(varchar(25),@begin_date,120)  and CONVERT(varchar(25),end_date,120)  >  CONVERT(varchar(25),@end_date,120)
				and begin_date < @end_date and begin_date > @begin_date and end_date > @end_date
				order by begin_Date desc offset 0 rows fetch next 1 rows only


				-- 复制数据
				insert into bd_analysis_doorRecord(user_serial,user_card,user_name,dept_name,work_type,begin_date,begin_door_serial,begin_door_name,end_date,end_door_serial,end_door_name,duration,date,time,user_exception_count)
				select user_serial,user_card,user_name,dept_name,work_type,@end_date,'--------------','结束统计考勤',end_date,end_door_serial,end_door_name,CONVERT(DECIMAL(18, 8), DATEDIFF(SECOND,@end_date, @end_date_finish)) / 60 / 60 / 24,CONVERT(VARCHAR(100), begin_date, 23),CONVERT(VARCHAR(100), @end_date, 24),user_exception_count from bd_analysis_doorRecord
				where 1=1
				and id = @id_finish
				--order by begin_Date desc offset 0 rows fetch next 1 rows only

				-- 更新上一条数据
				update bd_analysis_doorRecord set end_door_serial='--------------',end_door_name='结束统计考勤',end_date = @end_date,duration = CONVERT(DECIMAL(18, 8), DATEDIFF(SECOND, begin_date, @end_date)) / 60 / 60 / 24,time = CONVERT(VARCHAR(100), begin_date, 24) where id = @id_finish


				----------------------------------------------------------------------------

				declare @work_type varchar(50);
				IF @work_status = '正常' BEGIN
					set @work_type = 'In-P'
				END
				ELSE IF @work_status = '手动' BEGIN
					set @work_type = 'In-P'
				END
				ELSE IF @work_status = '手调' BEGIN
					set @work_type = 'In-P'
				END
				ELSE IF @work_status = '加班' BEGIN
					set @work_type = 'In-P-O'
				END
				ELSE IF @work_status = '调休' BEGIN
					set @work_type = 'In-P-L'
				END
				ELSE BEGIN
					set @work_type = 'In-未知'
				END


				-- 处理时间段中的进
				update bd_analysis_doorRecord set work_type = @work_type
				where work_type like 'In%' and user_serial = @user_serial and begin_date >= @begin_date and end_date <= @end_date

				
				-- 更新当天应工作总时长（正常、手动、手调、加班）
				update a set a.attendance_duration_sum = b.attendance_duration_sum
				from bd_analysis_doorRecord a
				inner join (
								select user_serial,CONVERT(varchar(100),begin_date,23) as date,sum( Convert(decimal(18,1),duration)) as attendance_duration_sum
								from bd_analysis_import_attendance
								where work_status = '正常' or work_status = '手动' or work_status = '手调' or work_status = '加班'
								group by user_serial,CONVERT(varchar(100),begin_date,23)
							) as b
				on a.user_serial = b.user_serial and a.date = b.date
				where a.user_serial = @user_serial 

				-- 更新当天应工作总时长，上面是所有的工作但没有减去调休（   (正常、手动、手调、加班) - 调休    ）
				update a set a.attendance_duration_sum = a.attendance_duration_sum - b.attendance_duration_sum
				from bd_analysis_doorRecord a
				inner join (
								select user_serial,CONVERT(varchar(100),begin_date,23) as date,sum( Convert(decimal(18,1),duration)) as attendance_duration_sum
								from bd_analysis_import_attendance
								where work_status = '调休'
								group by user_serial,CONVERT(varchar(100),begin_date,23)
							) as b
				on a.user_serial = b.user_serial and a.date = b.date
				where a.user_serial = @user_serial 

				
				-- 更新当天应工作总时长，如果小于等于0 那么该数值应该为空
				update a set a.attendance_duration_sum = NULL
				from bd_analysis_doorRecord a
				inner join (
								select user_serial,CONVERT(varchar(100),begin_date,23) as date,sum( Convert(decimal(18,1),duration)) as attendance_duration_sum
								from bd_analysis_import_attendance
								where work_status = '调休'
								group by user_serial,CONVERT(varchar(100),begin_date,23)
							) as b
				on a.user_serial = b.user_serial and a.date = b.date
				where a.user_serial = @user_serial and a.attendance_duration_sum <= 0

				
				--============================================


				--------------------------------------


				-- 更新当天应上班（正常、手动、手调）总时长
				update a set a.attendance_duration_normal_sum = b.attendance_duration_normal_sum
				from bd_analysis_doorRecord a
				inner join (
								select user_serial,CONVERT(varchar(100),begin_date,23) as date,sum( Convert(decimal(18,1),duration)) as attendance_duration_normal_sum
								from bd_analysis_import_attendance
								where work_status = '正常' or work_status = '手动' or work_status = '手调'
								group by user_serial,CONVERT(varchar(100),begin_date,23)
							) as b
				on a.user_serial = b.user_serial and a.date = b.date
				where a.user_serial = @user_serial and end_door_serial = 'Finishing' 


				-- 更新当天应工作总时长（正常、手动、手调），上面是所有的工作但没有减去调休（   (正常、手动、手调、加班) - 调休    ）
				update a set a.attendance_duration_normal_sum = a.attendance_duration_normal_sum - b.attendance_duration_normal_sum
				from bd_analysis_doorRecord a
				inner join (
								select user_serial,CONVERT(varchar(100),begin_date,23) as date,sum( Convert(decimal(18,1),duration)) as attendance_duration_normal_sum
								from bd_analysis_import_attendance
								where work_status = '调休'
								group by user_serial,CONVERT(varchar(100),begin_date,23)
							) as b
				on a.user_serial = b.user_serial and a.date = b.date
				where a.user_serial = @user_serial and end_door_serial = 'Finishing' 
				
				
				-- 更新当天应工作总时长（正常、手动、手调），如果小于等于0 那么该数值应该为空
				update a set a.attendance_duration_normal_sum = NULL
				from bd_analysis_doorRecord a
				inner join (
								select user_serial,CONVERT(varchar(100),begin_date,23) as date,sum( Convert(decimal(18,1),duration)) as attendance_duration_normal_sum
								from bd_analysis_import_attendance
								where work_status = '调休'
								group by user_serial,CONVERT(varchar(100),begin_date,23)
							) as b
				on a.user_serial = b.user_serial and a.date = b.date
				where a.user_serial = @user_serial and end_door_serial = 'Finishing' and a.attendance_duration_normal_sum < = 0
				

				--------------------------------------


				-- 更新当天应加班总时长
				update a set a.attendance_duration_over_time_sum = b.attendance_duration_over_time_sum
				from bd_analysis_doorRecord a
				inner join (
								select user_serial,CONVERT(varchar(100),begin_date,23) as date,sum( Convert(decimal(18,1),duration)) as attendance_duration_over_time_sum
								from bd_analysis_import_attendance
								where work_status = '加班'
								group by user_serial,CONVERT(varchar(100),begin_date,23)
							) as b
				on a.user_serial = b.user_serial and a.date = b.date
				where a.user_serial = @user_serial and end_door_serial = 'Finishing' 

				
				--============================================


				-- 更新当天实际上班（正常、手动、手调）总时长
				update a set a.real_duration_normal_sum = b.real_duration_normal_sum
				from bd_analysis_doorRecord a
				inner join (
								select user_serial,CONVERT(varchar(100),begin_date,23) as date,sum(duration) as real_duration_normal_sum
								from bd_analysis_doorRecord
								where work_type = 'In-P'
								group by user_serial,CONVERT(varchar(100),begin_date,23)	
							) as b
				on a.user_serial = b.user_serial and a.date = b.date
				where a.user_serial = @user_serial and a.end_door_serial = 'Finishing'


				-- 更新当天实际加班总时长
				update a set a.real_duration_over_time_sum = b.real_duration_over_time_sum
				from bd_analysis_doorRecord a
				inner join (
								select user_serial,CONVERT(varchar(100),begin_date,23) as date,sum(duration) as real_duration_over_time_sum
								from bd_analysis_doorRecord
								where work_type = 'In-P-O'
								group by user_serial,CONVERT(varchar(100),begin_date,23)	
							) as b
				on a.user_serial = b.user_serial and a.date = b.date
				where a.user_serial = @user_serial and a.end_door_serial = 'Finishing'


		----------------------------------------------

		-- 更新人员执行状态
		update bd_analysis_import_attendance set is_exec = '已执行' where id = @id;

		SET @index = @index + 1;

	END



-- 打开打印受影响行数
SET NOCOUNT OFF;
END;
