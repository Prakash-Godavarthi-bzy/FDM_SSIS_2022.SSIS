
--ALLOCATION ENGINE--

SELECT  
isnull(Imp.AllocationType, imp.Module) GrpModule, 
imp.Module Module, imp.RequestedDate, 
lower(imp.RequestedBy) RequestedBy, 
imp.StartTime, imp.EndTime, imp.Status, imp.NoImports,
CAST(DATEADD(ss,DATEDIFF(ss, imp.StartTime, imp.EndTime),cast('00:00:00' as time)) as NVARCHAR(8)) as ImportDuration,
Run.RequestedDate RunDate, lower(Run.RequestedBy) RunBy, Run.Status RunStatus, Run.StartTime RunStartTime, Run.EndTime RunEndTime, 
CAST(DATEADD(ss,DATEDIFF(ss, Run.StartTime, Run.EndTime),cast('00:00:00' as time)) as NVARCHAR(8)) as RunDuration,NoRuns, Run.AccPeriod RunAccPeriod,
Run.ProcessedDate InFDMCube,
post.NoPostings, post.StatusDate LastPosted, lower(post.PostedBy) PostedBy, post.SelectedAccountingPeriod PostingPeriod, post.Status PostingStatus, post.Batch FDM_BatchID,
CASE post.BackInFDMDate when null then null else POST.ProcessedDate end PostInFDMCube,
ISNULL(CASE WHEN ISNULL(post.StatusDate, '1900-01-01') > ISNULL(Run.RequestedDate, '1900-01-01') THEN post.StatusDate ELSE Run.RequestedDate end, imp.RequestedDate) DateOrder
FROM
-- Import
	(
	SELECT l.RunProcessLogID,  c.ModuleName ConfigModuleName, modGrp.AllocationType,
		   l.Module, CreatedDate As RequestedDate, CreatedBy RequestedBy, l.StartTime, l.EndTime, l.Status, NoImports
	FROM Admin.RunProcessLog l
	INNER JOIN Admin.RunProcessConfig c on l.fk_RunProcessConfig = c.pk_RunProcessConfig 
	INNER JOIN (SELECT DISTINCT AllocationGroup , AllocationType FROM FDM_DB.dbo.DimAllocationRules) ModGrp on l.Module = modGrp.AllocationGroup
	INNER JOIN
				(
				SELECT MAX(l.RunProcessLogID) RunProcessLogID, l.module ModuleName, count(*) NoImports FROM Admin.RunProcessLog l
				INNER JOIN Admin.RunProcessConfig c on l.fk_RunProcessConfig = c.pk_RunProcessConfig
				WHERE c.ModuleName = 'AL Import' 
				GROUP BY l.Module
				) lstImport on l.RunProcessLogID = lstimport.RunProcessLogID
	) Imp
LEFT JOIN
-- Trigger Run
	(
		SELECT l.RunProcessLogID, c.ModuleName ConfigModuleName, 
			   l.Module, CreatedDate As RequestedDate, CreatedBy RequestedBy, l.StartTime, l.EndTime, Status, SelectedAccountingPeriod, NoRuns, l.SelectedAccountingPeriod AccPeriod,
			   CASE [STATUS] when 'Failed' then null else ProcessedDate  end ProcessedDate
		FROM Admin.RunProcessLog l
		INNER JOIN Admin.RunProcessConfig c on l.fk_RunProcessConfig = c.pk_RunProcessConfig
		INNER JOIN 
				 (
				SELECT max(l.RunProcessLogID) RunProcessLogID, l.Module ModuleName, count(*) NoRuns FROM Admin.RunProcessLog l
				INNER JOIN Admin.RunProcessConfig c on l.fk_RunProcessConfig = c.pk_RunProcessConfig
				WHERE c.ModuleName = 'Allocations' 
				GROUP BY l.Module
				) lstRun on l.RunProcessLogID = lstRun.RunProcessLogID
		LEFT JOIN
				(
				SELECT  IL.OBJECTID, il.FromModule Module, max(cl.EndTime) ProcessedDate from ADMIN.CubeProcessLog CL 
				INNER JOIN ADMIN.IncrementalProcessLog IL on CL.pk_CubeProcessLog = il.fk_CubeProcessLog
				WHERE cl.ProcessType = 'Incremental'  and result = 'Success' and FromModule <> 'IntraDay Update' and FromModule <> 'IntraDay' and il.ObjectID LIKE 'Allocation%'
				GROUP BY il.FromModule, IL.OBJECTID
				) incCP ON l.Module = inccp.Module and l.EndTime < inccp.ProcessedDate
	) run on Imp.Module = Run.Module
