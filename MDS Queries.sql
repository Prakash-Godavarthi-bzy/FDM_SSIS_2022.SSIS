SELECT TOP 100 * FROM FDM_PROCESS.Admin.RunProcessLog ORDER BY 1 DESC
SELECT TOP 100 * FROM FDM_PROCESS.Admin.RunProcessLog WHERE Module = 'Overnight' ORDER BY 1 DESC
SELECT TOP 100 * FROM FDM_PROCESS.Admin.RunProcessLog WHERE fk_RunProcessConfig = 8 ORDER BY 1 DESC -- 581677
SELECT TOP 100 * FROM FDM_PROCESS.Admin.RunProcessLog WHERE LastInsertedAgrtid IS NOT NULL ORDER BY 1 DESC
SELECT TOP 100 *,DATEADD(HH,2,StartTime) FROM FDM_PROCESS.Admin.RunProcessLog WHERE EndTime IS NULL ORDER BY 1 DESC

SELECT * FROM FDM_DB.dbo.DimTrifocusTree (NOLOCK) -- 1871

SELECT * FROM SSISDB.internal.environment_variables WHERE [name] LIKE '%MDS%'
SELECT * FROM SSISDB.internal.environment_variables WHERE environment_id = 2
SELECT * FROM SSISDB.internal.environments
SELECT * FROM SSISDB.[internal].[environment_references]
SELECT * FROM SSISDB.[internal].[environment_permissions]
SELECT * FROM SSISDB.[internal].[projects]
SELECT * FROM SSISDB.[internal].[object_parameters] WHERE project_id = 2 and parameter_name like '%mds%' ORDER BY project_version_lsn DESC
--SELECT * FROM SSISDB.
--SELECT * FROM SSISDB.
--SELECT * FROM SSISDB.
--SELECT * FROM SSISDB.


SELECT * FROM staging_agresso.FDMOutput.FDMQueries WHERE FDMProcess = 'RITC Test' -- 373
SELECT * FROM staging_agresso.FDMOutput.FDMQueries WHERE FDMProcess = 'RITC Dev' -- 373

SELECT TOP 100 * FROM FDM_PROCESS.Admin.RunProcessLog ORDER BY 1 DESC
	

	--DBS-c8p-BeazleyMDS-UAT,1497
	
	SELECT * FROM FDM_DB.dbo.FactFDMExternal_Current WHERE fk_AccountingPeriod <=202006

	/*******************************************************************************/
	select [fk_AccountingPeriod],
		[fk_TransactionCurrency],
		[FXRate] into #fx
		from dbo.[FactFXRate]
		where fk_FXRate = 2
		and fk_RateScenario = 4
		and fk_ReportingCurrency = 2
		and fk_TransactionCurrency in ('GBP', 'EUR', 'USD', 'CAD')
		and fk_AccountingPeriod between '201812' and left(convert(varchar, getdate(), 112), 6)
		and right(fk_AccountingPeriod, 2) in ('03', '06', '09', '12')



		select sum(t.cur_amount) AS Premium--,t.RunProcessLogID
		--sum(t.cur_amount/ fx.FXRate) Premium
		from dbo.vw_FactFDMExternal t--fdm.FactFDMExternal_History t
		JOIN dbo.[DimAccount] acc on (acc.pk_Account = t.fk_Account)    
		LEFT JOIN dbo.DimRIPolicy ri on (ri.pk_RIPolicy = t.fk_RIPolicy)
		LEFT JOIN dbo.DimEntity en ON (en.pk_Entity = t.fk_Entity)
		--left join #fx fx on
		--(
		--fx.fk_AccountingPeriod = '202009'
		--and fx.fk_TransactionCurrency = t.currency
		--)
			WHERE
			acc.AccountCode = 'RI00001'
			and ri.RIAdjustment in ('RISPD', 'Reinsts')
			and RIPolicyNumber = 'R0895A20'
			and en.EntityCode = '623'
			and t.fk_AccountingPeriod <= '202006'
			--AND t.RunProcessLogID != 581677
			
			--GROUP BY t.cur_amount--,t.RunProcessLogID