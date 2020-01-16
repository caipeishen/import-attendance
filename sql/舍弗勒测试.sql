

/*
吸烟大于一小时
2050644	20000997	80583452178404	耿广进	Internal Logistics Team 2	Smoking	2019-09-01 01:19:53.247	2018011617485004	组装吸烟门出	2019-09-01 03:12:00.837	2018010913495150	9号门进	0.07785880	2019-09-01	01:19:53.0000000	2	NULL
2054853	20026387	27A22715	李建	生产外包	Smoking	2019-09-01 01:32:13.657	2018011617485004	组装吸烟门出	2019-09-01 02:50:18.627	2018010913495150	9号门进	0.05422454	2019-09-01	01:32:13.0000000	8	NULL
2050965	20001094	80583452053F04	王月	DMF Team 5	Smoking	2019-09-01 02:12:46.007	2018011617485004	组装吸烟门出	2019-09-01 03:41:52.037	2018011617421907	H门1#进	0.06187500	2019-09-01	02:12:46.0000000	2	NULL
2054277	20025433	8054F60A282104	李壮壮	Stamping Team 1	Smoking	2019-09-01 03:20:29.217	2018011617485004	组装吸烟门出	2019-09-01 06:21:53.817	2018011617463744	H门2#进	0.12597222	2019-09-01	03:20:29.0000000	3	NULL
2056020	20036974	80583482641D04	马道林	太仓供应商	Smoking	2019-09-01 03:25:23.203	2018011617485004	组装吸烟门出	2019-09-01 21:45:27.640	2018011617465984	H门3#进	0.76393519	2019-09-01	03:25:23.0000000	4	NULL
2054859	20026387	27A22715	李建	生产外包	Smoking	2019-09-01 03:35:57.433	2018011617485004	组装吸烟门出	2019-09-01 05:16:45.527	2018010913495150	9号门进	0.07000000	2019-09-01	03:35:57.0000000	8	NULL
2053890	20002946	805750521B4304	向才军	Machining team 3	Smoking	2019-09-01 03:40:37.860	2018011617485004	组装吸烟门出	2019-09-01 05:19:34.443	2018011617465984	H门3#进	0.06871528	2019-09-01	03:40:37.0000000	3	NULL
2055881	20035865	261C8CC5	金先华	生产外包	Smoking	2019-09-01 03:41:01.343	2018011617485004	组装吸烟门出	2019-09-01 05:34:36.520	2019021915341263	A库闸机出	0.07887731	2019-09-01	03:41:01.0000000	4	NULL
2053871	20002782	8054F612482804	程圆圆	Stamping team 1	Smoking	2019-09-01 04:02:56.307	2018011617485004	组装吸烟门出	2019-09-01 05:17:35.560	2018011617463744	H门2#进	0.05184028	2019-09-01	04:02:56.0000000	10	NULL

selct * from bd_analysis_doorRecord
2050643	20000997	80583452178404	耿广进	Internal Logistics Team 2	Out	2019-09-01 00:00:00.000	Starting	--------------	2019-09-01 01:19:53.247	2018011617485004	组装吸烟门出	0.05547454	2019-09-01	00:00:00.0000000	2	NULL
2050644	20000997	80583452178404	耿广进	Internal Logistics Team 2	Smoking	2019-09-01 01:19:53.247	2018011617485004	组装吸烟门出	2019-09-01 03:12:00.837	2018010913495150	9号门进	0.07785880	2019-09-01	01:19:53.0000000	2	NULL
2050645	20000997	80583452178404	耿广进	Internal Logistics Team 2	In	2019-09-01 03:12:00.837	2018010913495150	9号门进	2019-09-01 03:15:16.430	2018020217262148	G门2#出	0.00226852	2019-09-01	03:12:00.0000000	2	NULL
2050646	20000997	80583452178404	耿广进	Internal Logistics Team 2	Out	2019-09-01 03:15:16.430	2018020217262148	G门2#出	2019-09-01 03:37:23.597	2018011617463744	H门2#进	0.01535880	2019-09-01	03:15:16.0000000	2	NULL
2050647	20000997	80583452178404	耿广进	Internal Logistics Team 2	In	2019-09-01 03:37:23.597	2018011617463744	H门2#进	2019-09-01 03:40:55.080	2018010913500305	9号门出	0.00245370	2019-09-01	03:37:23.0000000	2	NULL

select * from mj_jl
2019-09-01 01:19:50.000	5726581	2018011617485004	1	0010003	20000997	80583452178404	517813	2	NULL	45	2019-09-01 01:19:53.247	0	NULL	NULL	0	耿广进	Internal Logistics Team 2
2019-09-01 01:27:04.000	5726609	2018011617483865	0	0010003	20000997	80583452178404	517827	1	NULL	45	2019-09-01 01:27:05.997	0	NULL	NULL	0	耿广进	Internal Logistics Team 2
2019-09-01 03:11:59.000	5727031	2018010913495150	0	0010012	20000997	80583452178404	481961	1	NULL	45	2019-09-01 03:12:00.837	0	NULL	NULL	0	耿广进	Internal Logistics Team 2
2019-09-01 03:15:15.000	5727037	2018020217262148	1	0010015	20000997	80583452178404	538824	2	NULL	45	2019-09-01 03:15:16.430	0	NULL	NULL	0	耿广进	Internal Logistics Team 2
2019-09-01 03:37:22.000	5727189	2018011617463744	0	0010006	20000997	80583452178404	442562	1	NULL	45	2019-09-01 03:37:23.597	0	NULL	NULL	0	耿广进	Internal Logistics Team 2
*/