-- Posting
LEFT JOIN
	(
			SELECT l.RunProcessLogID, c.ModuleName ConfigModuleName, l.Module, CreatedDate As RequestedDate, CreatedBy RequestedBy, 
				   l.StartTime, l.EndTime, SelectedAccountingPeriod, NoPostings, l.SelectedAccountingPeriod AccPeriod ,
				   case l.status when 'Processing' then 'Generating Batch' when 'Failed' then 'Failed To Generate' else pstLog.FDM_BatchId end Batch,
				   isnull(pstLog.statusdate,l.CreatedDate) StatusDate, lower(isnull(pstLog.[User], l.CreatedBy )) PostedBy,pstLog.BackInFDMDate,
				   ISNULL(pstlog.BatchStatus, ISNULL(pstLog.status, case L.Status when 'Processing' then 'Generating' when 'Pending' then 'Queued' else L.status end )) Status,
				   CASE pstLog.BackInFDMDate when null then null else min(postCP.ProcessedDate)	end ProcessedDate			  
			FROM Admin.RunProcessLog l
				  INNER JOIN Admin.RunProcessConfig c on l.fk_RunProcessConfig = c.pk_RunProcessConfig
				  INNER JOIN 
						(
						SELECT max(l.RunProcessLogID) RunProcessLogID, l.Module ModuleName, count(*) NoPostings FROM Admin.RunProcessLog l
						INNER JOIN Admin.RunProcessConfig c on l.fk_RunProcessConfig = c.pk_RunProcessConfig
						WHERE c.ModuleName = 'Agresso Posting' 
						GROUP BY l.Module
						) lstPost on l.RunProcessLogID = lstPost.RunProcessLogID
				LEFT JOIN 
						(
						SELECT DISTINCT RunProcessLogID, FDM_BatchId, Status, BatchStatus, StatusDate,ParamStringAccountingPeriod, Module, [User], BackInFDMDate from admin.PostingEngineLog
						) pstLog ON lstpost.RunProcessLogID = pstLog.RunProcessLogID
				LEFT JOIN 
						(
					    SELECT EndTime ProcessedDate from admin.IncrementalProcessLog ip
						INNER JOIN admin.cubeProcessLog cp on ip.fk_CubeProcessLog = cp.pk_CubeProcessLog
					    WHERE ProcessingState = 'Success' and ObjectID = '4dynamic'
					    UNION 
						SELECT EndTime ProcessedDate FROM admin.CubeProcessLog where ProcessType = 'Full' and Result = 'Success'
						) postCP ON pstLog.BackInFDMDate < postCP.ProcessedDate
				GROUP BY l.RunProcessLogID, c.ModuleName, l.Module, CreatedDate, CreatedBy, 
				   l.StartTime, l.EndTime, SelectedAccountingPeriod, NoPostings, l.SelectedAccountingPeriod,pstLog.FDM_BatchId ,
				   pstLog.statusdate,l.CreatedDate,pstLog.BackInFDMDate,PSTLOG.[bATCHSTATUS], L.STATUS, PSTLOG.[User], PstLog.Status
	) Post ON Imp.Module = Post.Module
GROUP BY  
imp.Module, Imp.AllocationType, imp.RequestedDate, imp.RequestedBy, imp.StartTime, imp.EndTime, imp.Status, imp.NoImports,
Run.RequestedDate, Run.RequestedBy, Run.Status, Run.StartTime, Run.EndTime, RUN.NoRuns, Run.AccPeriod,Run.ProcessedDate,Post.ProcessedDate,
post.NoPostings, post.StatusDate,post.PostedBy, post.SelectedAccountingPeriod, post.Status, post.Batch,post.BackInFDMDate
ORDER BY DateOrder DESC


--==========================================================================================================================================
--==========================================================================================================================================

--EXTERNAL FEED

