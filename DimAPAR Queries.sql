
	/* Agresso Query: (UKPRDB079)

		select * from agltransact -- 4590 records
		where voucher_type between 'W1' and 'W5'
		and apar_id != ''
		and apar_type = ''
	*/

	SELECT COUNT(1) 
	  FROM dbo.FactFDM (NOLOCK) 
	 WHERE fk_Process IN (333,334,335,336,337)
	   AND ap_ar_id != ''
       and ap_ar_type = '' --1685--1018--2003-- 653-- 4590 (4765)

	SELECT COUNT(1)
	  FROM dbo.FactFDM F (NOLOCK)
	 INNER JOIN dbo.DimTransactionDetailsV1_Current T (NOLOCK)
	    ON F.pk_FactFDM = T.pk_FactFDM
	 WHERE fk_Process IN (333,334,335,336,337)
	   AND F.ap_ar_id != ''
       and T.ap_ar_type = '' --315-- 1098 (1273)

	SELECT COUNT(1)
	  FROM dbo.FactFDM F (NOLOCK)
	 INNER JOIN dbo.DimTransactionDetailsV1_History T (NOLOCK)
	    ON F.pk_FactFDM = T.pk_FactFDM
	 WHERE fk_Process IN (333,334,335,336,337)
	   AND F.ap_ar_id != ''
       and T.ap_ar_type = '' --1370-- 3492 (3492)

	SELECT 1098 + 3492 -- 4590
	SELECT 1273 + 3492 -- 4765

	SELECT * FROM dbo.DimARAP

	
		UPDATE T
		   SET T.ap_ar_type = 'P'
		  FROM dbo.FactFDM F 
		 INNER JOIN dbo.DimTransactionDetailsV1_Current T
			ON F.pk_FactFDM = T.pk_FactFDM
		 WHERE F.fk_Process IN (333,334,335,336,337)
		   AND F.ap_ar_id != ''
		   and F.ap_ar_type = '' -- 1273

		UPDATE T
		   SET T.ap_ar_type = 'P'
		  FROM dbo.FactFDM F 
		 INNER JOIN dbo.DimTransactionDetailsV1_History T
			ON F.pk_FactFDM = T.pk_FactFDM
		 WHERE F.fk_Process IN (333,334,335,336,337)
		   AND F.ap_ar_id != ''
		   and F.ap_ar_type = '' -- 3492
		   
		UPDATE dbo.FactFDM 
		   SET ap_ar_type = 'P'
		 WHERE fk_Process IN (333,334,335,336,337)
		   AND ap_ar_id != ''
		   and ap_ar_type = '' -- 4765	
	

	SELECT * FROM dbo.DimProcess WHERE ProcessCode IN ('W1','W2','W3','W4','W5')
	--SELECT * FROM dbo.DimProcess WHERE ProcessCode LIKE 'W%'

	--SELECT @@Version

	--Microsoft SQL Server 2012 (SP4-GDR) 
	--(KB5021123) - 11.0.7512.11 (X64)   Dec  3 2022 01:19:42   Copyright (c) Microsoft Corporation  
	--Enterprise Edition (64-bit) on Windows NT 6.3 <X64> (Build 9600: ) (Hypervisor) 

		SELECT *  FROM dbo.FactFDM F INNER JOIN dbo.DimTransactionDetailsV1_Current T	ON F.pk_FactFDM = T.pk_FactFDM WHERE F.extref = '00704fb96f3c90011d67161779fc0001' and F.bk_TransactionID = 540032823

[dbo].[DimEntityTree]
		---------------------------------------------------
	
	SELECT TOP 100 *  FROM staging_agresso.dbo.acuheader
	SELECT TOP 100 *  FROM staging_agresso.dbo.asuheader
	SELECT TOP 100 *  FROM staging_agresso.dbo.agldimvalue
	SELECT TOP 100 *  FROM staging_agresso.dbo.agltransact

	SELECT COUNT(1) FROM dbo.FactFDM (NOLOCk)

	SELECT * FROM dbo.DimARAP
	SELECT * FROM dbo.DimEntity WHERE EntityCode = 'USBESI'
	SELECT * FROM dbo.DimEntity WHERE EntityCode LIKE '80%'
	SELECT * FROM staging_agresso.dbo.RISpendAFDBStage WHERE Entity LIKE 'US%'
	SELECT * FROM staging_agresso.dbo.RISpendAFDBStage WHERE [Source] LIKE 'Reinsts%'--_Balancing_items

	SELECT DISTINCT B.EntityCode 
	  FROM FDM_DB.dbo.vw_FactFDMExternal A
	 INNER JOIN dbo.DimEntity B
	    ON A.fk_Entity = B.pk_Entity
	 WHERE A.RunProcessLogID = 725121
	 ORDER BY B.EntityCode

	 SELECT * FROM dbo.DimARAP WHERE ap_ar_id = '20000005'


	 -----------------------------------------------------------------------

	 	SELECT	DISTINCT apar_id, apar_name, apar_type
	FROM staging_agresso.dbo.acuheader

	UNION ALL 

	SELECT	DISTINCT apar_id, apar_name, apar_type
	FROM	staging_agresso.dbo.asuheader

	UNION ALL

	SELECT DISTINCT apar_id, null AS apar_name,apar_type FROM staging_agresso.[dbo].[agltransact]



	SELECT TOP 100 *  FROM staging_agresso.dbo.agldimvalue WHERE [description] LIKE 'S%'

	SELECT DISTINCT apar_id,apar_type FROM staging_agresso.[dbo].[agltransact]

	SELECT * FROM dbo.DimARAP where ap_ar_id in ('S-00002016')
	--SELECT * FROM dbo.DimARAP where ISNULL(ap_ar_name,'') = ''

	SELECT DISTINCT A.ap_ar_id 
	  FROM dbo.FactFDM A (NOLOCK)
	  LEFT JOIN dbo.DimARAP B
	    ON A.ap_ar_id = B.ap_ar_id
	 WHERE B.ap_ar_id IS NULL