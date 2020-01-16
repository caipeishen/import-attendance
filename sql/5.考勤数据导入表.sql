USE [scm_main]
GO

/****** Object:  Table [dbo].[bd_analysis_import_attendance]    Script Date: 2019/9/27 9:42:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
--drop table [bd_analysis_import_attendance]
CREATE TABLE [dbo].[bd_analysis_import_attendance](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[user_no] [varchar](255) NULL,
	[user_name] [varchar](255) NULL,
	[user_serial] [bigint] NULL,
	[begin_date] [datetime] NULL,
	[end_date] [datetime] NULL,
	[create_date] [datetime] NULL,
	[is_over_time] [varchar](50) NULL,
	[is_exec] [varchar](50) NULL,
 CONSTRAINT [PK_bd_analysis_import_attendance] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[bd_analysis_import_attendance] ADD  CONSTRAINT [DF_bd_analysis_import_attendance_over_time]  DEFAULT ('·ñ') FOR [create_date]
GO


ALTER TABLE [dbo].[bd_analysis_import_attendance] ADD  CONSTRAINT [DF_bd_analysis_import_attendance_is_exec]  DEFAULT ('Î´Ö´ÐÐ') FOR [is_exec]
GO

