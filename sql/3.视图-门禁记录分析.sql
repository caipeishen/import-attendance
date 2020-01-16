
----- 当天的数据分析 ------
if exists (select * from sysobjects where name = 'view_bd_analysis_doorRecord_day')
 drop view view_bd_analysis_doorRecord_day
 go
create view view_bd_analysis_doorRecord_day
as
   select u.user_no,a.* 
   from bd_analysis_doorRecord a
   inner join dt_user u on u.user_serial =  a.user_serial
   where datediff(day, a.date,getdate()) = 0
go


----- 当月的数据分析 ------
if exists (select * from sysobjects where name = 'view_bd_analysis_doorRecord_month')
 drop view view_bd_analysis_doorRecord_month
 go
create view view_bd_analysis_doorRecord_month
as
   select u.user_no,a.* 
   from bd_analysis_doorRecord a
   inner join dt_user u on u.user_serial =  a.user_serial
   where datediff(month, a.date,getdate()) = 0
go


----- 当年的数据分析 ------
if exists (select * from sysobjects where name = 'view_bd_analysis_doorRecord_year')
 drop view view_bd_analysis_doorRecord_year
 go
create view view_bd_analysis_doorRecord_year 
as
   select u.user_no,a.* 
   from bd_analysis_doorRecord a
   inner join dt_user u on u.user_serial =  a.user_serial
   where datediff(year, a.date,getdate()) = 0
go
