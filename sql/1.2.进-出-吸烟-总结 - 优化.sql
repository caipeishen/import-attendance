IF EXISTS (SELECT
      1
    FROM sysobjects
    WHERE id = OBJECT_ID('dbo.proc_bd_analysis_doorRecord')
    AND type IN ('P', 'PC'))
  DROP PROCEDURE dbo.proc_bd_analysis_doorRecord
GO

CREATE PROCEDURE proc_bd_analysis_doorRecord (@Date  VARCHAR(10)='')
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @begin VARCHAR(10)=@Date,@end VARCHAR(10)

  IF(ISNULL(@Date,'')='')
  BEGIN
  	SET @begin=CONVERT(VARCHAR(10),GETDATE(),120)
  END

  SET @end=CONVERT(VARCHAR(10),DATEADD(DAY,1,@begin),120)


  CREATE TABLE #doorResult (
    user_serial BIGINT NULL
   ,user_card NVARCHAR(50) NULL
   ,user_name NVARCHAR(50) NULL
   ,dept_name NVARCHAR(50) NULL
   ,work_type NVARCHAR(50) NOT NULL
   ,begin_date DATETIME NULL
   ,begin_door_serial NVARCHAR(16) COLLATE Chinese_PRC_CI_AS NULL
   ,begin_door_name NVARCHAR(50) COLLATE Chinese_PRC_CI_AS NULL
   ,end_date DATETIME NULL
   ,end_door_serial NVARCHAR(16) COLLATE Chinese_PRC_CI_AS NULL
   ,end_door_name NVARCHAR(50) COLLATE Chinese_PRC_CI_AS NULL
   ,duration NUMERIC(18, 8) NULL
   ,date DATE NULL
   ,time TIME NULL
  )

  --创建数据初始化表
  CREATE TABLE #Data (
    id INT IDENTITY
   ,door_serial NVARCHAR(16) COLLATE Chinese_PRC_CI_AS NULL
   ,door_name NVARCHAR(50) COLLATE Chinese_PRC_CI_AS NULL
   ,fx INT
   ,user_serial INT
   ,sj DATETIME
   ,flag VARCHAR(50)
   ,rowno INT
  )

  CREATE TABLE #DataSmoking (
    id INT IDENTITY
   ,door_serial NVARCHAR(16) COLLATE Chinese_PRC_CI_AS NULL
   ,door_name NVARCHAR(50) COLLATE Chinese_PRC_CI_AS NULL
   ,fx INT
   ,user_serial INT
   ,sj DATETIME
   ,flag VARCHAR(50)
   ,rowno INT
  )
  
  --进
  CREATE TABLE #ResultIn (
    id INT
   ,user_serial INT
   ,begin_date DATETIME
   ,begin_door_serial NVARCHAR(16) COLLATE Chinese_PRC_CI_AS NULL
   ,begin_door_name NVARCHAR(50) COLLATE Chinese_PRC_CI_AS NULL
   ,end_date DATETIME
   ,end_door_serial NVARCHAR(16) COLLATE Chinese_PRC_CI_AS NULL
   ,end_door_name NVARCHAR(50) COLLATE Chinese_PRC_CI_AS NULL
  )

  --出
  CREATE TABLE #ResultOut (
    id INT
   ,user_serial INT
   ,begin_date DATETIME
   ,begin_door_serial NVARCHAR(16) COLLATE Chinese_PRC_CI_AS NULL
   ,begin_door_name NVARCHAR(50) COLLATE Chinese_PRC_CI_AS NULL
   ,end_date DATETIME
   ,end_door_serial NVARCHAR(16) COLLATE Chinese_PRC_CI_AS NULL
   ,end_door_name NVARCHAR(50) COLLATE Chinese_PRC_CI_AS NULL
  )

  
  -- 取定时的时间点（已经执行完成的最后一条）
  select top 1 * from bd_analysis_door_timing where beginDate is not null and @begin = CONVERT(varchar(100),beginDate,23) order by beginDate desc 



  INSERT INTO #Data (door_serial,door_name,fx, user_serial, sj)
  SELECT
    Gate_bh
   ,door.door_name
   ,fx
   ,user_serial
   ,mj.sj
  FROM mj_jl_real mj
  LEFT JOIN bd_analysis_door door on mj.Gate_bh = door.bh
  WHERE 1 = 1
  AND jl_type = 45
  AND user_serial IS NOT NULL
  AND sj >= @begin
  AND sj < @end