SELECT   TOP 20 1 ID ,Admin.InitCap(Run.Module) AS Module
, Run.RequestedDate, LOWER(Run.RequestedBy) AS RequestedBy, Run.StartTime, Run.EndTime, Run.Status, Run.NoRuns, CAST(DATEADD(ss, DATEDIFF(ss, 
                         Run.StartTime, Run.EndTime), CAST('00:00:00' AS time)) AS NVARCHAR(8)) AS RunDuration, Run.AccPeriod, CASE run.status WHEN 'Success' THEN isnull(MIN(inccp.ProcessedDate), MIN(fullcp.ProcessedDate)) 
                         ELSE NULL END AS InFDMCube, Post.NoPostings, Post.StatusDate AS LastPosted, LOWER(Post.PostedBy) AS PostedBy, Post.SelectedAccountingPeriod AS PostingPeriod, Post.Status AS PostingStatus, 
                         Post.Batch AS FDM_BatchID, CASE WHEN ISNULL(post.StatusDate, '1900-01-01') > ISNULL(Run.RequestedDate, '1900-01-01') THEN post.StatusDate ELSE Run.RequestedDate END AS DateOrder, 
                         CASE post.BackInFDMDate WHEN NULL THEN NULL ELSE MIN(postCP.ProcessedDate) END AS PostInFDMCube
FROM            (SELECT        l.RunProcessLogID, c.ModuleName AS ConfigModuleName, l.Module, l.CreatedDate AS RequestedDate, l.CreatedBy AS RequestedBy, l.StartTime, l.EndTime, l.Status, lstImport.NoRuns, 
                                                    l.SelectedAccountingPeriod AS AccPeriod
                          FROM            Admin.RunProcessLog AS l INNER JOIN
                                                    Admin.RunProcessConfig AS c ON l.fk_RunProcessConfig = c.pk_RunProcessConfig INNER JOIN
                                                        (SELECT        MAX(l.RunProcessLogID) AS RunProcessLogID, l.Module AS ModuleName, COUNT(*) AS NoRuns
                                                          FROM            Admin.RunProcessLog AS l INNER JOIN
                                                                                    Admin.RunProcessConfig AS c ON l.fk_RunProcessConfig = c.pk_RunProcessConfig
                                                          WHERE        (c.ModuleName <> 'AL Import') AND (c.ModuleName <> 'Allocations') AND (c.ModuleName <> 'Agresso Posting') AND (c.UserInitiated = 1)
                                                          GROUP BY l.Module) AS lstImport ON l.RunProcessLogID = lstImport.RunProcessLogID) AS Run LEFT OUTER JOIN
                             (SELECT        IL.FromModule AS Module, MAX(CL.EndTime) AS ProcessedDate
                               FROM            Admin.CubeProcessLog AS CL INNER JOIN
                                                         Admin.IncrementalProcessLog AS IL ON CL.pk_CubeProcessLog = IL.fk_CubeProcessLog
                               WHERE        (CL.ProcessType = 'Incremental') AND (CL.Result = 'Success') AND (IL.FromModule <> 'IntraDay Update') AND (IL.FromModule <> 'IntraDay')
                               GROUP BY CL.pk_CubeProcessLog, IL.FromModule) AS incCP ON Run.Module = incCP.Module AND Run.EndTime < incCP.ProcessedDate LEFT OUTER JOIN
                             (SELECT        EndTime AS ProcessedDate
                               FROM            Admin.CubeProcessLog
                               WHERE        (ProcessType = 'Full') AND (Result = 'Success')) AS fullCP ON Run.EndTime < fullCP.ProcessedDate LEFT OUTER JOIN
                             (SELECT        l.RunProcessLogID, c.ModuleName AS ConfigModuleName, l.Module, l.CreatedDate AS RequestedDate, l.CreatedBy AS RequestedBy, l.StartTime, l.EndTime, l.SelectedAccountingPeriod, 
                                                         lstPost.NoPostings, l.SelectedAccountingPeriod AS AccPeriod, 
                                                         CASE l.status WHEN 'Processing' THEN 'Generating Batch' WHEN 'Failed' THEN 'Failed To Generate' ELSE pstLog.FDM_BatchId END AS Batch, ISNULL(pstLog.StatusDate, l.CreatedDate) 
                                                         AS StatusDate, LOWER(ISNULL(pstLog.[User], l.CreatedBy)) AS PostedBy, ISNULL(pstLog.Status, CASE L.Status WHEN 'Processing' THEN 'Generating' when 'Pending' then 'Queued' ELSE L.status END) AS Status, 
                                                         pstLog.BackInFDMDate
                               FROM            Admin.RunProcessLog AS l INNER JOIN
                                                         Admin.RunProcessConfig AS c ON l.fk_RunProcessConfig = c.pk_RunProcessConfig INNER JOIN
                                                             (SELECT        MAX(l.RunProcessLogID) AS RunProcessLogID, l.Module AS ModuleName, COUNT(*) AS NoPostings
                                                               FROM            Admin.RunProcessLog AS l INNER JOIN
                                                                                         Admin.RunProcessConfig AS c ON l.fk_RunProcessConfig = c.pk_RunProcessConfig
                                                               WHERE        (c.ModuleName = 'Agresso Posting')
                                                               GROUP BY l.Module) AS lstPost ON l.RunProcessLogID = lstPost.RunProcessLogID LEFT OUTER JOIN
                                                             (SELECT DISTINCT RunProcessLogID, FDM_BatchId, Status, StatusDate, ParamStringAccountingPeriod, Module, [User], BackInFDMDate
                                                               FROM            Admin.PostingEngineLog) AS pstLog ON lstPost.RunProcessLogID = pstLog.RunProcessLogID) AS Post ON Run.Module = Post.Module LEFT OUTER JOIN
                             (SELECT        cp.EndTime AS ProcessedDate
                               FROM            Admin.IncrementalProcessLog AS ip INNER JOIN
                                                         Admin.CubeProcessLog AS cp ON ip.fk_CubeProcessLog = cp.pk_CubeProcessLog
                               WHERE        (ip.ProcessingState = 'Success') AND (ip.ObjectID = '4dynamic')
                               UNION
                               SELECT        EndTime AS ProcessedDate
                               FROM            Admin.CubeProcessLog AS CubeProcessLog_1
                               WHERE        (ProcessType = 'Full') AND (Result = 'Success')) AS postCP ON Post.BackInFDMDate < postCP.ProcessedDate
