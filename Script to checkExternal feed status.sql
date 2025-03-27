DECLARE @JOB_NAME AS VARCHAR(50),@JOB_ID1 AS UNIQUEIDENTIFIER;
SET @JOB_NAME = N'FDM_ExternalFeed';
SELECT @JOB_ID1 = JOB_ID FROM MSDB.dbo.sysjobs WHERE name='FDM_ExternalFeed';

SELECT TOP 1 CASE WHEN STOP_EXECUTION_DATE IS NULL THEN 'External Feed Job is running.' ELSE 'External Feed Job is running.'
	   END AS ExternalJobStatus
  FROM MSDB.dbo.sysjobactivity WHERE job_id = @JOB_ID1
   AND CAST(start_execution_date AS DATE) = CAST(GETDATE() AS DATE)
 ORDER BY 1 DESC




	