-- AND user_serial = 20001210
--  AND user_serial IN(20029670)
  ORDER BY user_serial, sj ASC



  -- 添加头和尾，该存储过程分析数据需要用到
  INSERT INTO #Data (door_serial,door_name,fx, user_serial, sj, flag, rowno)
  SELECT DISTINCT 'Starting','--------------',0,user_serial,@begin+' 00:00:00.000',NULL, null FROM #Data

--  IF(@Date=CONVERT(VARCHAR(10),'2019-08-07',120))
  IF(@Date=CONVERT(VARCHAR(10),GETDATE(),120))
  BEGIN
    INSERT INTO #Data (door_serial,door_name,fx, user_serial, sj, flag, rowno)
    SELECT DISTINCT 'Finishing','--------------',1,user_serial,GETDATE(),NULL, null FROM #Data	
--    SELECT DISTINCT 'Finishing','--------------',1,user_serial,'2019-08-07 15:00:00',NULL, null FROM #Data
  END ELSE
  BEGIN
    INSERT INTO #Data (door_serial,door_name,fx, user_serial, sj, flag, rowno)
    SELECT DISTINCT 'Finishing','--------------',1,user_serial,@begin+' 23:59:59.000',NULL, null FROM #Data  	
  END


  --相同方向连续刷卡的记录设置相同标识  
  DECLARE @userSerial INT,@fx INT,@total INT,@i INT=0,@lastUser INT=-1,@lastFx INT=-1,@guid VARCHAR(50)='',@sj DATETIME
  
  SELECT @total = COUNT(1) FROM #Data 

  WHILE @i<@total 
  BEGIN  
  	
    SELECT TOP 1 @userSerial=user_serial,@fx=fx,@sj=sj FROM #Data WHERE flag IS NULL ORDER BY user_serial,sj ASC

    IF(@userSerial=@lastUser AND @fx= @lastFx)
    BEGIN
      UPDATE #Data SET flag=@guid WHERE user_serial=@userSerial AND fx=@fx AND sj=@sj
    END ELSE
    BEGIN
      SELECT @guid=NEWID()
    	SELECT @lastUser=@userSerial,@lastFx=@fx 
      UPDATE #Data SET flag=@guid WHERE user_serial=@userSerial AND fx=@fx AND sj=@sj  	
    END

    SET @i+=1
  END

  --更新相同标识的数据序列号
  UPDATE d
  SET rowno = x.rowno
  FROM #Data d
  INNER JOIN (SELECT
      id
     ,fx
     ,user_serial
     ,sj
     ,flag
     ,ROW_NUMBER() OVER (PARTITION BY flag ORDER BY user_serial, sj) rowno
  
    FROM #Data) x
    ON x.id = d.id

  -----------------------------------------------进开始----------------------------------------------------
  --结束时间
  INSERT INTO #ResultIn (user_serial, end_date, end_door_serial,end_door_name, id)
    SELECT
      t.user_serial
     ,t.sj
     ,t.door_serial
	 ,t.door_name
     ,ROW_NUMBER() OVER (PARTITION BY t.user_serial ORDER BY user_serial, sj) rowno
    FROM #Data t
    WHERE fx = 1
    AND rowno = 1
    ORDER BY t.user_serial, t.sj

    --开始时间 很巧妙
	/* 
		如果正常数据有进，但是我们手动添加过进和出，顺序为	 进（00:00:00.000）进 出 进 出 进 出 进 出 (23:59:59.000) 
		如果正常数据没有进，但是我们手动添加过进和出，顺序为 进（00:00:00.000）   出 进 出 进 出 进 出 (23:59:59.000) 
		但不管怎么样，我们取数据是取的最后一条进（最后一条表示连续刷卡的最后一条）
	*/
    UPDATE r
    SET begin_date = x.sj, begin_door_serial = x.door_serial,begin_door_name = x.door_name
    FROM #ResultIn r
    INNER JOIN (SELECT
	   a.door_serial
	   ,a.door_name
       ,a.id
       ,a.fx
       ,a.user_serial
       ,a.sj
       ,a.flag
       ,ROW_NUMBER() OVER (PARTITION BY a.user_serial ORDER BY a.user_serial, a.sj) rowno
      FROM (SELECT
          flag
         ,MAX(t.rowno) maxRowNo
        FROM #Data t
        WHERE fx = 0
        GROUP BY t.flag) x
      INNER JOIN (SELECT
          *
        FROM #Data
        WHERE fx = 0) a
        ON a.flag = x.flag
        AND x.maxRowNo = a.rowno
    --  WHERE a.user_serial=20000295
    ) x
      ON x.rowno = r.id
      AND x.user_serial = r.user_serial
  
  
  insert into #doorResult
  select 
	r.user_serial as user_serial,u.user_card as user_card,u.user_lname as user_name,u.user_depname as dept_name,
	'In' as work_type,
	r.begin_date,r.begin_door_serial,r.begin_door_name as begin_door_name,
	r.end_date,r.end_door_serial,r.end_door_name as end_door_name,
	null,null,null
  from #ResultIn r 
  left join dt_user u on u.user_serial = r.user_serial
  order by r.user_serial,r.begin_date

  -----------------------------------------------进结束----------------------------------------------------

  
  -----------------------------------------------出开始----------------------------------------------------

  --出开始时间
  INSERT INTO #ResultOut (user_serial, begin_date, begin_door_serial,begin_door_name, id)
    SELECT
      t.user_serial
     ,t.sj
     ,t.door_serial
     ,t.door_name
     ,ROW_NUMBER() OVER (PARTITION BY t.user_serial ORDER BY user_serial, sj) rowno
    FROM #Data t
    WHERE fx = 1
    AND rowno = 1
    ORDER BY t.user_serial, t.sj

    --出结束时间 很巧妙
	/* 
		注意：这里有一个 '-1'这个是排除我们手动添加的进（00:00:00）
		如果正常数据有进，但是我们手动添加过进和出，顺序为	 进（00:00:00.000）进 出 进 出 进 出 进 出 (23:59:59.000) 
		如果正常数据没有进，但是我们手动添加过进和出，顺序为 进（00:00:00.000）   出 进 出 进 出 进 出 (23:59:59.000) 
		但不管怎么样，我们取数据是取的最后一条进（最后一条表示连续刷卡的最后一条）
	*/
    UPDATE r
    SET end_date = x.sj, end_door_serial = x.door_serial, end_door_name = x.door_name
    FROM #ResultOut r
    INNER JOIN (SELECT
	   a.door_serial
	   ,a.door_name
       ,a.id
       ,a.fx
       ,a.user_serial
       ,a.sj
       ,a.flag
       ,ROW_NUMBER() OVER (PARTITION BY a.user_serial ORDER BY a.user_serial, a.sj) - 1 rowno
      FROM (SELECT
          flag
         ,MAX(t.rowno) maxRowNo
        FROM #Data t
        WHERE fx = 0
        GROUP BY t.flag) x
      INNER JOIN (SELECT
          *
        FROM #Data
        WHERE fx = 0) a
        ON a.flag = x.flag
        AND x.maxRowNo = a.rowno
    --  WHERE a.user_serial=20000295
    ) x
      ON x.rowno = r.id
      AND x.user_serial = r.user_serial


  insert into #doorResult
  select r.user_serial as user_serial,u.user_card as user_card,u.user_lname as user_name,u.user_depname as dept_name,
	'Out' as work_type,
	r.begin_date,r.begin_door_serial,r.begin_door_name as begin_door_name,
	r.end_date,r.end_door_serial,r.end_door_name as end_door_name,
	null,null,null
  from #ResultOut r
  left join dt_user u on u.user_serial = r.user_serial
  order by r.user_serial,r.begin_date


  -----------------------------------------------出结束----------------------------------------------------
  


  -----------------------------------------------烟开始----------------------------------------------------

  -- 组装吸烟门出吸烟门装反，这里的出代表进
  UPDATE #doorResult
  SET work_type = 'Smoking'
  WHERE begin_door_name = '组装吸烟门出'
  --WHERE begin_door_name like '%吸烟%' and begin_door_name like '%出%'

  UPDATE #doorResult
  SET work_type = 'Smoking'
  WHERE begin_door_name = '三厂北侧吸烟亭进'
  --WHERE begin_door_name like '%吸烟%' and begin_door_name like '%出%'
  
  -----------------------------------------------烟结束----------------------------------------------------


  
  --------------------------------------------杂乱处理开始----------------------------------------------------
  DELETE FROM #doorResult
  WHERE begin_door_serial = 'Finishing'

  -- 处理结束
--  IF(@Date=CONVERT(VARCHAR(10),'2019-08-07',120))
  IF(@Date=CONVERT(VARCHAR(10),GETDATE(),120))
  BEGIN
    -- 处理当天当前结束时间数据
--    DECLARE @endDate DATETIME = '2019-08-07 15:00:00'
    DECLARE @endDate DATETIME = GETDATE()
	  UPDATE #doorResult SET end_date=@endDate,end_door_serial='Finishing',end_door_name='--------------' WHERE end_date IS NULL

    INSERT INTO #doorResult (user_serial, user_card, user_name, dept_name, work_type, begin_date, begin_door_serial, 
        begin_door_name, end_date, end_door_name)
      SELECT DISTINCT
        user_serial
       ,user_card
       ,user_name
       ,dept_name
       ,'Null'
       ,@endDate
       ,''
       ,'--------------'
       ,@Date + ' 23:59:59'
        --       ,'2019-08-07 23:59:59'
       ,'--------------'
      FROM #doorResult  
  END ELSE
  BEGIN
  	UPDATE #doorResult SET end_date=@Date + ' 23:59:59',end_door_serial='Finishing',end_door_name='--------------' WHERE end_date IS NULL
  END

  -- 处理最后出的状态
