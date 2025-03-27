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
	  /*******************************************************************/
	SELECT Module,fk_RunProcessConfig,B.FolderName,MAX(CreatedDate) AS CreatedDate--,SelectedAccountingPeriod
		 --, DATEDIFF(MI,StartTime,EndTime) AS TimeTaken
		 --, ROW_NUMBER() OVER (PARTITION BY Module ORDER BY CreatedDate DESC) AS RowID
	  FROM FDM_Process.Admin.RunProcessLog A
     INNER JOIN FDM_Process.Admin.RunProcessConfig B
	    ON A.fk_RunProcessConfig = B.pk_RunProcessConfig
	 WHERE fk_RunProcessConfig  NOT IN (-1,14,42,3,13) 
	   --AND CreatedDate < DATEADD(YY,-1,GETDATE())
	   AND [Status]= 'Success'
	 GROUP BY Module,fk_RunProcessConfig,B.FolderName
	 HAVING MAX(CreatedDate) < DATEADD(YY,-1,GETDATE())
	 ORDER BY MAX(CreatedDate) DESC,Module

	/**********************Modules which are not run in past one year***************************/
	SELECT A.ModuleName,A.FolderName, T.LastRunDate,pk_RunProcessConfig
	  FROM FDM_Process.Admin.RunProcessConfig A	  
	 INNER JOIN	( 
	SELECT fk_RunProcessConfig --AS pk_RunProcessConfig
	    , MAX(CreatedDate) AS LastRunDate--,fk_RunProcessConfig AS pk_RunProcessConfig	 
	  FROM FDM_Process.Admin.RunProcessLog A     
	 WHERE fk_RunProcessConfig  NOT IN (-1,14,42,3,13) 
	--AND CreatedDate < DATEADD(YY,-1,GETDATE())
	   AND [Status]= 'Success'
	 GROUP BY fk_RunProcessConfig
	HAVING MAX(CreatedDate) < DATEADD(YY,-1,GETDATE())
	) AS T
	ON A.pk_RunProcessConfig = T.fk_RunProcessConfig
	UNION 
	SELECT A.ModuleName,A.FolderName, NULL AS LastRunDate,pk_RunProcessConfig
	  FROM FDM_Process.Admin.RunProcessConfig A	  
	  LEFT JOIN	FDM_Process.Admin.RunProcessLog T		 
	    ON A.pk_RunProcessConfig = T.fk_RunProcessConfig
	 WHERE T.fk_RunProcessConfig IS NULL
	 ORDER BY A.ModuleName

	 /**********************Modules which are not run in past one year with Last used user name***************************/
	SELECT A.ModuleName,A.FolderName, T.LastRunDate,pk_RunProcessConfig--,T.RunProcessLogID
	     --, PL.CreatedBy
		 , U.UserName
	  FROM FDM_Process.Admin.RunProcessConfig A	  
	 INNER JOIN	( 
			SELECT fk_RunProcessConfig --AS pk_RunProcessConfig
				, MAX(CreatedDate) AS LastRunDate--,fk_RunProcessConfig AS pk_RunProcessConfig
				, MAX(RunProcessLogID) AS RunProcessLogID
			  FROM FDM_Process.Admin.RunProcessLog A     
			 WHERE fk_RunProcessConfig  NOT IN (-1,14,42,3,13) 
			--AND CreatedDate < DATEADD(YY,-1,GETDATE())
			   AND [Status]= 'Success'
			 GROUP BY fk_RunProcessConfig
			HAVING MAX(CreatedDate) < DATEADD(YY,-1,GETDATE())
		) AS T
	   ON A.pk_RunProcessConfig = T.fk_RunProcessConfig
	INNER JOIN FDM_Process.Admin.RunProcessLog PL
	   ON PL.RunProcessLogID = T.RunProcessLogID
	 LEFT JOIN FDM_DB.dbo.DimUser U
	   ON U.UserID = PL.CreatedBy
	UNION 
	SELECT A.ModuleName,A.FolderName, NULL AS LastRunDate,pk_RunProcessConfig, NULL AS UserName --CreatedBy
	  FROM FDM_Process.Admin.RunProcessConfig A	  
	  LEFT JOIN	FDM_Process.Admin.RunProcessLog T		 
	    ON A.pk_RunProcessConfig = T.fk_RunProcessConfig
	 WHERE T.fk_RunProcessConfig IS NULL
	 ORDER BY A.ModuleName

	 ------------------------------------------------------------

--	 SELECT * FROM FDM_Process.Admin.RunProcessConfig ORDER BY FolderName

	SELECT A.ModuleName,A.FolderName, T.LastRunDate,pk_RunProcessConfig
	  FROM FDM_Process.Admin.RunProcessConfig A	  
	  LEFT JOIN	(
			SELECT fk_RunProcessConfig,MAX(CreatedDate) AS LastRunDate--,SelectedAccountingPeriod		 
			  FROM FDM_Process.Admin.RunProcessLog A     
			 WHERE fk_RunProcessConfig  NOT IN (-1,14,42)--,3,13) 
			   --AND CreatedDate < DATEADD(YY,-1,GETDATE())
			   AND [Status]= 'Success'
			 GROUP BY fk_RunProcessConfig
			 --HAVING MAX(CreatedDate) < DATEADD(YY,-1,GETDATE())
			 --ORDER BY MAX(CreatedDate) DESC
		 ) AS T
	  ON A.pk_RunProcessConfig = T.fk_RunProcessConfig
	  ORDER BY ModuleName
	 

	 SELECT * FROM FDM_Process.Admin.RunProcessConfig WHERE pk_RunProcessConfig IN (7,5)


