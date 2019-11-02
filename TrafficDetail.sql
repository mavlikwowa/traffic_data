SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Маликов В.А.
-- Create date: 2016-12-04
-- Description:	Процедура для отчёта "Детализация трафика"
-- exec a.Traffic @from_date = '2016-01-01', @trim_date = '2016-02-01', @name = 'Все'
-- =============================================
CREATE PROCEDURE a.Traffic
	@from_date date, 
	@trim_date date,
	@name varchar (255)
AS
BEGIN
	/*
		По идее, правильнее ограничить допустимые даты в ReportBuilder`e, дабы не пугать пользователя эксепшеном.
	*/
	if DATEDIFF(month, @from_date, @trim_date) > 1
	begin
		raiserror ('Период не может превышать один месяц!', 16, 1)
		return
	end
	
	select @name = case @name when  'Все' then null else @name end
	create table #t1
	(
		DepartureDateTime varchar (128),
		ArrivalDateTime varchar (128),
		DepartureAirport varchar (max),
		DestinationAirport varchar (max),
		AirCompany varchar (255),
		Plane varchar (255),
		Passengers int,
		Workload float,
		AirCompanyId int
	)
	insert into #t1
	(
		DepartureDateTime,
		ArrivalDateTime,
		DepartureAirport,
		DestinationAirport,
		AirCompany,
		Plane,
		Passengers,
		Workload,
		AirCompanyId
	)
	select
		CONVERT(VARCHAR (10), f.DepartureDateTime , 104) + ' ' + CONVERT( VARCHAR(8 ),f.DepartureDateTime,108),
		CONVERT(VARCHAR (10), f.ArrivalDateTime , 104) + ' ' + CONVERT( VARCHAR(8 ),f.ArrivalDateTime,108),
		g.Continent + ' ,' + g.Country + ' ,' + g.Region + ' ,' + g.City + ' ,' + g.Name,
		g.Continent + ' ,' + g2.Country + ' ,' + g2.Region + ' ,' + g2.City + ' ,' + g.Name, 
		c.Name,
		p.Name,
		f.Passengers,
		CAST(ROUND(CONVERT(NUMERIC,f.Passengers)/CONVERT(NUMERIC,p.Seats) * 100, 2, 0) as float),
		c.AirCompanyId
	from a.Flights f
		join a.Geography g on g.AirportId = f.DepartureAirportId
		join a.Geography g2 on g2.AirportId = f.DestinationAirportId
		join a.Companies c on c.AirCompanyId = f.AirCompanyId
		join a.Planes p on p.PlaneId = f.PlaneId
	where 
		f.DepartureDateTime >= @from_date 
		and f.ArrivalDateTime < @trim_date 
		and (@name = c.Name or @name is null)
		
	select
		DepartureDateTime [DepartureDateTime],
		ArrivalDateTime [ArrivalDateTime],
		DepartureAirport [DepartureAirport],
		DestinationAirport [DestinationAirport],
		AirCompany [AirCompany],
		Plane [Plane],
		Passengers [Passengers],
		Workload [Workload]
	from #t1
	
	if @name is null
	begin
		select 
			c.name [AirCompanys] -- список смапить в отедльную таблицу в репортсе.
		from a.Companies c
		where exists
		(
			select 1 from #t1 t1
			where t1.AirCompanyId = c.AirCompanyId
		)
		order by c.name
	end
	
	drop table #t1
END
GO

