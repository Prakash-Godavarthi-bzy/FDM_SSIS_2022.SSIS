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
		 INTO #tempTrans
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

	  SELECT * FROM #tempTrans
	  -----------------------------------------------

	  SELECT 1 AS pk_LookupEntityAndScenario, CAST(clientCode as Varchar(25)) as Client,	CAST(EntityCode as Varchar(25))  AS dim_3,	EntityCode,	CAST(ScenarioCode as Varchar(25))  ScenarioCode
	FROM FDM_DB..[vw_ClientScenarioEntityMapping]


	SELECT A.*,ISNULL(B.EntityCode,A.S_EntityCode) AS EntityCode,ISNULL(B.ScenarioCode,A.client)  AS ScenarioCode
	  INTO #Temp1
	  FROM #tempTrans A
	  LEFT JOIN FDM_DB..[vw_ClientScenarioEntityMapping] B
	    ON A.client = B.ClientCode
		AND A.S_EntityCode = B.EntityCode

	SELECT * FROM FDM_DB.dbo.DimScenario

	SELECT * FROM #Temp1 A
	 LEFT JOIN FDM_DB.dbo.DimScenario B
	    ON A.ScenarioCode = B.ScenarioCode
		WHERE B.pk_Scenario IS NULL