WHERE CASE WHEN ISNULL(post.StatusDate, '1900-01-01') > ISNULL(Run.RequestedDate, '1900-01-01') THEN post.StatusDate 
					ELSE Run.RequestedDate END BETWEEN DATEADD(WEEK,-12,GETDATE()) AND GETDATE() 
GROUP BY Run.Module, Run.RequestedDate, Run.RequestedBy, Run.StartTime, Run.EndTime, Run.Status, Run.NoRuns, Run.AccPeriod, Post.NoPostings, Post.StatusDate, Post.PostedBy, Post.SelectedAccountingPeriod, 
                         Post.Status, Post.Batch
ORDER BY DateOrder DESC
--============================================================================================================================================================
--============================================================================================================================================================

--POSTING ENGINE--

SELECT DENSE_RANK() OVER (PARTITION BY ConfigPackageName ORDER BY StatusDate desc)  AS BatchCount, Batch, RunProcessLogid, ConfigPackageName, Module, ModuleGrouping, GeneratedBy,
GeneratedDate, SelectedAccountingPeriod, StatusDate, PostedBy, PostingPeriod, isnull(BatchStatus, PostingStatus) BatchStatus,PostingStatus,
VoucherNo, InFDM, TransactionCount, ProcessCode, PostInFDMCube, NoPostings, Entity, Client
FROM
(
SELECT case l.status when 'Processing' then 'Generating Batch' when 'Failed' then 'Failed To Generate' else post.FDM_BatchId end Batch, 
l.RunProcessLogID, c.PackageName ConfigPackageName, 
l.Module Module, lower(l.CreatedBy) GeneratedBy, l.StartTime GeneratedDate ,  l.SelectedAccountingPeriod,
isnull(post.statusdate,l.CreatedDate) StatusDate, lower(isnull(post.[User], l.CreatedBy )) PostedBy, l.SelectedAccountingPeriod PostingPeriod,
ISNULL(post.status, case L.Status when 'Processing' then 'Generating' when 'Pending' then 'Queued' else L.status end ) PostingStatus, 
POST.BatchStatus BatchStatus,
CASE WHEN (ISNULL(post.bATCHstatus, case L.Status when 'Processing' then 'Generating' when 'Pending' then 'Queued' else L.status end )) 
	IN ('Processing', 'Generating', 'Queued') then  l.Module + cast(cast( l.StartTime as time) as varchar) else l.module end ModuleGrouping,
post.VoucherNo, post.InFDM, post.TransactionCount, post.[User], case post.ProcessCode WHEN 'N\A' THEN post.ParamStringSubProcess ELSE post.processCode END ProcessCode,
POST.Client, POST.Entity,
CASE post.BackInFDMDate when null then null else min(postCP.ProcessedDate) end PostInFDMCube,lstPost.NoPostings
FROM Admin.RunProcessLog l
INNER JOIN Admin.RunProcessConfig c on l.fk_RunProcessConfig = c.pk_RunProcessConfig
INNER JOIN
	(
	SELECT max(l.RunProcessLogID) RunProcessLogID, l.Module ModuleName,count(*) NoPostings FROM Admin.RunProcessLog l
	INNER JOIN Admin.RunProcessConfig c on l.fk_RunProcessConfig = c.pk_RunProcessConfig
	WHERE c.ModuleName = 'Agresso Posting' 
	GROUP BY l.Module
	) lstPost on l.RunProcessLogID = lstPost.RunProcessLogID
LEFT JOIN Admin.PostingEngineLog  post on l.RunProcessLogID = post.RunProcessLogID
LEFT JOIN 
  (
  SELECT EndTime ProcessedDate from admin.IncrementalProcessLog ip
  INNER JOIN admin.cubeProcessLog cp on ip.fk_CubeProcessLog = cp.pk_CubeProcessLog
  WHERE ProcessingState = 'Success' and ObjectID = '4dynamic'
  UNION 
 SELECT EndTime ProcessedDate FROM admin.CubeProcessLog where ProcessType = 'Full' and Result = 'Success'
 ) postCP ON Post.BackInFDMDate < postCP.ProcessedDate
WHERE 
c.ModuleName = 'Agresso Posting'
GROUP BY 
 post.FDM_BatchId,POST.BatchStatus,
l.RunProcessLogID, c.PackageName, 
l.Module, l.CreatedBy, l.StartTime , l.SelectedAccountingPeriod,
post.statusdate,l.CreatedDate, post.[User], l.SelectedAccountingPeriod, 
post.status, L.status,POST.cLIENT, POST.Entity,ParamStringSubProcess,
post.VoucherNo, post.InFDM, post.TransactionCount, post.[User], post.ProcessCode,
lstPost.NoPostings
) A
ORDER BY StatusDate Desc
--==========================================================================================================================================================================
--==========================================================================================================================================================================