--  UPDATE #doorResult set work_type = 'NULL' WHERE work_type = 'Out' AND end_door_serial = 'Finishing'

  -- 处理开始
  INSERT INTO #doorResult (user_serial, user_card, user_name, dept_name, work_type,begin_date,begin_door_serial,begin_door_name,end_date, end_door_serial, end_door_name)
  SELECT
    x.user_serial
    ,x.user_card
    ,x.user_name
    ,x.dept_name
    ,CASE WHEN x.work_type = 'In' THEN 'Out' ELSE 'In' END
    ,@Date + ' 00:00:00'
    ,'Starting'
    ,'--------------'
    ,x.begin_date
    ,x.begin_door_serial
    ,x.begin_door_name
  FROM (SELECT
      *
     ,ROW_NUMBER() OVER (PARTITION BY user_serial ORDER BY user_serial, begin_date) rowNo
    FROM #doorResult
    ) x
  WHERE x.rowNo = 1
    AND x.begin_door_serial != 'Starting'


  UPDATE #doorResult
  SET duration = CONVERT(DECIMAL(18, 8), DATEDIFF(SECOND, begin_date, end_date)) / 60 / 60 / 24
     ,date = CONVERT(VARCHAR(100), begin_date, 23)
     ,time = CONVERT(VARCHAR(100), begin_date, 24)

  -------------------------------------------杂乱处理结束----------------------------------------------------
  

  -- 首先清空 上次疾苦
  DELETE FROM  bd_analysis_doorRecord where date = @Date;

  INSERT INTO bd_analysis_doorRecord (user_serial, user_card, user_name, dept_name, work_type, begin_date, begin_door_serial, 
    begin_door_name, end_date, end_door_serial, end_door_name, duration, date, time,user_exception_count)
  SELECT
    user_serial
   ,user_card
   ,user_name
   ,dept_name
   ,work_type
   ,begin_date
   ,begin_door_serial
   ,begin_door_name
   ,end_date
   ,end_door_serial
   ,end_door_name
   ,duration
   ,date
   ,time
   ,isnull((
	   select count(0) 
	   from bd_mj_abnormal_data a 
	   where a.user_serial = r.user_serial and CONVERT(varchar(100),a.sj, 23) = r.date
	   group by a.user_serial
	),0)
  FROM #doorResult r
    ORDER BY user_serial, begin_date

