SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Маликов В.А.
-- Create date: 2016-12-04
-- Description:	Процедура для отчёта "Сводный отчет по пассажиропотоку"

-- =============================================
CREATE PROCEDURE a.Passengers
AS
BEGIN
	declare @from_date date = DATEADD(month, -13, DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)) 
	declare @trim_date date = DATEADD(month, -1, DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0))
	
	create table #t1
	(
		m varchar(255),
		AirCompanyId int,
		Passengers int
	)
	insert into #t1
	select
		case
			when DATENAME(month, DepartureDateTime) = 'January' then 'Январь'
			when DATENAME(month, DepartureDateTime) = 'February' then 'Февраль'
			when DATENAME(month, DepartureDateTime) = 'March' then 'Март'
			when DATENAME(month, DepartureDateTime) = 'April' then 'Апрель'
			when DATENAME(month, DepartureDateTime) = 'May' then 'Май'
			when DATENAME(month, DepartureDateTime) = 'June' then 'Июнь'
			when DATENAME(month, DepartureDateTime) = 'July' then 'Июль'
			when DATENAME(month, DepartureDateTime) = 'August' then 'Август'
			when DATENAME(month, DepartureDateTime) = 'September' then 'Сентябрь'
			when DATENAME(month, DepartureDateTime) = 'October' then 'Октябрь'
			when DATENAME(month, DepartureDateTime) = 'November' then 'Ноябрь'
			when DATENAME(month, DepartureDateTime) = 'December' then 'Декабрь'
		end dt,
		AirCompanyId,
		-- тут isnull не помогает. Придётся в репортсе доделать логику. Не добавлять же еще одну таблицу...
		isnull(Passengers, 0) 
	from a.Flights
	where DepartureDateTime >= @from_date and DepartureDateTime < @trim_date



	select
		AirCompanyId,
		[Январь],
		[Февраль],
		[Март],
		[Апрель],
		[Май],
		[Июнь],
		[Июль],
		[Август],
		[Сентябрь],
		[Октябрь],
		[Ноябрь],
		[Декабрь]
	from
	(
	  select 
		AirCompanyId, 
		Passengers,
		m 
	  from #t1
	) d
	pivot
	(
	sum (Passengers) 
	FOR m IN 
	(
		[Январь],
		[Февраль],
		[Март],
		[Апрель],
		[Май],
		[Июнь],
		[Июль],
		[Август],
		[Сентябрь],
		[Октябрь],
		[Ноябрь],
		[Декабрь]
	)
	) piv;
	
	drop table #t1
END
GO
