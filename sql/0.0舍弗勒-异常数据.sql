
-- 创建记录定时记录表
	CREATE TABLE bd_mj_abnormal_data_exec(
		[id] [int] IDENTITY(1,1) NOT NULL,
		[descName] [varchar](50) NOT NULL,
		[execDate] [datetime] NULL,
		CONSTRAINT [PK_bd_mj_abnormal_data_exec] PRIMARY KEY CLUSTERED 
	(
		[id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]


-- 创建异常数据表
	CREATE TABLE bd_mj_abnormal_data(
		[xh] [int] NOT NULL,
		[user_serial] [bigint] NOT NULL,
		[user_no] [nvarchar](20) NOT NULL,
		[user_name] [nvarchar](50) NULL,
		[dep_name] [nvarchar](50) NULL,
		[door_bh] [char](16) COLLATE Chinese_PRC_CI_AS NULL,
		[door_name] [nvarchar](50) NULL,
		[sj] [datetime] NOT NULL,
		[in_out] [varchar](2) NULL,
		[timing] [bigint] NOT NULL,
	) ON [PRIMARY]

-- 创建保存异常数据存储过程
-- 如果当前记录与下一条记录进出方向相同，则为异常数据
	if exists (select 1
			  from sysobjects
			  where  id = object_id('bd_proc_mj_abnormal_data')
			  and type in ('P','PC'))
	  DROP PROCEDURE bd_proc_mj_abnormal_data
	go
	CREATE PROCEDURE bd_proc_mj_abnormal_data 
		--传参日期
		@datetime datetime 
	as
	

		--查询日期
		declare @date datetime;

		--如果没有传时间的话，设置时间为当天的前一天
		IF ISNULL(@datetime,'') = '' BEGIN
			set @date = dateadd(day,-1,convert(char(10),GETDATE(),120));
		END
		ELSE BEGIN
			set @date = @datetime;
		END


		--保存当前定时任务的ID
		declare @timingId int;
		IF ISNULL(@datetime,'') = '' BEGIN
			insert into bd_mj_abnormal_data_exec(descName,execDate) values ('定时任务',GETDATE());
		END
		ELSE BEGIN
			insert into bd_mj_abnormal_data_exec(descName,execDate) values ('手动执行',@datetime);
		END
		set @timingId = @@IDENTITY;
		

		--创建异常数据临时表
		CREATE TABLE #bd_mj_abnormal_result(
			[xh] [int] NOT NULL,
			[door_bh] [char](16) COLLATE Chinese_PRC_CI_AS  NOT NULL,
			[user_serial] [bigint] NOT NULL,
			[in_out] [int] NOT NULL,
			[sj] [datetime] NOT NULL
		);

		--将当天的数据存起来
		select r.* into #bd_mj_abnormal_real 
		from mj_jl_real r
		inner join st_door_real d on r.Gate_bh = d.bh
		where (d.door_name like '%进%' or d.door_name like '%出%') and r.sj >= convert(char(10),@date,120) and r.sj < dateadd(day,1,convert(char(10),@date,120)) and r.user_serial is not null
		order by r.sj,r.xh asc 

		--当前进出的所有用户
		select user_serial into #bd_mj_turnover_user
		from #bd_mj_abnormal_real
		group by user_serial
		order by user_serial asc


		--当前遍历的用户的行号
		declare @user_sum int;
		--用户总个数
		declare @user_count int;
		--初始化当前遍历行（一定要赋值，不然@user_sum<@user_count不满足条件）
		set @user_sum = 0;


		--查询用户个数，得出遍历的次数
		select @user_count = count(0) from  #bd_mj_turnover_user;
	
		WHILE (@user_sum<@user_count) BEGIN
		
			/*虽然有些变量在循环中，但是SQL中的变量不能重复声明，也就是没有作用，但不会报错，这样写 更容易理解*/

			--当前用户当前的刷卡记录行
			declare @real_sum int;
			--当前用户的刷卡记录总行数
			declare @real_count int;
			--初始化当前遍历行（一定要赋值，不然@@user_sum<@@user_count不满足条件）
			set @real_sum = 0;

			--声明进出记录需要用的数据
			declare @xh_current int;
			declare @door_bh_current char(16);
			declare @user_serial_current bigint;
			declare @in_out_current int;
			declare @in_out_date_current datetime;

			--进或出 相同的次数，一但大于2 说明重复多次，等于2的时候保留上一次的记录
			declare @repeat_count int;
			set @repeat_count = 1;

			--定要赋值为空，不然会保留上次的结果，因为变量不能重复声明，也就是变量声明了，也不会是初始化为空
			set @in_out_current = null;

			--得出当前的用户编号
			select @user_serial_current = user_serial from #bd_mj_turnover_user order by user_serial offset @user_sum rows fetch next 1 rows only ;

			--得出当前用户刷了多少条数据，得出遍历次数
			select @real_count = count(0) from #bd_mj_abnormal_real where user_serial = @user_serial_current;

				WHILE(@real_sum<@real_count) BEGIN

					--声明变量，存储上一条数据
					declare @xh_prev int;
					declare @door_bh_prev char(16);
					declare @user_serial_prev bigint;
					declare @in_out_prev int;
					declare @in_out_date_prev datetime;
			
					--定要赋值为空，不然会保留上次的结果，因为变量不能重复声明，也就是变量声明了，也不会是初始化为空
					set @xh_prev = null;
					set @door_bh_prev = null;
					set @user_serial_prev = null;
					set @in_out_prev = null;
					set @in_out_date_prev = null;
				
				
					--保存为上次的数据
					IF @xh_current is not null set @xh_prev  = @xh_current;
					IF @door_bh_current is not null set @door_bh_prev  = @door_bh_current;
					IF @user_serial_current is not null set @user_serial_prev  = @user_serial_current;
					IF @in_out_current is not null set @in_out_prev  = @in_out_current;
					IF @in_out_date_current is not null set @in_out_date_prev  = @in_out_date_current;


					--得到当前用户遍历的当前刷卡记录数据
					select @xh_current = xh,@door_bh_current = Gate_bh,@user_serial_current = user_serial,@in_out_current = fx ,@in_out_date_current = sj from #bd_mj_abnormal_real where user_serial = @user_serial_current 
					order by sj,xh asc
					offset @real_sum rows
					fetch next 1 rows only;


					--如果当前记录与下一条记录进出方向相同，则为异常

					--如果@in_out_prev为空说明是当前用户的刷卡记录的第一条数据
					IF @in_out_prev is not null BEGIN 
						--当前方向和上条方向相同（1.前面数据 2.最后一条数据）
						IF @in_out_prev = @in_out_current BEGIN
							--2.最后一条数据：保留当前数据
							IF @real_sum = (@real_count -1) BEGIN
								insert into #bd_mj_abnormal_result(xh,door_bh,user_serial,in_out,sj) values (@xh_prev,@door_bh_prev,@user_serial_prev,@in_out_prev,@in_out_date_prev);
								insert into #bd_mj_abnormal_result(xh,door_bh,user_serial,in_out,sj) values (@xh_current,@door_bh_current,@user_serial_current,@in_out_current,@in_out_date_current);
							END
							--1.前面数据：保留上一条数据
							ELSE BEGIN
								insert into #bd_mj_abnormal_result(xh,door_bh,user_serial,in_out,sj) values (@xh_prev,@door_bh_prev,@user_serial_prev,@in_out_prev,@in_out_date_prev);
							END
							set @repeat_count = @repeat_count + 1;
						END
						--当前方向和上条方向不相同（1.前面数据方向相同  2.当前数据不相同）
						ELSE BEGIN
							--1.前面数据方向相同，需要保存当前和上条
							IF @repeat_count > 1 BEGIN
								insert into #bd_mj_abnormal_result(xh,door_bh,user_serial,in_out,sj) values (@xh_prev,@door_bh_prev,@user_serial_prev,@in_out_prev,@in_out_date_prev);
							END
							--2.当前数据不相同，什么也不用干
							ELSE BEGIN
								print '什么也不用干';
							END
							--让相同的条数恢复初始化
							set @repeat_count = 1;
						END
					END
					set @real_sum = @real_sum + 1;

				END
				set @user_sum = @user_sum + 1;

			END
		

		--插入到异常数据表中
		insert into bd_mj_abnormal_data(xh,user_serial,user_no,user_name,dep_name,door_bh,door_name,sj,in_out,timing)
		select r.xh,u.user_serial,u.user_no,u.user_lname as user_name,u.user_depname as dep_name,d.bh as door_bh,d.door_name,r.sj,case r.in_out  when 0 then '进' when 1 then '出' end as in_out,@timingId
		from #bd_mj_abnormal_result r
		inner join dt_user u on r.user_serial = u.user_serial
		inner join st_door_real d on r.door_bh = d.bh
		order by r.user_serial asc,r.sj asc,r.xh asc
		

		--删除异常用户进出表
		drop table #bd_mj_turnover_user

		--删除异常数据临时表
		drop table #bd_mj_abnormal_result
