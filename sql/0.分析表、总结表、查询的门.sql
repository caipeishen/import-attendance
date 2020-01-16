
--drop table [bd_analysis_door]
-- 需要查询的门
select door_name,bh into bd_analysis_door from st_door_real 
where door_name not in ('二楼会议中心','北门进','北门出','工厂晨会会议室','测试','A库仓库门禁','MUC Office-A','MUC Office-C','五号厂房冲压地坑西','五号厂房冲压地坑东','三厂化学室','三厂实验室','三厂测量室','MUCS DS Office','Blue Projector Room Outer','Blue Projector Room Inner','Logistics MOVE Office','Golden Projector Room','模具资料室')


--drop table [bd_analysis_doorRecord]
-- 创建数据分析表
CREATE TABLE [dbo].[bd_analysis_doorRecord](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[user_serial] [bigint] NULL,
	[user_card] [nvarchar](50) NULL,
	[user_name] [nvarchar](50) NULL,
	[dept_name] [nvarchar](50) NULL,
	[work_type] [nvarchar](50) NOT NULL,
	[begin_date] [datetime] NULL,
	[begin_door_serial] [nvarchar](16) COLLATE Chinese_PRC_CI_AS NULL,
	[begin_door_name] [nvarchar](50) NULL,
	[end_date] [datetime] NULL,
	[end_door_serial] [nvarchar](16)  COLLATE Chinese_PRC_CI_AS NULL,
	[end_door_name] [nvarchar](50) NULL,
	[duration] [numeric](18, 8) NULL,
	[date] [date] NULL,
	[time] [time](7) NULL,
	[user_exception_count] [int] NULL
) ON [PRIMARY]

--drop table [bd_analysis_doorRecord_summary]
-- 创建数据分析总结表
CREATE TABLE [dbo].[bd_analysis_doorRecord_summary](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[user_serial] [bigint] NULL,
	[user_card] [nvarchar](50) NULL,
	[user_name] [nvarchar](50) NULL,
	[dept_name] [nvarchar](50) NULL,
	[date] [date] NULL,
	[in_sum_time] [numeric](8, 2) NULL,
	[smoking_sum_time] [numeric](8, 2) NULL,
	[out_sum_time] [numeric](8, 2) NULL,
	[out_sum_count] [int] NULL
) ON [PRIMARY]