create table a.Geography 
(
	AirportId int primary key identity(1,1) not null,
	Name varchar (255) not null,
	City varchar (255),
	Region varchar (255),
	Country varchar (255),
	Continent varchar (255)
)

create table a.Companies
(
	AirCompanyId int primary key identity(0,1) not null,
	Name varchar(255) not null
)

create table a.Planes
(
	PlaneId int primary key identity(1,1) not null,
	Name varchar (255) not null,
	Seats int 
)

create table a.Flights
(
	RecordId int primary key identity(1,1) not null,
	DepartureDateTime datetime not null,
	ArrivalDateTime datetime not null,
	DepartureAirportId int foreign key references a.Geography(AirportId) not null,
	DestinationAirportId int foreign key references a.Geography(AirportId) not null,
	AirCompanyId int foreign key references a.Companies(AirCompanyId) not null,
	PlaneId int foreign key references a.Planes(PlaneId) not null,
	Passengers int not null
)

---------------------------------------------------------------------------------------------------------

insert into a.Companies --  Ваша авиакомпания представлена под идентификатором 0.
(
	Name
)
values
(
	'AdventureBirds'
)

select * from a.Companies
---------------------------------------------------------------------------------------------------------
/*
	В задание это не входит, но для написания запросов, немного заполним таблицы данными
*/

create table #t1
(
	Continent varchar (255)
)

insert into #t1
(
	Continent
)
values
(
	'Европа'
),
(	
	'Азия'
),
(	
	'Австралия'
),
(	
	'Северная Америка'
),
(	
	'Южная Америка'
),
-- а вдруг
(	
	'Антарктида'
) 



declare 
@a int = 100 -- сколько строк добавить

while @a > 0

begin

	insert into a.Geography
	(
		Name,
		City,
		Region,
		Country,
		Continent
	)
	values
	(
		'Аэропорт'+ ' ' + CHAR ((ABS(Checksum(NewID()) % 15) + 1) + 64) + CHAR ((ABS(Checksum(NewID()) % 15) + 1) + 64)+ CHAR ((ABS(Checksum(NewID()) % 15) + 1)+ 64),
		'Город'+ ' ' + CHAR ((ABS(Checksum(NewID()) % 15) + 1) + 64) + CHAR ((ABS(Checksum(NewID()) % 15) + 1) + 64)+ CHAR ((ABS(Checksum(NewID()) % 15) + 1)+ 64),
		'Регион'+ ' ' + CHAR ((ABS(Checksum(NewID()) % 15) + 1) + 64) + CHAR ((ABS(Checksum(NewID()) % 15) + 1) + 64)+ CHAR ((ABS(Checksum(NewID()) % 15) + 1)+ 64),
		'Страна'+ ' ' + CHAR ((ABS(Checksum(NewID()) % 15) + 1) + 64) + CHAR ((ABS(Checksum(NewID()) % 15) + 1) + 64)+ CHAR ((ABS(Checksum(NewID()) % 15) + 1)+ 64),
		(select top 1 Continent FROM #t1 order by NewID())
	)
	
	insert into a.Companies 
	(
		Name
	)
	select 
		'Company' + CHAR ((ABS(Checksum(NewID()) % 15) + 1) + 64) + CHAR ((ABS(Checksum(NewID()) % 15) + 1) + 64)+ CHAR ((ABS(Checksum(NewID()) % 15) + 1)+ 64)
	
	insert into a.Planes
	(
		Name,
		Seats
	)
	select 
		CHAR ((ABS(Checksum(NewID()) % 15) + 1) + 64) + '-' + CONVERT(varchar(10), ABS(Checksum(NewID()) % 100 + 200)),
		ABS(Checksum(NewID()) % 100) + 200
	
	select @a = @a - 1

end

drop table #t1

declare 
@b int = 10000, -- сколько строк добавить
@DepartureDateTime datetime,
@ArrivalDateTime datetime,
@DepartureAirportId int,
@DestinationAirportId int,
@PlaneId int,
@Passengers int


while @b > 0

begin
	
	set @DepartureDateTime  = (select CAST(DateAdd(d, ROUND(DateDiff(D, '2010-01-01', '2013-01-01') * RAND(), 0), '2013-01-01') AS DATETIME) + CAST(dateadd(millisecond, cast(86400000 * RAND() as int), convert(time, '00:00')) AS DATETIME))
	set @ArrivalDateTime = DATEADD(hh,ABS(Checksum(NewID()) % 10), @DepartureDateTime) -- время прилёта должно быть больше времени вылета в пределах 10 часов	
	set @DepartureAirportId  = (select top 1 AirportId FROM a.Geography order by NewID())
	set @DestinationAirportId = (
		select 
			top 1 AirportId 
		from a.Geography 
		where AirportId !=@DepartureAirportId 
		order by NewID()
	) -- аэропорт прибытия не может совпадать с аэропортом отправления (аварийные посадки в счёт не берём). 
	set @PlaneId = (select top 1 PlaneId FROM a.Planes order by NewID())
	set @Passengers = (select Seats - ABS(Checksum(NewID()) % 10) from a.Planes where PlaneId = @PlaneId) -- пассажиров не может быть больше сидений в самолёте. 
	insert into a.Flights
	(
		DepartureDateTime,
		ArrivalDateTime,
		DepartureAirportId,
		DestinationAirportId,
		AirCompanyId,
		PlaneId,
		Passengers 
	)
	values
	(
		@DepartureDateTime,
		@ArrivalDateTime,
		@DepartureAirportId,
		@DestinationAirportId,
		(select top 1 AirCompanyId FROM a.Companies order by NewID()),
		@PlaneId,
		@Passengers
	)
		
	
	select @b = @b - 1

end

--select * from a.Flights
--select * from a.Geography
--select * from a.Companies
--select * from a.Planes
