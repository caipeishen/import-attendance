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

		思路：岔分那些需要拆分的数据（就是前后时间包在了分界时间点）

	*/

	declare @sum bigint;
	declare @index bigint = 0;
	select @sum = count(0) from bd_analysis_import_attendance where is_exec = '未执行'

	declare @id bigint;
	declare @user_no varchar(255);
	declare @user_serial bigint;
	declare @begin_date datetime;
	declare @end_date datetime;

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
				select @id = id,@user_no = user_no,@user_serial = user_serial,@begin_date = begin_date,@end_date = end_date
				from bd_analysis_import_attendance
				where is_exec = '未执行'
				order by id offset 0 rows fetch next 1 rows only


				-- 注意：循环如果没有找到该数据，会保留上次的数据，所以我们要清除变量
				set @id_start = 0;
				set @begin_date_start = null;
				set @end_date_start = null;

				print '----------------------'
				print CONVERT(varchar(25),@begin_date,120);
				print CONVERT(varchar(25),@end_date,120);
				print '----------------------'

				-- 查询找出需要修改的数据
				select @id_start = id,@begin_date_start = begin_date,@end_date_start = end_date from bd_analysis_doorRecord
				where 1=1
				and work_type = 'In'
				and user_serial = @user_serial
				and CONVERT(varchar(25),begin_date,120) < CONVERT(varchar(25),@begin_date,120) and CONVERT(varchar(10),begin_date,120) = CONVERT(varchar(10),@begin_date,120)  and CONVERT(varchar(25),end_date,120) > CONVERT(varchar(25),@begin_date,120)
				order by begin_Date desc offset 0 rows fetch next 1 rows only


				--IF @id_start <> 0 BEGIN

					-- 复制数据
					insert into bd_analysis_doorRecord(user_serial,user_card,user_name,dept_name,work_type,begin_date,begin_door_serial,begin_door_name,end_date,end_door_serial,end_door_name,duration,date,time,user_exception_count)
					select user_serial,user_card,user_name,dept_name,work_type,@begin_date,'--------------','开始统计考勤',@end_date_start,end_door_serial,end_door_name,CONVERT(DECIMAL(18, 8), DATEDIFF(SECOND, @begin_date, @end_date_start)) / 60 / 60 / 24,CONVERT(VARCHAR(100), begin_date, 23),CONVERT(VARCHAR(100), @begin_date, 24),user_exception_count from bd_analysis_doorRecord
					where 1=1
					and id = @id_start
					--and work_type = 'In'
					--and user_serial = @user_serial
					--and begin_date < @begin_date and begin_date > @date and end_date > @begin_date
					order by begin_Date desc offset 0 rows fetch next 1 rows only

					-- 更新上一条数据
					update bd_analysis_doorRecord set end_door_serial = '--------------',end_door_name = '开始统计考勤',end_date = @begin_date,duration = CONVERT(DECIMAL(18, 8), DATEDIFF(SECOND, begin_date, @begin_date)) / 60 / 60 / 24,time = CONVERT(VARCHAR(100), begin_date, 24) where id = @id_start

				--END

				-------------------------



				-- 注意：循环如果没有找到该数据，会保留上次的数据，所以我们要清除变量
				set @id_finish = 0;
				set @begin_date_finish = null;
				set @end_date_finish = null;

				-- 查询找出需要修改的数据
				select @id_finish = id,@begin_date_finish = begin_date,@end_date_finish = end_date from bd_analysis_doorRecord
				where 1=1
				and work_type = 'In'
				and user_serial = @user_serial
				and CONVERT(varchar(25),begin_date,120)  < CONVERT(varchar(25),@end_date,120)  and CONVERT(varchar(25),begin_date,120) > CONVERT(varchar(25),@begin_date,120)  and CONVERT(varchar(25),end_date,120)  >  CONVERT(varchar(25),@end_date,120)
				order by begin_Date desc offset 0 rows fetch next 1 rows only


				--IF @id_finish <> 0 BEGIN

					-- 复制数据
					insert into bd_analysis_doorRecord(user_serial,user_card,user_name,dept_name,work_type,begin_date,begin_door_serial,begin_door_name,end_date,end_door_serial,end_door_name,duration,date,time,user_exception_count)
					select user_serial,user_card,user_name,dept_name,work_type,@end_date,'--------------','结束统计考勤',end_date,end_door_serial,end_door_name,CONVERT(DECIMAL(18, 8), DATEDIFF(SECOND,@end_date, @end_date_finish)) / 60 / 60 / 24,CONVERT(VARCHAR(100), begin_date, 23),CONVERT(VARCHAR(100), @end_date, 24),user_exception_count from bd_analysis_doorRecord
					where 1=1
					and id = @id_finish
					--and work_type = 'In'
					--and user_serial = @user_serial
					--and begin_date < @end_date and begin_date > @begin_date and end_date > @end_date
					order by begin_Date desc offset 0 rows fetch next 1 rows only

					-- 更新上一条数据
					update bd_analysis_doorRecord set end_door_serial='--------------',end_door_name='结束统计考勤',end_date = @end_date,duration = CONVERT(DECIMAL(18, 8), DATEDIFF(SECOND, begin_date, @end_date)) / 60 / 60 / 24,time = CONVERT(VARCHAR(100), begin_date, 24) where id = @id_finish

				--END

				----------------------------------------------------------------------------

				-- 处理时间段中的进
				update bd_analysis_doorRecord set work_type = 'In-P'
				where work_type = 'In' and user_serial = @user_serial and begin_date >= @begin_date and end_date <= @end_date

		----------------------------------------------

		-- 更新人员执行状态
		update bd_analysis_import_attendance set is_exec = '已执行' where id = @id;

		SET @index = @index + 1;

	END




-- 打开打印受影响行数
SET NOCOUNT OFF;
END;
