
	IF(OBJECT_ID('tempdb..#temp') IS NOT NULL)
		DROP TABLE #temp

	IF(OBJECT_ID('tempdb..#tempTree') IS NOT NULL)
		DROP TABLE #tempTree

	CREATE TABLE #tempTree (Pk_RequestId INT,ReportingPeriod INT,OpeningBalanceID INT,OpeningBalancePeriod INT,GroupId INT)

	SELECT Pk_RequestId,ROW_NUMBER() OVER( ORDER BY Pk_RequestId) AS RowId
	  INTO #temp
	  FROM PWAPS.IFRS17CalcUI_RunLog 
	 WHERE [Opening Balances Id] IS NOT NULL 
	 ORDER BY Pk_RequestId

	 SELECT * FROM #temp
	DECLARE @LoopCount INT,@MaxRowId INT,@Pk_RequestId INT

	SET @LoopCount = 1
	SET @MaxRowId = (SELECT MAX(RowId) FROM #temp)
	SELECT @LoopCount,@MaxRowId

	WHILE (@LoopCount <= @MaxRowId)
	BEGIN
		SELECT @Pk_RequestId  = Pk_RequestId FROM #temp WHERE RowId = @LoopCount

		;WITH CTE AS(
 
		SELECT	Pk_RequestId
				,[Reporting Period] AS ReportingPeriod
				,[Opening Balances Id] AS OpeningBalanceID
				,[OB Reporting Period] AS OpeningBalancePeriod
		FROM	PWAPS.IFRS17CalcUI_RunLog
		where Pk_RequestId=@Pk_RequestId --OR Pk_RequestId IS NULL
 
		UNION ALL
 
		SELECT		F1.Pk_RequestId,
					F1.[Reporting Period]
					,F1.[Opening Balances Id]
					,F1.[OB Reporting Period]
		FROM		CTE F
		JOIN		PWAPS.IFRS17CalcUI_RunLog F1
		ON			F.OpeningBalanceID = F1.Pk_RequestId
		)
		
		INSERT INTO #tempTree (Pk_RequestId ,ReportingPeriod ,OpeningBalanceID ,OpeningBalancePeriod,GroupId )
		SELECT *,@Pk_RequestId AS GroupId		  
		  FROM CTE

		SET @LoopCount = @LoopCount + 1
	END

	SELECT * FROM #tempTree --WHERE GroupId = 56