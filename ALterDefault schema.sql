DECLARE @environment_name NVARCHAR (5)
SELECT @environment_name = CAST([value] AS NVARCHAR(3)) FROM [master].[sys].[fn_listextendedproperty] (NULL, NULL, NULL, NULL, NULL, NULL, NULL) WHERE [name] = N'Environment Name'
PRINT @environment_name

	DECLARE @LoginName NVARCHAR(255) = N'BFL\FDM Developers',@SQL NVARCHAR(255)
	SET        @SQL = 'ALTER SERVER ROLE [sysadmin] ADD MEMBER ['+@LoginName+']'
    EXEC sp_executesql @SQL
	Print 'User permissions assigned to '+@LoginName + ' - ' + @SQL


	SELECT su.name as DatabaseUser
	FROM sys.sysusers su
	join sys.syslogins sl on sl.sid = su.sid
	where sl.name = 'BFL\PXY_FDM_DEV' -- login

	SELECT su.name as DatabaseUser,sl.name AS LoginName
	FROM sys.sysusers su
	join sys.syslogins sl on sl.sid = su.sid
	where sl.name = 'BFL\FDM Developers'--sl.name = 'BFL\PXY_FDM_DEV' -- login

	SELECT A.name as userName, B.name as login, B.Type_desc, default_database_name, B.*   
	FROM sys.sysusers A   
		FULL OUTER JOIN sys.sql_logins B   
		   ON A.sid = B.sid   
	WHERE islogin = 1 and A.sid is not null

	SELECT DB_NAME(DB_ID()) as DatabaseName, * FROM sys.sysusers  
	
	SELECT DB_NAME(DB_ID()) as DatabaseName,* FROM sys.sysusers WHERE name = 'BFL\FDM Developers'

	select * from sys.database_principals where type='U' or type = 'S'
	SELECT * FROM master.sys.sql_logins

	sp_verify_proxy_identifiers
	
	/******************To change DB owner**************************/
	SELECT s.name
	FROM sys.schemas s
	WHERE s.principal_id = USER_ID('PXY_FDM');

	USE staging_agresso
	ALTER AUTHORIZATION ON SCHEMA::Admin TO dbo;
--ALTER AUTHORIZATION ON SCHEMA::db_denydatawriter TO dbo;
	/****************Changes the properties of an existing proxy.***********************************/
	USE msdb ;  
	GO  
	IF NOT EXISTS (select * from msdb.dbo.sysproxies WHERE [name] = 'PXY_FDM' AND [enabled] = 1)
	BEGIN
		EXEC dbo.sp_update_proxy  
			@proxy_name = 'PXY_FDM',  
			@enabled = 1;  

		PRINT 'PXY_FDM Enabled.'				
	END
	GO
	/*****************************************************/


	--CREATE LOGIN [proxy_login] WITH PASSWORD=N'passw0rd', 
--    DEFAULT_DATABASE=[SSISConfig], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF

	CREATE CREDENTIAL [PXY_FDM] WITH IDENTITY='PXY_FDM_DEV', SECRET='passw0rd'

	ALTER LOGIN [BFL\PXY_FDM_DEV] ADD CREDENTIAL [PXY_FDM]
	GO
	USE [msdb]
	GO
	EXEC msdb.dbo.sp_add_proxy @proxy_name=N'PXY_FDM',@credential_name=N'PXY_FDM', 
			@enabled=1
	GO
	EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'PXY_FDM', @subsystem_id=11
	GO

	-------------------------------------

	SELECT [destination_database_name], MAX(restore_date) AS restore_date,MAX(backup_start_date) AS backup_start_date
	FROM
	(
		SELECT[rs].[destination_database_name],[rs].[restore_date],[bs].[backup_start_date],[bs].[backup_finish_date]
	,[bs].[database_name] as [source_database_name]
	,[bmf].[physical_device_name] as [backup_file_used_for_restore]
	FROM msdb.dbo.restorehistory rs
	INNER JOIN msdb.dbo.backupset bs ON [rs].[backup_set_id] = [bs].[backup_set_id]
	INNER JOIN msdb.dbo.backupmediafamily bmf 
	ON [bs].[media_set_id] = [bmf].[media_set_id]
	--ORDER BY [rs].[restore_date] DESC
	) AS T
	GROUP BY [destination_database_name]