--LAST PROCESSED--

select CONVERT(VARCHAR(10), max(endTime), 103) + ' '  + convert(VARCHAR(8), max(endTime), 14) LastProcessed 
from admin.RunProcessLog
WHERE Module = 'IntraDay Update' and status = 'Success'
--==========================================================================================================================================================================
--==========================================================================================================================================================================

--LAST REFRESH--

SELECT * FROM 
(SELECT max(CP.EndTime) LastTransRefresh from 
Admin.IncrementalProcessLog l
INNER JOIN Admin.CubeProcessLog cp on l.fk_CubeProcessLog = cp.pk_CubeProcessLog
where l.FromModule = 'IntraDay' and l.ObjectType = 'Partition' and l.ProcessingState = 'Success'
and InsertDate > getDate()-5) LR
CROSS JOIN
(
SELECT max(StartTime) LastCheckForTrans FROM Admin.RunProcessLog
where CreatedDate > getDate()-5 and fk_RunProcessConfig=-1 and status = 'Success'
) LC
CROSS JOIN
(
select max(lastAgressoTrans) lastAgressoTrans
 FROM
	(
select max(AgressoLedgerDate) LastAgressoTrans from admin.NonFDMPostingLog
union all
select max(statusdate) from admin.PostingEngineLog where status = 'Success' and StatusDate >= getDate()-5
	) A
) LA
--==================================================================================================================================================================
--==================================================================================================================================================================

--RECONCILIATION--

