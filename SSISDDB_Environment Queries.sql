SELECT * FROM SSISDB.internal.projects where name like '%financelanding%'   --19
SELECT * FROM SSISDB.internal.environments  --15
SELECT * FROM SSISDb.internal.environment_variables WHERE environment_id=15
SELECT referenced_variable_name,* FROM SSISDB.internal.object_parameters where project_id=19 and project_version_lsn=143 and parameter_name like '%external%'

		SELECT C.* 
		  FROM SSISDB.internal.projects A
		 INNER JOIN SSISDB.internal.environments B
			ON A.folder_id = B.folder_id
		 INNER JOIN SSISDb.internal.environment_variables C
			ON B.environment_id = C.environment_id
		 WHERE B.environment_name = 'FDM_SSIS' AND A.name = 'FDM_SSIS'
		  --AND C.[name] = 'PFTSharedLocation'
		  ORDER BY C.name 

-----------------------------------------------------------
		/*================================FDM Catalog Folder  and FDM_SSIS Catalog Environment ======================================================*/

		DECLARE @FDMFolder VARCHAR(30)='FDM',
				@FDM_SSISEnv VARCHAR(30)='FDM_SSIS',
				@FDM_DC_SSISEnv VARCHAR(30)='FDM_DC_SSIS',
				@FolderId_FDM INT


				SELECT Name	FROM SSISDB.catalog.folders	WHERE Name=@FDMFolder
				SELECT E.NAME	FROM SSISDB.catalog.environments E
					JOIN   SSISDB.catalog.folders F ON E.folder_id=F.folder_id
					WHERE F.name=@FDMFolder AND E.Name=@FDM_SSISEnv
				SELECT E.NAME	FROM SSISDB.catalog.environments E
					JOIN   SSISDB.catalog.folders F ON E.folder_id=F.folder_id
					WHERE F.name=@FDMFolder AND E.Name=@FDM_DC_SSISEnv
 
		SELECT * FROM SSISDB.[internal].[environments]
		SELECT * FROM SSISDB.[internal].[folders]

	/*To get envirnment variable mapping*/

	SELECT objp.[referenced_variable_name] AS [EnvironmentVariable]
        , fldr.name AS FolderName
        , proj.name AS ProjectName
        , COALESCE('Package: ' + pkg.name, 'Project') AS Scope
        , objp.parameter_name COLLATE Latin1_General_CS_AS AS ParameterName
	FROM SSISDB.internal.object_parameters objp
	INNER JOIN SSISDB.internal.projects proj
	ON objp.project_id = proj.project_id
	Inner join SSISDB.internal.folders fldr
	ON proj.folder_id = fldr.folder_id
	LEFT JOIN SSISDB.internal.packages pkg
       		ON objp.object_name = pkg.name
       		AND objp.project_id = pkg.project_id
	WHERE objp.value_type = 'R' --AND objp.parameter_name LIKE '%PFT%'
	  AND proj.name = 'FDM_SSIS'
	  AND objp.parameter_name LIKE '%PFT%'

	SELECT    objp.[referenced_variable_name] AS [EnvironmentVariable]
			, fldr.name AS FolderName
			, proj.name AS ProjectName
			, COALESCE('Package: ' + pkg.name, 'Project') AS Scope
			, objp.parameter_name COLLATE Latin1_General_CS_AS AS ParameterName
	FROM SSISDB.catalog.object_parameters objp
		INNER JOIN SSISDB.catalog.projects proj
			ON objp.project_id = proj.project_id
		INNER JOIN SSISDB.catalog.folders AS fldr
			ON proj.folder_id = fldr.folder_id
		LEFT JOIN SSISDB.catalog.packages pkg
			ON objp.object_name = pkg.name
			AND objp.project_id = pkg.project_id
	-- Only search Projects/Packages that reference Environment variables
	WHERE objp.value_type = 'R'
		AND proj.name like '%FDM_SSIS%'

	SELECT * FROM SSISDB.internal.projects WHERE name='FDM_SSIS'
	SELECT * FROM SSISDB.internal.projects WHERE name='FDM_SSIS'
	SELECT * FROM SSISDB.internal.packages WHERE project_id = 4 ORDER BY [name]

	SELECT TOP 100 * FROM FDM_PROCESS.Admin.RunProcessLog ORDER BY 1 DESC
	SELECT TOP 100 * FROM FDM_PROCESS.Admin.RunProcessLog WHERE EndTime IS NULL ORDER BY 1 DESC
	SELECT TOP 100 * FROM FDM_PROCESS.Admin.RunProcessLog WHERE Module = 'Overnight' ORDER BY 1 DESC --465696159
	SELECT TOP 100 * FROM FDM_PROCESS.Admin.RunProcessLog WHERE LastInsertedAgrtid IS NOT NULL ORDER BY 1 DESC --465696336

SELECT referenced_variable_name,parameter_name,* FROM SSISDB.internal.object_parameters
WHERE project_id IN (SELECT project_id FROM SSISDB.internal.projects WHERE name='FDM_SSIS' )
AND project_version_lsn IN (SELECT MAX(object_version_lsn) FROM SSISDB.internal.projects WHERE name='FDM_SSIS' )
AND parameter_name ='PFTSharedLocation'
SELECT * FROM SSISDB.internal.environment_variables
WHERE environment_id IN (SELECT environment_id FROM SSISDB.internal.environments where environment_name='FDM_SSIS')
and name='PFTSharedLocation'

	SELECT referenced_variable_name,parameter_name,* FROM SSISDB.internal.object_parameters
	WHERE project_id IN (SELECT project_id FROM SSISDB.internal.projects WHERE name='FDM_SSIS' )

SELECT * FROM SSISDB.internal.environment_references
361684995
361686730
	SELECT * FROM SSISDB.[internal].[environments]
	SELECT * FROM SSISDB.[internal].[environment_variables] WHERE environment_id = 1 AND name LIKE '%PFT%'


	----------------------------------------------------

	SELECT * FROM FDM_DB.dbo.PFTFileLog ORDER BY 1 DESC

	SELECT DISTINCT [Review Cycle] FROM FDM_DB.FDM_Export.PFT_SYND_WITH_CEDE ORDER BY [Review Cycle] DESC

	SELECT DISTINCT AccountingPeriod FROM FDM_DB.dbo.PremiumForecastPremiumStage Order BY AccountingPeriod DESC-- WHERE AccountingPeriod = 202212

	SELECT * FROM FDM_DB.FDM_Export.PFT_SYND_WITH_CEDE WHERE [Review Cycle] = '2022Q4'
	--TRUNCATE TABLE FDM_DB.FDM_Export.PFT_SYND_WITH_CEDE
	SELECT * FROM FDM_PROCESS.Admin.RunProcessConfig WHERE ModuleName LIKE '%PFT%'