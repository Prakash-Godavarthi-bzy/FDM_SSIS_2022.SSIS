
SELECT * FROM SSISDB.[internal].[executions] WHERE execution_id = 1043809
SELECT * FROM SSISDB.[internal].[execution_parameter_values] WHERE execution_id = 1043809 AND parameter_name LIKE '%MDS%'
SELECT * FROM SSISDB.[internal].[execution_parameter_values] WHERE execution_id = 1043809 AND parameter_name LIKE '%FDM%'
SELECT * FROM SSISDB.[internal].[object_parameters] WHERE [object_name] = 'BIDAC_ControlLoad.dtsx' AND parameter_name LIKE '%MDS%'

------------------------------------------------------------------
EXEC SSISDB.catalog.stop_operation @operation_id = 0


SELECT TOP 100 EM.event_message_id,
EM.operation_id ,
EM.execution_path,
EM.package_name,
EM.package_location_type,
EM.package_path_full,
EM.event_name,
EM.message_source_name,
EM.subcomponent_name,
EM.package_path,
OM.message,
OM.message_type
FROM SSISDB.internal.event_messages EM
 
INNER JOIN SSISDB.internal.operation_messages OM
ON EM.operation_id=OM.operation_id AND EM.event_message_id=OM.operation_message_id 
WHERE OM.message_type=120 AND EM.event_name='OnError'
AND convert(date,OM.message_time) = convert(date,getdate())
ORDER BY EM.operation_id


--SELECT referenced_variable_name,parameter_name,* FROM SSISDB.internal.object_parameters
--WHERE project_id IN (SELECT project_id FROM SSISDB.internal.projects WHERE name='FDM_SSIS' )
--AND project_version_lsn IN (SELECT MAX(object_version_lsn) FROM SSISDB.internal.projects WHERE name='FDM_SSIS' )
--AND parameter_name ='SMTPServer'
--SELECT * FROM SSISDB.internal.environment_variables

--WHERE environment_id IN (SELECT environment_id FROM SSISDB.internal.environments where environment_name='FDM_SSIS')
--and name='SMTPServer'



--	SELECT referenced_variable_name,parameter_name,* FROM SSISDB.internal.object_parameters

--	WHERE project_id IN (SELECT project_id FROM SSISDB.internal.projects WHERE name='FDM_SSIS' )



--SELECT * FROM SSISDB.internal.environment_references
--361684995
--361686730

--	SELECT * FROM SSISDB.[internal].[environments]

--	SELECT * FROM SSISDB.[internal].[environment_variables] WHERE environment_id = 1 AND name LIKE '%D%'


	
SELECT     execs.[execution_id], 
           execs.[folder_name], 
           execs.[project_name], 
           execs.[package_name],
           execs.[reference_id],
           execs.[reference_type], 
           execs.[environment_folder_name], 
           execs.[environment_name], 
           execs.[project_lsn], 
           execs.[executed_as_sid], 
           execs.[executed_as_name], 
           execs.[use32bitruntime],  
           opers.[operation_type], 
           opers.[created_time],  
           opers.[object_type], 
           opers.[object_id],
           opers.[status], 
           opers.[start_time], 
           opers.[end_time],  
           opers.[caller_sid], 
           opers.[caller_name], 
           opers.[process_id], 
           opers.[stopped_by_sid], 
           opers.[stopped_by_name],
           opers.[operation_guid] as [dump_id],
           opers.[server_name],
           opers.[machine_name],
           ossysinfos.[total_physical_memory_kb],
           ossysinfos.[available_physical_memory_kb],
           ossysinfos.[total_page_file_kb],
           ossysinfos.[available_page_file_kb],
           ossysinfos.[cpu_count]
		FROM       [internal].[executions] execs 
		INNER JOIN [internal].[operations] opers 
           ON execs.[execution_id]= opers.[operation_id]
           LEFT JOIN [internal].[operation_os_sys_info] ossysinfos
           ON ossysinfos.[operation_id]= execs.[execution_id]
		   --WHERE execs.[execution_id] IN (637141,637144)
		   where opers.[status] = 2
		   ORDER BY start_time DESC
--WHERE      opers.[operation_id] in (SELECT id FROM [internal].[current_user_readable_operations])
           --OR (IS_MEMBER('ssis_admin') = 1)
           --OR (IS_SRVROLEMEMBER('sysadmin') = 1)

	SELECT * FROM [internal].[executions] WHERE execution_id = 637141
	SELECT * FROM [internal].[operations] WHERE [operation_id] = 637141
	SELECT * FROM [internal].[executables] ORDER BY 1 DESC

	SELECT * FROM [internal].[executions] WHERE execution_id = 647160
	SELECT * FROM [internal].[operations] WHERE [operation_id] = 647160

	SELECT 'exec [catalog].[stop_operation] ' + CAST(operation_id as varchar(10))
	FROM [SSISDB].[internal].[operations]  where status = 2



	SELECT em.*
     FROM SSISDB.[internal].event_messages em
     WHERE em.operation_id = 637141

	SELECT 
    q.*
FROM
    (SELECT em.*
     FROM SSISDB.[internal].event_messages em
     WHERE em.operation_id = (SELECT MAX(execution_id) 
                              FROM SSISDB.[internal].executions)
       AND event_name NOT LIKE '%Validate%') q
/* Put in whatever WHERE predicates you might like*/
--WHERE event_name = 'OnError'
WHERE package_name = '1 Control Load FDM.dtsx'
--WHERE execution_path LIKE '%<some executable>%'
ORDER BY message_time DESC

----------------------------------------------------------------------------------------------------------------

SELECT * FROM SSISDB.internal.operations
	where status=2
	ORDER BY 1 DESC

	SELECT * FROM SSISDB.internal.operation_messages
	WHERE message_type=120
	ORDER BY 1 DESC

	SELECT * FROM SSISDB.internal.executable_statistics
	WHERE execution_id=637140

	
SELECT * FROM SSISDB.internal.event_messages
	
SELECT * FROM SSISDB.internal.operation_messages WHERE operation_id = 637140 AND message_type IN (110,120)
	
SELECT * FROM SSISDB.internal.operation_messages WHERE operation_id = 637140 AND message_type IN (120)

	
SELECT * FROM [SSISDB].[internal].[executions] ORDER BY 1 DESC


		SELECT
		  ex.execution_id,
		  ex.package_name,
		  ex.environment_name,
		  ex.caller_name,
		  DATEDIFF(SECOND, CAST(ex.start_time AS datetime2), SYSDATETIME()) AS 'run_time_sec'
		  --smc.threshold_time_sec,
		  --smc.alert_email 
		  --INTO #execution_info
		FROM ssisdb.catalog.executions(nolock) ex
		--JOIN dbo.ssis_monitor_configure(nolock) smc
		--  ON ex.package_name = smc.package_name
		WHERE ex.end_time IS NULL  -- still running 
		AND ex.status = 2 -- ( 1-created , 2-running ,3-canceled,4-failed ,5-pending,6-ended unexpectedly,7-succeeded ,8-stopping, 9-completed )
		--AND (ex.environment_name = smc.environment_name
		--OR smc.environment_name IS NULL)
		--AND (DATEDIFF(SECOND, CAST(ex.start_time AS datetime2), SYSDATETIME()) > smc.threshold_time_sec);