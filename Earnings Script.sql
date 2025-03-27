SELECT * FROM dbo.DimEarnings WHERE pk_DimEarnings = 901059
SELECT * FROM dbo.DimEarnings WHERE InceptionDate = '2023-12-01'AND ExpiryDate = '2023-12-02' 
   AND PolicyYOA = '2024' AND PolicyType = 'Policy'

   SELECT * FROM dbo.DimEarnings WHERE InceptionDate = '2023-04-18'AND ExpiryDate = '2024-04-17' 
   AND PolicyYOA = '2024' AND PolicyType = 'Policy'

   
   SELECT * FROM dbo.DimEarnings WHERE pk_DimEarnings IN (901059,904085,904122)

   SELECT * FROM dbo.FactFDM (NOLOCK) WHERE fk_DimEarnings IN (901059)
   SELECT * FROM dbo.FactFDM (NOLOCK) WHERE fk_DimEarnings IN (904085)
   SELECT * FROM dbo.FactFDM (NOLOCK) WHERE fk_DimEarnings IN (904122)
   ------------------------------------------------

   SELECT	 DISTINCT
		  CAST( ISNULL(F.[voucher_date],'1900-01-01') AS DATE) AS  [InceptionDate]
		, CAST( ISNULL(F.[trans_date],'1900-01-01') AS DATE) AS [ExpiryDate]
		, LTRIM(RTRIM(F.[Dim_4])) AS [YOA]
		, LTRIM(RTRIM(F.[Dim_1])) AS [Trifocus]
		, ISNULL(LTRIM(RTRIM(R2.[dim_value])),'XYXYXYXYXY') AS [Section]
		, CAST( CASE WHEN R3.[rel_value] IN ('B','L') THEN 'Binder' ELSE 'Policy' END AS NVARCHAR(255)) AS [PolicyType]
		, CASE WHEN E.[UsPolicyRef] IS NOT NULL THEN 1 ELSE 0 END AS [USSection]
	FROM		staging_agresso.[dbo].[agltransact] F
	LEFT JOIN	staging_agresso.[dbo].[agldimvalue] R2
				ON R2.[client] IN (SELECT DISTINCT [client]
	  FROM [staging_agresso].[dbo].[AMCCutoverConfig]) AND R2.[attribute_id] = 'ZZ05' AND LTRIM(RTRIM(R2.[dim_value])) = LTRIM(RTRIM(F.[dim_5]))
	LEFT JOIN	staging_agresso.[dbo].[aglrelvalue] R3
				ON R2.[dim_value] = R3.[att_value] AND R2.[client] = R3.[client] AND R3.[rel_attr_id] = 'ZZ21'
	LEFT JOIN	staging_agresso.[dbo].[EurobaseUSPolicyExclusion] E ON E.[UsPolicyRef] = LEFT(ISNULL(R2.[dim_value],-1),6)
	ORDER BY [Section], [Trifocus]

	------------------------------------------------------------

		SELECT 
		CAST(case when r3.rel_value in ('B','L') then 'Binder' else 'Policy' end
		 AS Nvarchar(255)) AS PolicyType 	, section = r2.dim_value
		 , mop = CAST(isnull(r3.rel_value, 'NOMOP')AS  Nvarchar(255))
		 , CAST( CASE WHEN  E.[UsPolicyRef] IS NOT NULL THEN 1 ELSE 0 END AS [smallint]) [USSection]
		  FROM
				staging_agresso.dbo.agldimvalue r2
				LEFT OUTER JOIN staging_agresso.dbo.aglrelvalue r3
				on r2.dim_value = r3.att_value and r2.client = r3.client AND r3.rel_attr_id = 'ZZ21'
		LEFT JOIN	[staging_agresso].[dbo].[EurobaseUSPolicyExclusion] E ON E.[UsPolicyRef] = LEFT(ISNULL(R2.[dim_value],-1),6)
			WHERE r2.client = (SELECT DISTINCT [client]
		  FROM [staging_agresso].[dbo].[AMCCutoverConfig])	AND r2.attribute_id = 'ZZ05'

		  SELECT TOP 100 * FROM FDM_DB.dbo.FactFDM(NOLOCK) WHERE fk_DimEarnings = -1 AND insert_date > DATEADD(YY,-1,GETDATE())

			SELECT * FROM dbo.DimEarnings WHERE InceptionDate = '2023-02-20'AND ExpiryDate = '2023-02-22' 
			AND PolicyYOA = '2022' AND PolicyType = 'Policy'

