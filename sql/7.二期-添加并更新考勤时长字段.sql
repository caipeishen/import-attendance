
-- 导入数据考勤表(bd_analysis_import_attendance)

-- 将is_over_time修改未status
exec sp_rename 'bd_analysis_import_attendance.is_over_time','work_status'

-- 添加默认属性
alter table bd_analysis_import_attendance add default('正常') for work_status with values

-- 添加考勤表的考勤时长
alter table bd_analysis_import_attendance add duration numeric(18,8) default 0

-- 初始化考勤时长数据
update bd_analysis_import_attendance set duration = 0 where duration is null

-- 更新所有考勤时长数据
update bd_analysis_import_attendance set duration = datediff(minute,begin_date,end_date)/60.000000 where duration = 0


-- 查询每天的考勤总时长
select user_serial,CONVERT(varchar(100),begin_date,23) as date,sum(duration) as attendance_duration_sum
from bd_analysis_import_attendance
group by user_serial,CONVERT(varchar(100),begin_date,23)


-- 门禁数据分析表(bd_analysis_doorRecord)
-- 添加当天考勤时长
alter table bd_analysis_doorRecord add attendance_duration_sum numeric(18,8)

-- 初始化考勤时长数据
--update bd_analysis_doorRecord set attendance_duration_sum = 0 where attendance_duration_sum is null
--update bd_analysis_doorRecord set attendance_duration_sum = null where attendance_duration_sum = 0

-- 更新所有考勤时长数据
update a set a.attendance_duration_sum = b.attendance_duration_sum
from bd_analysis_doorRecord a
inner join (
        select user_serial,CONVERT(varchar(100),begin_date,23) as date,sum( Convert(decimal(18,1),duration)) as attendance_duration_sum
        from bd_analysis_import_attendance
        group by user_serial,CONVERT(varchar(100),begin_date,23)
      ) as b
on a.user_serial = b.user_serial and a.date = b.date