select * 
from bd_analysis_doorRecord
where work_type = 'Smoking' and (duration * 24) > 1 
order by begin_date,user_serial


select * 
from bd_analysis_doorRecord
where user_serial = '20000997' and convert(varchar(7),begin_date,120) = '2019-09'
order by begin_date,user_serial


select * 
from mj_jl_real
where user_serial = '20000997'and convert(varchar(7),sj,120) = '2019-09'



-- 添加考勤表的考勤时长
alter table bd_analysis_import_attendance add real_date date

-- 更新老数据状态
update bd_analysis_import_attendance set work_status = '正常' where work_status is null or work_status = '否'


-- 添加月考勤汇总字段
alter table bd_analysis_doorRecord add attendance_duration_normal_sum numeric(18, 8)
alter table bd_analysis_doorRecord add attendance_duration_over_time_sum numeric(18, 8)

alter table bd_analysis_doorRecord add real_duration_normal_sum numeric(18, 8)
alter table bd_analysis_doorRecord add real_duration_over_time_sum numeric(18, 8)


select * from bd_analysis_doorRecord where user_name = '钱晓东' and date='2019-10-12' order by user_Serial,begin_date


truncate table bd_analysis_import_attendance

exec proc_bd_analysis_doorRecord_attendance


select * from bd_analysis_import_attendance where user_serial = '20002450' and work_status = '调休' order by begin_date desc


select * from bd_analysis_doorRecord where  user_serial = '20001940' order by begin_Date asc




--先插入开始时间
insert into bd_analysis_door_timing (beginDate) values (GETDATE());

declare @id int = @@IDENTITY;

declare @date date = getdate();

EXEC proc_bd_analysis_doorRecord @date
EXEC proc_bd_analysis_doorRecord_summary @date

-- 再更新结束时间
update bd_analysis_door_timing set endDate = GETDATE() where id = @id;


/*
	
	1.创建一张记录定时表

	2.记录当前执行的时间，取上一次记录时间往后开始更新数据



	根据传过来的日期 去定时表中查询数据 是否有当天的定时记录 有则使用上次最后的定时记录 没有则使用全新（使用指的是查询刷卡数据）


*/




-- 更新所有数据的正常、手动、手调排班总时间
update a set a.duration_normal = b.duration_normal
from bd_analysis_doorRecord a
inner join (
	select user_serial,left(real_date,7) as year_month,sum(duration) as duration_normal
	from bd_analysis_import_attendance
	where work_status  = '正常' or work_status  = '手动' or work_status  = '手调'
	group by user_serial,left(real_date,7)
) as b on a.user_serial = b.user_serial and left(a.real_date,7) = b.year_month 
where a.duration_normal is null



-- 更新所有数据的加班排班总时间
update a set a.duration_over_time = b.duration_over_time
from bd_analysis_doorRecord a
inner join (
	select user_serial,left(real_date,7) as year_month,sum(duration) as duration_over_time
	from bd_analysis_import_attendance
	where work_status  = '加班'
	group by user_serial,left(real_date,7)
) as b on a.user_serial = b.user_serial and left(a.real_date,7) = b.year_month 
where a.duration_over_time is null


-- 更新所有数据的调休排班总时间
update a set a.duration_leave = b.duration_leave
from bd_analysis_doorRecord a
inner join (
	select user_serial,left(real_date,7) as year_month,sum(duration) as duration_leave
	from bd_analysis_import_attendance
	where work_status  = '调休'
	group by user_serial,left(real_date,7)
) as b on a.user_serial = b.user_serial and left(a.real_date,7) = b.year_month 
where a.duration_leave is null