---------------------------------------------异常数据1开始----------------------------------------------------

select * into #doorAnalysis1
from bd_analysis_doorRecord
where work_type = 'In' and begin_door_serial = 'Starting'

--select user_serial,date FROM #doorAnalysis1 group by user_serial,date having count(0)>1


-- 定义变量

declare @sum_exception1 bigint = 0;
declare @count_exception1 bigint = (select count(0) from #doorAnalysis1)

declare @id_exception1 bigint
declare @user_serial_exception1 varchar(100)
declare @begin_date_exception1 date

declare @work_type_before_exception1 varchar(100)

WHILE(@sum_exception1 < @count_exception1) BEGIN
	
	-- 得出当天第一条的信息
	select 
		@id_exception1 = id,
		@user_serial_exception1 = user_serial,
		@begin_date_exception1 = begin_date
	from #doorAnalysis1 
	order by user_serial offset @sum_exception1 rows fetch next 1 rows only
	
	-- 前一天的最后一条信息
	--select * from bd_analysis_doorRecord where begin_date < @begin_date_exception1 and user_serial = @user_serial_exception1 order by begin_date desc
	
	select 
		top 1 @work_type_before_exception1 = work_type 
	from bd_analysis_doorRecord 
	where begin_date < @begin_date_exception1 and user_serial = @user_serial_exception1 order by begin_date desc

	-- 最后一条Out	出 → 进 进 → 出 第二天还是进的情况
	-- 最后一条In	进 → 出 进 → 出 表示没有出的数据
	-- 最后一条数据 不管你是进还是出，你都要是Null
	IF isnull(@work_type_before_exception1,'') = 'Out' BEGIN
		update bd_analysis_doorRecord set work_type = 'Out' where id = @id_exception1
	END

	set @sum_exception1 = @sum_exception1 +1;
END

-------------------------------------------异常数据1结束----------------------------------------------------
-------------------------------------------异常数据2开始----------------------------------------------------

select * into #doorAnalysis2
from bd_analysis_doorRecord
where work_type = 'Out' and begin_door_serial = 'Starting'

--select user_serial,date FROM #doorAnalysis2 group by user_serial,date having count(0)>1


-- 定义变量

declare @sum_exception2 bigint = 0;
declare @count_exception2 bigint = (select count(0) from #doorAnalysis2)

declare @id_exception2 bigint
declare @user_serial_exception2 varchar(100)
declare @begin_date_exception2 date

declare @id_exception_before2 bigint
declare @work_type_before_exception2 varchar(100)

WHILE(@sum_exception2 < @count_exception2) BEGIN
	
	-- 得出当天第一条的信息
	select 
		@id_exception2 = id,
		@user_serial_exception2 = user_serial,
		@begin_date_exception2 = begin_date
	from #doorAnalysis2 
	order by user_serial offset @sum_exception2 rows fetch next 1 rows only
	
	-- 前一天的最后一条信息
	--select * from bd_analysis_doorRecord where begin_date < @begin_date_exception2 and user_serial = @user_serial_exception2 order by begin_date desc
	
	select 
		top 1 @id_exception_before2 = id,@work_type_before_exception2 = work_type 
	from bd_analysis_doorRecord 
	where begin_date < @begin_date_exception2 and user_serial = @user_serial_exception2 order by begin_date desc

	-- 最后一条Out	出 → 进 进 → 出 第二天还是进的情况
	-- 最后一条In	进 → 出 进 → 出 表示没有出的数据
	-- 最后一条数据 不管你是进还是出，你都要是Null
	IF isnull(@work_type_before_exception2,'') = 'In' BEGIN
		update bd_analysis_doorRecord set work_type = 'Out' where id = @id_exception_before2
	END

	set @sum_exception2 = @sum_exception2 +1;
END

-------------------------------------------异常数据2结束----------------------------------------------------


  DROP TABLE #Data
  DROP TABLE #ResultIn
  DROP TABLE #ResultOut
  DROP TABLE #doorResult
  DROP TABLE #doorAnalysis1
  DROP TABLE #doorAnalysis2
  

  SET NOCOUNT OFF;
END
GO