-----------------------------------------------------------------------------------------------
	
SELECT  [account]    ,[amount]       ,client = Ltrim(Rtrim(UPPER(a.[client])))       ,[cur_amount]       ,[currency] = ltrim(rtrim([currency]))       ,[description]      
    ,dim_1 =  ltrim(rtrim(UPPER([dim_1])))       ,[dim_2]      
    ,[dim_3]= ltrim(rtrim(UPPER([dim_3])))
    ,ISNULL(CASE WHEN DC.ClientName like '%Budget%' or DC.ClientName like '%Forecast%' THEN ltrim(rtrim(UPPER([dim_3]))) ELSE ltrim(rtrim(UPPER(CE.EntityCode))) END,'') AS S_EntityCode	
    ,CASE WHEN LTRIM(RTRIM([dim_4])) = '' THEN '-1' ELSE [dim_4] END AS dim_4
     ,[YOA] =
    CASE
    WHEN Isnumeric([dim_4])=1 THEN [dim_4]
    WHEN [dim_4]='CALX' THEN 9999
    WHEN [dim_4]='NOYOA' THEN 9998
    WHEN [dim_4]='OLD' THEN 9997
    ELSE -1
    END
         ,[dim_5]       ,[dim_6]
         ,[dim_7]
		 ,CASE WHEN LEN(LTRIM(RTRIM(CE1.EntityCode))) >2 THEN ltrim(rtrim(UPPER(CE1.EntityCode))) ELSE '' END AS TargetEntity
         --,CE1.EntityCode AS TargetEntity
         ,[ext_inv_ref]       ,[ext_ref]       ,[fiscal_year]       ,[last_update]       ,
		 [line_no]       ,[number_1]       ,[order_id]       ,[period]       ,[sequence_no]       ,
		 [status]       ,[tax_code]       ,[tax_system]       ,[trans_date]       ,[trans_id]       ,[update_flag]       ,
		 user_id = Upper([user_id])       ,[value_1]       ,[value_2]       ,[value_3]       ,[voucher_date]       ,[voucher_no]       ,
		 [voucher_type] = ltrim(rtrim(UPPER([voucher_type])))       ,
		 [agrtid] ,LastUpdateDateForTime = Cast([last_update] AS TIME), [apar_id], [apar_type],IsNumeric( [account]) AS AccountType
         ,CombinationID
      FROM [dbo].[agltransact] a
      LEFT JOIN (SELECT CAST(clientCode as Varchar(25)) as Client
                      ,    EntityCode
                   FROM FDM_DB.DBO.[vw_ClientScenarioEntityMapping]
                  WHERE ScenarioCode IN ('BP') and ClientCode!='BP') CE
                  ON a.client = CE.Client
      
      LEFT JOIN (SELECT CAST(clientCode as Varchar(25)) as Client
                      ,    EntityCode
                   FROM FDM_DB.DBO.[vw_ClientScenarioEntityMapping]
                  WHERE ScenarioCode IN ('BP') and ClientCode!='BP') CE1
                  ON a.dim_7 = CE1.Client
	  LEFT JOIN FDM_DB.DBO.DimClient DC
	  on a.client= DC.ClientCode
       JOIN FDM_DB.DBO.DimAllocationCombinations c
      ON LTRIM(RTRIM(Account))= RTRIM(LTRIM(AccountCode))
      AND RTRIM(LTRIM(ProcessCode)) =LTRIM(RTRIM(Voucher_Type))
      AND RTRIM(LTRIM(TriFocusCode)) = LTRIM(RTRIM(a.Dim_1))
      --AND RTRIM(LTRIM(c.[EntityCode])) = ISNULL(LTRIM(RTRIM(CE.EntityCode)), LTRIM(RTRIM(a.Dim_3)))
	  AND RTRIM(LTRIM(c.[EntityCode])) = ISNULL(CASE WHEN DC.ClientName like '%Budget%' or DC.ClientName like '%Forecast%' THEN ltrim(rtrim(UPPER([dim_3]))) ELSE ltrim(rtrim(UPPER(CE.EntityCode))) END,'')
      AND LTRIM(RTRIM(a.Dim_2)) = RTRIM(LTRIM([ProjectCode]))
      AND CASE WHEN LEN(LTRIM(RTRIM(DIM_5))) >7 THEN '' ELSE  LTRIM(RTRIM(a.Dim_5)) END = RTRIM(LTRIM([LocationCode]))
      AND RTRIM(LTRIM([YOA])) = CASE
            WHEN Isnumeric([dim_4])=1 THEN [dim_4]
            WHEN [dim_4]='CALX' THEN '9999'
            WHEN [dim_4]='NOYOA' THEN '9998'
            WHEN [dim_4]='OLD' THEN '9997'
            ELSE '-1'
            END
      AND RTRIM(LTRIM(TargetEntity)) = CASE WHEN LEN(ltrim(rtrim(UPPER(CE1.EntityCode)))) >2 THEN CE1.EntityCode ELSE '' END
	  WHERE A.agrtid IN (514467136,514468546,514471368,514472287,514467137)
	  
	  SELECT TOP 1 * FROM FDM_DB.dbo.FactFDM WHERE bk_TransactionID IN (514467136,514468546,514471368,514472287,514467137)
	  SELECT TOP 1 * FROM FDM_DB.dbo.FactFDM WHERE bk_TransactionID IN (514467471,514473028,514465556,514467465)
	  SELECT TOP 1 * FROM FDM_DB.dbo.FactFDM WHERE bk_TransactionID IN (514466905,514482360,514468061,514472360,514481921)

	  SELECT TOP 100 * FROM FDM_DB.dbo.FactFDM WHERE fk_DimEarnings != -1 AND insert_date > DATEADD(YY,-1,GETDATE())
	  SELECT * FROM dbo.DimEarnings WHERE pk_DimEarnings = 901059