SELECT * FROM bd_analysis_import_attendance WHERE create_date >= '2019-11-29' AND create_date < dateadd(day, 1, '2019-11-29') 




select * from bd_analysis_import_attendance where work_status = '调休'





select * from dt_user where user_no = '28025276'


-- 处理时间段中的进
update bd_analysis_doorRecord set work_type = @work_type
where work_type = 'In' and user_serial = @user_serial and begin_date >= @begin_date and end_date <= @end_date

 

select * from bd_analysis_import_attendance order by work_status desc

select * from bd_analysis_import_attendance where user_serial = '20000565' order by user_serial,begin_date


select * from view_bd_analysis_doorRecord_year where user_serial = '20000565' order by user_serial,begin_date


				update a set a.attendance_duration_sum = b.attendance_duration_sum
				from bd_analysis_doorRecord a
				inner join (
								select user_serial,CONVERT(varchar(100),begin_date,23) as date,sum( Convert(decimal(18,1),duration)) as attendance_duration_sum
								from bd_analysis_import_attendance
								where work_status = '正常' or work_status = '手动' or work_status = '手调' or work_status = '加班'
								group by user_serial,CONVERT(varchar(100),begin_date,23)
							) as b
				on a.user_serial = b.user_serial and a.date = b.date

				-- 更新当天应工作总时长，上面是所有的工作但没有减去调休（   (正常、手动、手调、加班) - 调休    ）
				select * --update a set a.attendance_duration_sum = a.attendance_duration_sum - b.attendance_duration_sum
				from bd_analysis_doorRecord a
				inner join (
								select user_serial,CONVERT(varchar(100),begin_date,23) as date,sum( Convert(decimal(18,1),duration)) as attendance_duration_sum
								from bd_analysis_import_attendance
								where work_status = '调休'
								group by user_serial,CONVERT(varchar(100),begin_date,23)
							) as b
				on a.user_serial = b.user_serial and a.date = b.date

				
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
				where a.attendance_duration_sum <= 0

				
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
				where end_door_serial = 'Finishing' 
				
				
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
				where end_door_serial = 'Finishing' and a.attendance_duration_normal_sum < = 0



/*

4186249	20000565	805834824D4304	鲍永良	DMF Team 3	Out	2019-10-22 06:20:33.387	2018020217251688	G门1#出	2019-10-22 23:59:59.000	Finishing	--------------	0.73571759	2019-10-22	06:20:33.0000000	0	14.00000000	16.00000000	NULL	0.18942130	NULL	20000565	2019-10-22	2.0
4449939	20001029	8054F60A398E04	毕改花	Machining Hub/TC Team1	In-P-L	2019-10-28 08:00:00.000	--------------	开始统计考勤	2019-10-28 23:59:59.000	Finishing	--------------	0.66665509	2019-10-28	08:00:00.0000000	0	NULL	8.00000000	8.00000000	NULL	0.22843750	20001029	2019-10-28	24.0
4450007	20000565	805834824D4304	鲍永良	DMF Team 3	In-P-L	2019-10-24 20:00:00.000	--------------	开始统计考勤	2019-10-24 20:33:52.030	2018011617485004	组装吸烟门出	0.02351852	2019-10-24	20:00:00.0000000	2	NULL	NULL	NULL	NULL	NULL	20000565	2019-10-24	24.0
4284475	20001283	80583452363004	边晓龙	Stamping Team 3	Out	2019-10-25 00:06:56.840	2018011617471375	H门3#出	2019-10-25 23:59:59.000	Finishing	--------------	0.99517361	2019-10-25	00:06:56.0000000	0	NULL	8.00000000	NULL	NULL	NULL	20001283	2019-10-25	24.0

28010029	卜晓明	20000685	2019-10-18 00:00:00.000	2019-10-18 23:59:59.000	2019-11-28 15:35:28.520	调休	已执行	24.00000000	2019-10-18
28010029	4071820	20000685	805744C26A2E04	卜晓明	Machining DQ K1/K2 Team 2	Out	2019-10-18 00:01:38.290	2018020217262148	G门2#出	2019-10-18 23:59:59.000	Finishing	--------------	0.99885417	2019-10-18	00:01:38.0000000	0	8.00000000	8.00000000	NULL	NULL	NULL

28018492	4189821	20001204	805FB7925A1E04	鲍俊勇	DMF Team 3	In	2019-10-22 23:44:40.747	2018020217245043	G门1#进	2019-10-22 23:59:59.000	Finishing	--------------	0.01063657	2019-10-22	23:44:40.0000000	0	8.00000000	8.00000000	NULL	0.20680556	NULL
28018492	鲍俊勇	20001204	2019-10-22 06:00:00.000	2019-10-22 08:00:00.000	2019-11-28 15:35:28.520	调休	已执行	2.00000000	2019-10-22



28010029	卜晓明	20000685	2019-10-24 00:00:00.000	2019-10-24 23:59:59.000	2019-11-28 15:35:28.520	调休	已执行	24.00000000	2019-10-24
28024610	毕志力	20001940	2019-10-18 00:00:00.000	2019-10-18 23:59:59.000	2019-11-28 15:35:28.520	调休	已执行	24.00000000	2019-10-18
*/