SELECT  'Intraday - Transaction Count' RecDescription, 'Total Transactions for ' +CONVERT(nvarchar(10), RECdATE, 103)  RecToolTip,
CASE WHEN Agresso = FDMDB Then 'Yes' ELSE 'No' End AgressoToFDMDB,
CASE WHEN Agresso = FDMDB Then 'No Difference' ELSE Format(Agresso - FDMDB,'#,##0') End AgressoToFDMDBToolTip,
CASE WHEN FDMDB = FDMCube Then 'Yes' ELSE 'No' End FDMDBToFDMCube,
CASE WHEN FDMDB = FDMCube Then 'No Difference' ELSE Format(FDMDB - FDMCube,'#,##0') End FDMDBToFDMCubeToolTip
FROM
(
SELECT rec.RecDate,
SUM(CASE WHEN Source = 'Agresso' then TransactionCount else 0 end) as Agresso,
SUM(CASE WHEN Source = 'FDM DB' then TransactionCount else 0 end) as FDMDB,
SUM(CASE WHEN Source = 'FDM Cube' then TransactionCount else 0 end)as FDMCube
from admin.FDMReconciliation rec
inner join admin.RunProcessLog rp on rec.FK_RunProcessLogID = rp.RunProcessLogID
inner join (select max(FK_RunProcessLogID) FK_RunProcessLogID from admin.FDMReconciliation) lst 
		on rec.FK_RunProcessLogID = lst.FK_RunProcessLogID
inner join (select max(recDate) recDate from admin.FDMReconciliation where fk_runProcessLogID = (select max(FK_RunProcessLogID) FK_RunProcessLogID from admin.FDMReconciliation)) lstdte
		on rec.recDate = lstdte.recDate
GROUP BY rec.recDate
)A
UNION ALL
SELECT 
'Overnight - CurAmount last 3 yrs' RecDescription, 'Cur Amount by Entity, CCY and Account for the last 3 years',
CASE SUM(AggToFDMDB) WHEN 0 THEN 'Yes' else 'No' END AggToFDMDB,
CASE SUM(AggToFDMDB) WHEN 0 THEN 'No Difference' else FORMAT(SUM(Agresso) - SUM(FDMDB),'#,##0.00') END AggToFDMDBToolTip,
CASE SUM(FDMDBToCube) WHEN 0 THEN 'Yes' else 'No' END FDMDBToCube,
CASE SUM(FDMDBToCube) WHEN 0 THEN 'No Difference' else FORMAT(SUM(FDMDB) - SUM(FDMCube),'#,##0.00') END FDMDBToCubeToolTip
from
(
SELECT  
Client, Entity, Currency, Account,
SUM(CASE WHEN Source = 'Agresso' then round(CurAmount,2) else 0 end) as Agresso,
SUM(CASE WHEN Source = 'FDM DB' then round(CurAmount,2) else 0 end) as FDMDB,
SUM(CASE WHEN Source = 'FDM Cube' then round(CurAmount,2) else 0 end)as FDMCube,
CASE WHEN SUM(CASE WHEN Source = 'Agresso' then round(CurAmount,2) else 0 end) - 
	SUM(CASE WHEN Source = 'FDM DB' then round(CurAmount,2) else 0 end) NOT between -1 and 1 THEN 1 else 0 END AggToFDMDB,
CASE WHEN SUM(CASE WHEN Source = 'FDM DB' then round(CurAmount,2) else 0 end) - 
	SUM(CASE WHEN Source = 'FDM Cube' then round(CurAmount,2) else 0 end) NOT between -1 and 1 THEN 1 else 0 END FDMDBToCube
from admin.FDMReconciliationOvernight rec where Entity <> 'SGSY'
group by Client, Entity, Currency, Account
) a
--===========================================================================================================================================================================================
--===========================================================================================================================================================================================

--NONFDMJOURNALS--

SELECT top 30 VoucherNo, VoucherType, lower(Username) UserName, TransactionCount, AccountingPeriod, AgressoLedgerDate, FDMDate InFDM
FROM Admin.NonFDMPostingLog
WHERE AgressoLedgerDate > getDate()-5
ORDER BY AgressoLedgerDate Desc
--===========================================================================================================================================================================================
--===========================================================================================================================================================================================

--CUBE PROCESS INTRADAY STATUS

