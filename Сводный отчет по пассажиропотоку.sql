SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	������� �.�.
-- Create date: 2016-12-04
-- Description:	��������� ��� ������ "������� ����� �� ���������������"

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
			when DATENAME(month, DepartureDateTime) = 'January' then '������'
			when DATENAME(month, DepartureDateTime) = 'February' then '�������'
			when DATENAME(month, DepartureDateTime) = 'March' then '����'
			when DATENAME(month, DepartureDateTime) = 'April' then '������'
			when DATENAME(month, DepartureDateTime) = 'May' then '���'
			when DATENAME(month, DepartureDateTime) = 'June' then '����'
			when DATENAME(month, DepartureDateTime) = 'July' then '����'
			when DATENAME(month, DepartureDateTime) = 'August' then '������'
			when DATENAME(month, DepartureDateTime) = 'September' then '��������'
			when DATENAME(month, DepartureDateTime) = 'October' then '�������'
			when DATENAME(month, DepartureDateTime) = 'November' then '������'
			when DATENAME(month, DepartureDateTime) = 'December' then '�������'
		end dt,
		AirCompanyId,
		-- ��� isnull �� ��������. ������� � �������� �������� ������. �� ��������� �� ��� ���� �������...
		isnull(Passengers, 0) 
	from a.Flights
	where DepartureDateTime >= @from_date and DepartureDateTime < @trim_date



	select
		AirCompanyId,
		[������],
		[�������],
		[����],
		[������],
		[���],
		[����],
		[����],
		[������],
		[��������],
		[�������],
		[������],
		[�������]
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
		[������],
		[�������],
		[����],
		[������],
		[���],
		[����],
		[����],
		[������],
		[��������],
		[�������],
		[������],
		[�������]
	)
	) piv;
	
	drop table #t1
END
GO