--WITH CTE AS (
--SELECT 
--		PolicyType = case when r3.rel_value in ('B','L') then 'Binder' else 'Policy' end
--		, mop =LTRIM(RTRIM( isnull(r3.rel_value, 'NOMOP')))
--		,UWPlatform = LTRIM(RTRIM( r4.rel_value))
--		, section = LTRIM(RTRIM(r2.dim_value))
--		, policy = LTRIM(RTRIM(case when left(r2.dim_value,1) in ('W','V') then ---US
--						case when charindex('-',r2.dim_value,0) > 0 then
--							left(r2.dim_value,charindex('-',r2.dim_value)-1)
--					else
--						r2.dim_value
--					end
--					else
--						left(r2.dim_value,8) --Eurobase
--					end))
--	FROM
--		staging_agresso.dbo.agldimvalue r2
--		LEFT OUTER JOIN staging_agresso.dbo.aglrelvalue r3
--		on r2.dim_value = r3.att_value and r2.client = r3.client AND r3.rel_attr_id = 'ZZ21'
--		LEFT OUTER JOIN staging_agresso.dbo.aglrelvalue r4
--		on r2.dim_value = r4.att_value and r2.client = r4.client AND r4.rel_attr_id = 'ZZA9'
--	WHERE r2.client = (SELECT top 1  [client]
--	FROM [staging_agresso].[dbo].[AMCCutoverConfig])
--	AND r2.attribute_id = 'ZZ05'
--	--AND r4.rel_value IS NOT NULL
--	)
--	UPDATE FDM_DB..DimPolicySectionV2
--	SET UWPlatform = c.UWPlatform
--	FROM FDM_DB..DimPolicySectionV2 p
--	JOIN CTE c ON p.AgressoSectionReference = section
--	WHERE c.UWPlatform IS NOT NULL AND ISNULL(p.UWPlatform,'')<> ISNULL(c.UWPlatform,'')

--	--SELECT * FROM staging_agresso.dbo.agldimvalue r2


--UPDATE s
--SET  USPolicy = t.IsUSTrifocus
--FROM fdm_db.dbo.DimPolicySectionV2  s
--JOIN FDM_DB..DimTrifocus t ON t.TrifocusCode = s.TrifocusCode
--WHERE USPolicy IS NULL OR s.USPolicy <> t.IsUSTrifocus

	SELECT * FROm FDM_DB..DimTrifocus WHERE TrifocusCode = '696'
	SELECT * FROm FDM_DB..DimTrifocus WHERE TrifocusCode = '722'
	SELECT * FROm FDM_DB..DimTrifocus WHERE TrifocusCode = '688'

		SELECT * FROM TDM.staging.ActuarialReservingData