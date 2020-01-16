IF EXISTS (SELECT
      1
    FROM sysobjects
    WHERE id = OBJECT_ID('dbo.proc_bd_analysis_doorRecord_summary')
    AND type IN ('P', 'PC'))
  DROP PROCEDURE dbo.proc_bd_analysis_doorRecord_summary
GO

CREATE PROCEDURE proc_bd_analysis_doorRecord_summary (@Date  VARCHAR(10)='')
AS
BEGIN
	SET NOCOUNT ON;

	delete from bd_analysis_doorRecord_summary where date = @Date

	-- 去重并插入数据分析表数据
	insert into bd_analysis_doorRecord_summary
	select distinct user_serial,user_card,user_name,dept_name,date,0,0,0,0
	from bd_analysis_doorRecord where date = @Date

	-- 更新工作时长
	update bads set in_sum_time = bad.in_sum_time
	from bd_analysis_doorRecord_summary bads
	inner join (
		select user_serial,Convert(decimal(18,2),SUM(DATEDIFF(second,begin_date,end_date))/60.00) as in_sum_time
		from bd_analysis_doorRecord
		where work_type = 'In'
		group by user_serial
	) bad on bads.user_serial = bad.user_serial

	-- 更新吸烟的时长
	update bads set smoking_sum_time = bad.in_sum_time
	from bd_analysis_doorRecord_summary bads
	inner join (
		select user_serial,Convert(decimal(18,2),SUM(DATEDIFF(second,begin_date,end_date))/60.00) as in_sum_time
		from bd_analysis_doorRecord
		where work_type = 'Smoking'
		group by user_serial
	) bad on bads.user_serial = bad.user_serial

	-- 更新外出的时长
	update bads set out_sum_time = bad.in_sum_time
	from bd_analysis_doorRecord_summary bads
	inner join (
		select user_serial,Convert(decimal(18,2),SUM(DATEDIFF(second,begin_date,end_date))/60.00) as in_sum_time
		from bd_analysis_doorRecord
		where work_type = 'Out'
		group by user_serial
	) bad on bads.user_serial = bad.user_serial

	-- 更新外出的次数
	update bads set out_sum_count = bad.in_sum_count
	from bd_analysis_doorRecord_summary bads
	inner join (
		select user_serial,COUNT(0) as in_sum_count
		from bd_analysis_doorRecord
		where work_type = 'Out'
		group by user_serial
	) bad on bads.user_serial = bad.user_serial


	SET NOCOUNT OFF;
END