SELECT	DISTINCT 'Previous Run' AS  RunInfo, 
			CASE WHEN [FromModule] IN ('Intraday Update','IntraDay','UW Patterns') THEN 'Agresso Transactions' ELSE ISNULL(FromModule,'None') END AS Module,
			CAST( ROUND( CAST(DATEDIFF (ss,a.StartTime,a.EndTIme)/60.00 AS VARCHAR(100)),0)   AS VARCHAR(25)) AS IntradayRuntime
	FROM	(
				SELECT	TOP 1 StartTime,
						EndTime FROM admin.RunProcessLog
				WHERE	Module = 'Intraday Update'
				AND		EndTime IS NOT NULL
				ORDER	BY RunProcessLogID DESC
			) a
	LEFT	JOIN admin.CubeProcessLog cp
	ON		ISNULL(cp.EndTime,cp.StartTime) BETWEEN a.StartTime AND ISNULL(a.EndTime,getdate())
	LEFT	JOIN [FDM_PROCESS].[Admin].[IncrementalProcessLog] ip
	ON		pk_CubeProcessLog=fk_CubeProcessLog
	UNION
	SELECT	DISTINCT 'Current Run' AS  RunInfo,
			CASE WHEN [FromModule] IN ('Intraday Update','IntraDay','UW Patterns') THEN 'Agresso Transactions' ELSE ISNULL(FromModule,'None') END AS Module,
			'Running' AS B
	FROM	[FDM_PROCESS].[Admin].[IncrementalProcessLog]
	WHERE	InsertDate <= (SELECT MIN(StartTime)  FROM Admin.CubeProcessLog WHERE StartTime > (SELECT top 1 StartTime FROM admin.RunProcessLog WHERE EndTime is NULL ORDER BY 1 DESC))
	AND		InsertDate >= (SELECT MAX(EndTIme)  FROM Admin.CubeProcessLog WHERE EndTime <= (SELECT top 1 EndTime FROM admin.RunProcessLog WHERE EndTime is NOT NULL ORDER BY 1 DESC))
	UNION
	SELECT	DISTINCT 'Future Run' AS  RunInfo,
			CASE WHEN [FromModule] IN ('Intraday Update','IntraDay','UW Patterns') THEN 'Agresso Transactions' ELSE ISNULL(FromModule,'None') END AS Module,
			'N/A' AS B
	FROM	[FDM_PROCESS].[Admin].[IncrementalProcessLog]
	WHERE	InsertDate > (SELECT MAX(StartTime)  FROM Admin.CubeProcessLog)
--==============================================================================================================================================================================================================
--==============================================================================================================================================================================================================

--QMA

SELECT      TOP 2 'QMA Refresh' As QMA,
            CAST (opers.[start_time] AS datetime)AS [start_time],
            CAST (opers.[end_time] AS datetime) AS [end_time],
            RIGHT('0'+CONVERT(VARCHAR(5),DateDiff(s, opers.[start_time], ISNULL(opers.[end_time],GETDATE()))/3600),2) +':'+
            RIGHT('0'+CONVERT(VARCHAR(5),DateDiff(s, opers.[start_time], ISNULL(opers.[end_time],GETDATE()))%3600/60),2) +':'+
            RIGHT('0'+CONVERT(VARCHAR(5),DateDiff(s, opers.[start_time], ISNULL(opers.[end_time],GETDATE()))%60),2) AS RunTime ,
            CASE WHEN opers.status=7 THEN DATEDIFF(MINUTE,opers.start_time,opers.end_time)
                ELSE NULL END AS RuntimeInMinutes,
            CASE opers.[status]
                WHEN 1 THEN 'Created'
                WHEN 2 THEN 'Running'
                WHEN 3 THEN 'Canceled'
                WHEN 4 THEN 'Failed'
                WHEN 5 THEN 'Pending'
                WHEN 6 THEN 'Ended unexpectedly'
                WHEN 7 THEN 'Succeeded'
                WHEN 8 THEN 'Stopping'
                WHEN 9 THEN 'Completed'
            END AS RunStatus ,
            CASE    WHEN ROW_NUMBER() OVER(PARTITION BY  CAST(opers.[start_time] AS DATE)ORDER BY opers.start_time ASC)=1
                    THEN 'Overnight triggered Run'
                    ELSE 'Manual Run' END AS Runtype
FROM      [SSISDB].[internal].[executions](nolock) execs INNER JOIN [SSISDB].[internal].[operations](nolock) opers
           ON execs.[execution_id]= opers.[operation_id]
WHERE execs.package_name='RRProjFDMDataControl100_RemovingFields.dtsx'
AND CAST(opers.[start_time] as DATE)> GETDATE()-5
ORDER BY start_time DESC
--==============================================================================================================================================================================
--==============================================================================================================================================================================
