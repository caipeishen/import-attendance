
------ 当天数据总结 -------
if exists (select * from sysobjects where name = 'view_bd_analysis_doorRecord_summary_day')
 drop view view_bd_analysis_doorRecord_summary_day
 go
create view view_bd_analysis_doorRecord_summary_day
as
   select u.user_no,a.* 
   from bd_analysis_doorRecord_summary a
   inner join dt_user u on u.user_serial =  a.user_serial
   where datediff(day, a.date,getdate()) = 0
go


------ 当月数据总结 -------
if exists (select * from sysobjects where name = 'view_bd_analysis_doorRecord_summary_month')
 drop view view_bd_analysis_doorRecord_summary_month
 go
create view view_bd_analysis_doorRecord_summary_month
as
   select u.user_no,a.* 
   from bd_analysis_doorRecord_summary a
   inner join dt_user u on u.user_serial =  a.user_serial
   where datediff(month, a.date,getdate()) = 0
go


------ 当年数据总结 -------
if exists (select * from sysobjects where name = 'view_bd_analysis_doorRecord_summary_year')
 drop view view_bd_analysis_doorRecord_summary_year
 go
create view view_bd_analysis_doorRecord_summary_year 
as
   select u.user_no,a.* 
   from bd_analysis_doorRecord_summary a
   inner join dt_user u on u.user_serial =  a.user_serial
   where datediff(year, a.date,getdate()) = 0
go
