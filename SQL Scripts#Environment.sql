--SELECT TOP 100 * FROM FDM_PROCESS.Admin.RunProcessLog ORDER BY 1 DESC

SELECT referenced_variable_name,parameter_name,* FROM SSISDB.internal.object_parameters
WHERE project_id IN (SELECT project_id FROM SSISDB.internal.projects WHERE name='FDM_SSIS' )
AND project_version_lsn IN (SELECT MAX(object_version_lsn) FROM SSISDB.internal.projects WHERE name='FDM_SSIS' )
AND parameter_name ='SMTPServer'
SELECT * FROM SSISDB.internal.environment_variables
WHERE environment_id IN (SELECT environment_id FROM SSISDB.internal.environments where environment_name='FDM_SSIS')
and name='SMTPServer'

	SELECT referenced_variable_name,parameter_name,* FROM SSISDB.internal.object_parameters
	WHERE project_id IN (SELECT project_id FROM SSISDB.internal.projects WHERE name='FDM_SSIS' )

SELECT * FROM SSISDB.internal.environment_references
361684995
361686730
	SELECT * FROM SSISDB.[internal].[environments]
	SELECT * FROM SSISDB.[internal].[environment_variables] WHERE environment_id = 1 AND name LIKE '%D%'
