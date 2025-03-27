---------------Check Backup file Dates------------------------------------------hewij

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

	