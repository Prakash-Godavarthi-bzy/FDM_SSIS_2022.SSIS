--SELECT * FROM FDM_DB.[dbo].[WriteTable_01 Premium] 
-- WHERE pk_ReviewCycle_6 = '2022Q3'
--   AND Department_2 = 'TFD MAP Risks' AND pk_OfficeChannel_3 = 'BIFR' AND pk_PolicyType_5 = 'Binder'
--   AND pk_TriFocus_7 = 'TRI00089' AND pk_YOA_8 = 2022 AND pk_TransactionCurrency_9 ='USD'
--   AND pk_InceptionMonth_4 = 1
--   ORDER BY MS_AUDIT_TIME_11

--    SELECT * FROM FDM_DB.[dbo].[WriteTable_01 Premium] WHERE pk_ReviewCycle_6 = '2022Q2'
--   AND Department_2 = 'TFD MAP Risks' AND pk_OfficeChannel_3 = 'BIFR' AND pk_PolicyType_5 = 'Binder'
--   AND pk_TriFocus_7 = 'TRI00089' AND pk_YOA_8 = 2022 AND pk_TransactionCurrency_9 ='USD'
--   AND pk_InceptionMonth_4 = 1
--   ORDER BY MS_AUDIT_TIME_11


	DECLARE @stepSizeInMinutes INT = 1; -- Change this line to change the time interval
	DECLARE @from DATETIME2 = '2017-01-01',
			  @to DATETIME2 = '2017-02-12';

	---- Create Recursive Discrete Table
	--WITH Recursive_CTE AS
	--(
	--	   SELECT @from AS TimestampUtc
	--		UNION ALL
	--	   SELECT DATEADD(MONTH, 1, TimestampUtc) 
	--		 FROM Recursive_CTE
	--		WHERE TimestampUtc <= @to
	--)
	--SELECT *
	--  FROM Recursive_CTE
	-- ORDER BY TimestampUtc
	--OPTION (MAXRECURSION 0);

	-------------------------

	DECLARE @StartDateTime DATETIME
	DECLARE @EndDateTime DATETIME

	SET @StartDateTime = '2022-03-01'
	SET @EndDateTime = GETDATE();

	WITH DateRange(DateData) AS 
	(
		SELECT @StartDateTime as Date
		UNION ALL
		SELECT DATEADD(M,1,DateData)
		FROM DateRange 
		WHERE DateData < @EndDateTime
	)
	SELECT DateData,MONTH(DateData) AS MonthNo,YEAR(DateData) AS YearNo
	INTO #DateRanges
	FROM DateRange
	OPTION (MAXRECURSION 0)
	GO


	SELECT * FROM #DateRanges

	IF(OBJECT_ID('tempdb..#Tran') IS NOT NULL)
		DROP TABLE #Tran
	IF(OBJECT_ID('tempdb..#Tran1') IS NOT NULL)
		DROP TABLE #Tran1
	
	CREATE TABLE #Tran(CaseId INT,PatientId INT,CaseStateActiveDate DateTime,CaseStateCloseDate DateTime)

	INSERT INTO #Tran(CaseId,PatientId,CaseStateActiveDate,CaseStateCloseDate)
	VALUES (100,5000,'2022-03-01','2022-05-01'),
		(101,5001,'2022-05-01','2022-07-02'),
		(102,5002,'2022-03-01','2022-03-10'),
		(103,5003,'2022-03-01','2022-12-01')

	SELECT *,MONTH(CaseStateActiveDate) AS MonthActive,YEAR(CaseStateActiveDate) AS YearActive
		 , MONTH(CaseStateCloseDate) AS MonthClose,YEAR(CaseStateCloseDate) AS YearClose
      INTO #Tran1
	  FROM #Tran


		SELECT * FROM #Tran1

		SELECT * FROM #DateRanges A
		 OUTER APPLY #Tran1 B
		  WHERE (A.YearNo >= B.YearActive AND A.MonthNo >= B.MonthActive)
		    AND ( A.YearNo <= B.YearClose AND A.MonthNo <= B.MonthClose)
		  ORDER BY B.CaseId,B.PatientId,A.MonthNo,A.YearNo

	   SELECT * FROM #DateRanges A
		 CROSS JOIN #Tran1 B
		  WHERE (A.YearNo BETWEEN B.YearActive AND B.YearClose)
		    AND (A.MonthNo BETWEEN B.MonthActive AND B.MonthClose)		 
		  ORDER BY B.CaseId,B.PatientId,A.MonthNo,A.YearNo

		  SELECT * FROM staging_agresso.[FDMOutput].[FDMQueries] WHERE FDMSubProcess = '4D'