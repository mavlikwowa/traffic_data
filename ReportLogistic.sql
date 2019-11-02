SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Маликов В.А. 
-- Create date: 2016-12-04
-- Description:	Процедура для отчёта "Логистический отчёт"
-- exec a.Logistic
-- =============================================
CREATE PROCEDURE a.Logistic 
AS
BEGIN
	declare @from_date date = DATEADD(month, DATEDIFF(month, 0, getdate()), 0) 
	declare @trim_date date = DATEADD(month, DATEDIFF(month, 0, dateadd(month, 1, getdate())), 0)
	
	declare @t1 table
	(
		r_number int,
		DepartureDateTime datetime,
		ArrivalDateTime datetime,
		DepartureAirportId int,
		DestinationAirportId int,
		AirCompanyId int	
	)
	insert into @t1
	select 
		DENSE_RANK() OVER (partition by f.DepartureAirportId order by  f.DepartureDateTime asc) as r_number,
		f.DepartureDateTime,
		f.ArrivalDateTime,
		f.DepartureAirportId,
		f.DestinationAirportId,
		f.AirCompanyId
	from a.Flights f
	join 
	(
		select
			MAX(f.DepartureDateTime) as DepartureDateTime,
			f.DepartureAirportId
		from a.Flights f
		where 
			f.DepartureDateTime>= @from_date 
			and f.ArrivalDateTime < @trim_date 
			and f.AirCompanyId = 0 -- AdventureBirds
		group by
			f.DepartureAirportId
	) ff on ff.DepartureAirportId = f.DepartureAirportId
	where 
		f.DepartureDateTime>= @from_date 
		and f.ArrivalDateTime < @trim_date 
		and f.AirCompanyId != 0 -- AdventureBirds
		and ff.DepartureDateTime > f.DepartureDateTime

/*
	Странно. В задании указано взять все вылеты перед рейсами, а в примере выбирается только последний, хотя можно взять еще несколько....
	Подвох? :)
*/

	select
		CONVERT(VARCHAR (10), t1.DepartureDateTime , 104) + ' ' + CONVERT( VARCHAR(8 ),t1.DepartureDateTime,108) [DepartureDateTime],
		CONVERT(VARCHAR (10), t1.ArrivalDateTime , 104) + ' ' + CONVERT( VARCHAR(8 ),t1.ArrivalDateTime,108) [ArrivalDateTime],
		g.Continent + ' ,' + g.Country + ' ,' + g.Region + ' ,' + g.City + ' ,' + g.Name [DepartureAirport],
		g.Continent + ' ,' + g2.Country + ' ,' + g2.Region + ' ,' + g2.City + ' ,' + g.Name [DestinationAirport], 
		c.Name [AirCompany]
	from @t1 t1
		join 
		(
			select 
				max(r_number) as r_number, 
				DepartureAirportId 
			from @t1
			group by 
				DepartureAirportId
		) t on t.r_number = t1.r_number and t.DepartureAirportId = t1.DepartureAirportId
		join a.Geography g on g.AirportId = t1.DepartureAirportId
		join a.Geography g2 on g2.AirportId = t1.DestinationAirportId
		join a.Companies c on c.AirCompanyId = t1.AirCompanyId
END
GO



