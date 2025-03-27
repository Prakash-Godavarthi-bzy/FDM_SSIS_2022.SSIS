	SELECT * from FDM_DB..FactFDM (NOLOCK) WHERE insert_date >= '2024-12-12' AND fk_Entity =-1 AND fk_User = 1355  -- 129690
	SELECT * from FDM_DB..FactFDM (NOLOCK) WHERE insert_date >= '2024-12-12' AND fk_Entity =-1 AND fk_User = 1406  -- 60310
	SELECT * from FDM_DB..FactFDM (NOLOCK) WHERE insert_date >= '2024-12-12' AND fk_Entity =-1 AND fk_User = 1564  -- 745764

	SELECT * FROM FDM_DB.dbo.FactFDM (NOLOCK) WHERE insert_date >= '2024-11-01' AND fk_Entity =-1 -- 2035
	SELECT * FROM FDM_DB.dbo.FactFDM (NOLOCK) WHERE bk_TransactionID IN (620427436,620427438,620427440,620427442,620427444,620427446,620427448,620427450,620427452,
		620427454,
		620427456,
		620427458,
		620427460,
		620427462)

	SELECT * FROM FDM_DB.dbo.FactFDM (NOLOCK) WHERE bk_TransactionID IN (620437177)
	SELECT * FROM FDM_DB.dbo.DimEntity WHERE EntityCode LIKE '%IFRS%'


	/****************************************************************************/
	  IF(OBJECT_ID('tempdb..#ModuleRunTime') IS NOT NULL)
		DROP TABLE #ModuleRunTime

	  SELECT RunProcessLogID, Module,CreatedDate,SelectedAccountingPeriod,TimeTaken
	  INTO #ModuleRunTime
	  FROM 
		(
		SELECT MAX(RunProcessLogID) AS RunProcessLogID
		     , Module
			 , MAX(CreatedDate) AS CreatedDate
			 , SelectedAccountingPeriod
			 , DATEDIFF(MI,MAX(StartTime),MAX(EndTime)) AS TimeTaken
			 , ROW_NUMBER() OVER (PARTITION BY Module,SelectedAccountingPeriod ORDER BY MAX(CreatedDate) DESC) AS RowID			 
		  FROM FDM_Process.Admin.RunProcessLog 
		 WHERE fk_RunProcessConfig  NOT IN (-1,14,42) 
		   AND CreatedDate >= DATEADD(MM,-5,GETDATE())
		   AND [Status]= 'Success'
		 GROUP BY Module,SelectedAccountingPeriod
		 --ORDER BY Module,CreatedDate--DATEDIFF(MI,StartTime,EndTime) DESC
		 ) T
	 WHERE RowID = 1
	   --AND TimeTaken >=5
	 ORDER BY Module,SelectedAccountingPeriod,TimeTaken

	 SELECT DISTINCT A.*		  
		  , COALESCE(C1.ProcessCode,C2.ProcessCode,'Unknown') AS ProcessCode
		  , COALESCE(C1.ProcessName,C2.ProcessName,'Unknown') AS ProcessName  
	   FROM #ModuleRunTime A
	   LEFT JOIN FDM_DB.dbo.vw_FactFDMExternal	B (NOLOCK)
	     ON A.RunProcessLogID = B.RunProcessLogID
	   LEFT JOIN FDM_DB.dbo.DimProcess C1
	     ON B.fk_Process = C1.pk_Process
	  LEFT JOIN FDM_DB.dbo.VW_FACTAllocationV1_Total	D (NOLOCK)
	     ON A.RunProcessLogID = D.BatchID
	   LEFT JOIN FDM_DB.dbo.DimProcess C2
	     ON D.fk_Process = C2.pk_Process
	  ORDER BY Module,SelectedAccountingPeriod,TimeTaken