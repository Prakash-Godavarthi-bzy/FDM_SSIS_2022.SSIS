DECLARE @environment_name NVARCHAR (5)
SELECT @environment_name = CAST([value] AS NVARCHAR(3)) FROM [master].[sys].[fn_listextendedproperty] (NULL, NULL, NULL, NULL, NULL, NULL, NULL) WHERE [name] = N'Environment Name'
PRINT @environment_name
 
IF (@environment_name='SYS')
BEGIN

BEGIN TRY ;

	BEGIN TRAN ;
	
		UPDATE FDM_PROCESS.[Admin].[RunProcessLog] 
		   SET LastInsertedAgrtid = CASE WHEN Module = 'Overnight' THEN 396389605 ELSE null END
		 WHERE LastInsertedAgrtid IS NOT NULL AND RunProcessLogID > 466913 --3

		DELETE FROM FDM_DB.dbo.ExecutionLog
		WHERE LastInsertedID > 396389605
		AND TableName in ('FactFDM','DimTransactionDetails') --6

		DELETE FROM FDM_DB.dbo.DimTransactionDetailsV1_Current
		WHERE bk_TransactionID>396389605 --33

		DELETE FROM FDM_DB.dbo.DimTransactionDetailsV1_History
		WHERE bk_TransactionID>396389605 --0
		
		DELETE FROM FDM_DB.dbo.FACTFDM
		WHERE bk_TransactionID>396389605---- 33	

		--/*Insert missing Overnight entry into Run process log*/
		--INSERT INTO [FDM_PROCESS].[Admin].[RunProcessLog]               
  --      SELECT '-1' AS [fk_RunProcessConfig],'Not Applicable' AS [FileName], 'Overnight' AS [Module],'2021-08-20 01:57:08.530' AS [CreatedDate]
  --              ,'FDM' AS [CreatedBy],'202108' AS [SelectedAccountingPeriod], '2021-08-20 01:57:08.530' AS [StartTime], '2021-08-20 03:54:46.490' AS [EndTime]
  --              ,'SUCCESS' [Status]    , 'Y' [FileStatus],395187035 [LastInsertedAgrtid]

				 
		Commit TRAN
		
END TRY

BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK ;
	THROW ;
END CATCH

END

ELSE
PRINT 'No script executed'

--LastInsertedAgrtid - 396389777
	--SELECT * FROM FDM_PROCESS.[Admin].[RunProcessLog] ORDER BY 1 DESC

	--UPDATE FDM_PROCESS.[Admin].[RunProcessLog]
	--   SET EndTime = GETDATE()
	--     , [Status] = 'Success'
	-- WHERE RunProcessLogID = 471557


	/*
		SELECT * FROM FDM_PROCESS.[Admin].[RunProcessLog] 
		   --SET LastInsertedAgrtid = CASE WHEN Module = 'Overnight' THEN 396389605 ELSE null END
		 WHERE LastInsertedAgrtid IS NOT NULL AND RunProcessLogID > 466913 --3

		SELECT * FROM FDM_DB.dbo.ExecutionLog
		WHERE LastInsertedID > 396389605
		AND TableName in ('FactFDM','DimTransactionDetails') --24

		SELECT * FROM FDM_DB.dbo.DimTransactionDetailsV1_Current
		WHERE bk_TransactionID>396389605 --3837

		SELECT * FROM FDM_DB.dbo.DimTransactionDetailsV1_History
		WHERE bk_TransactionID>396389605 --0
		
		SELECT * FROM FDM_DB.dbo.FACTFDM
		WHERE bk_TransactionID>396389605---- 3837	
	*/