28013251	翟四梅	20000868
28025576	钱晓东	20002134
28025245	艾芳红	20002062
28010029	卜晓明	20000685
28027478	安龙凤	20002450
28030469	安烟明	20034324
28020113	白占宝	20001365



select * from bd_analysis_doorRecord where duration is null


select * from bd_analysis_doorRecord where user_serial = '20000367' order by user_serial,begin_date  asc




-- 异常 20000392（开始） 20000403(开始) 20000395（结束）

-- 查询岔分数据
select *   
from bd_analysis_doorRecord
where date = '2019-08-01' 
and user_serial = '20000399'
order by begin_Date asc



select CONVERT(VARCHAR(100), begin_date, 24) from bd_analysis_doorRecord


select * from bd_analysis_import_attendance



truncate table bd_analysis_import_attendance


select * from bd_analysis_import_attendance

update bd_analysis_import_attendance set is_exec = '未执行'

-- 岔分数据
exec proc_bd_analysis_doorRecord_attendance 


select * from bd_analysis_doorRecord

-- 00:22:21	未修改第一次
-- 01:01:00 已修改第一次
-- 00:54:38 未修改第二次
-- 00:31:55 未修改第三次

DECLARE @i int=1,@Date varchar(10)='2019-08-01',@EndDate varchar(10)='2019-09-01'
WHILE(@Date<@EndDate)
BEGIN
	PRINT @Date

	EXEC proc_bd_analysis_doorRecord @Date
	EXEC proc_bd_analysis_doorRecord_summary @Date

	SET @Date=CONVERT(varchar(10),DATEADD(DAY,1,@Date),120) 
END
	


/*

declare @sum int = 0;
declare @count int = 12;

declare @date varchar(10) = CONVERT(varchar(100), '2019-08-01', 23);

WHILE (@sum < @count) BEGIN
	print @date;
	exec proc_bd_analysis_doorRecord @date
	exec proc_bd_analysis_doorRecord_summary @date
	set @date = CONVERT(varchar(100), dateadd(day,1,@date), 23);
	set @sum = @sum + 1;
END

*/

-- truncate table [dbo].[bd_analysis_doorRecord]
-- truncate table [dbo].[bd_analysis_doorRecord_summary]

-- 12
-- 20000874
select * from bd_mj_abnormal_data where user_Serial = '20000299' and  CONVERT(varchar(100),sj, 23) = '2019-07-06'

--8276
-- 更新数据分析表
declare @date varchar(10) = CONVERT(varchar(100), '2019-07-06', 23);
exec proc_bd_analysis_doorRecord @date
exec proc_bd_analysis_doorRecord_summary @date

select * from dt_user where user_lname = '李其翔'
select * from mj_jl_real where CONVERT(varchar(100),sj, 23) = '2019-01-11' and user_Serial = '20001922';

/*
	5744	20001450	805AF13A5C3804	倪敬顺	Mechanical	In	NULL	NULL	NULL	2019-08-01 23:54:24.543
	70465	20001922	80577352166B04	方满	Stamping Team 1	In	NULL	NULL	NULL	2019-08-07 23:59:59.000
*/
-- 查询 所有 门禁记录分析
select * from bd_analysis_doorRecord order by begin_Date

-- 查询 当天 门禁记录分析
select * from view_bd_analysis_doorRecord_day

-- 查询 当月 门禁记录分析
select * from view_bd_analysis_doorRecord_month order by user_serial,begin_date

-- 查询 当年 门禁记录分析
select * from view_bd_analysis_doorRecord_year order by user_serial,begin_date


-- 查询 所有 门禁记录总结 
select * from bd_analysis_doorRecord_summary

-- 查询 当天 门禁记录总结
select * from view_bd_analysis_doorRecord_summary_day

-- 查询 当月 门禁记录总结
select * from view_bd_analysis_doorRecord_summary_month order by date

-- 查询 当年 门禁记录总结
select * from view_bd_analysis_doorRecord_summary_year order by date

