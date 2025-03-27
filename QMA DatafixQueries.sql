	SELECT * FROM staging_agresso..MDXQueriesForModules WHERE MDXQuery LIKE '%MDX%'
	SELECT TOP 100 * FROM FDM_PROCESS.Admin.RunProcessLog WHERE fk_RunProcessConfig=42 ORDER BY 1 DESC
	SELECT COUNT(*) FROM staging_agresso..StageMDXResults19_LTDYTD_100RemovingFields_201909 WHERE LoadTime>'2021-FEB-11' --913381

	SELECT * FROM staging_agresso..MDXQueriesForModules WHERE Module='RRProjFDMData30'
	SELECT * FROM staging_agresso..MDXQueriesForModules WHERE Module='RRProjFDMData40'

	/*
	
		SELECT * FROM staging_agresso..MDXQueriesForModules WHERE Module='RRProjFDMData30'

	UPDATE staging_agresso..MDXQueriesForModules
	SET MDXQuery='SELECT  {[Measures].[Trans Currency Amount],
					[Measures].[Group Currency Amount],
					[Measures].[Functional Currency Amount                                        
					} ON 0,
	NON EMPTY([Entity].[Entity].[Entity].MEMBERS,
					  [Account].[Account Code].[Account Code].MEMBERS,
					  [Account].[Account Name].[Account Name].MEMBERS,
					  [Cur Transaction Currency].[Tran Curr].[Tran Curr].MEMBERS,
					  [Tri Focus].[Trifocus Code].[Trifocus Code].MEMBERS,                         
					  [Tri Focus].[Tri Focus Name].[Tri Focus Name].MEMBERS,
					  {MDXCombination}
			  ) ON 1  
	FROM [FinanceDataMart]  
	WHERE  (
					[Entity].[Platform].&[SYND],
					[Time Series].[Time Series].&[30],
					[Trifocus Tree].[Trifocus Tree].&[25_25]
					)'
	WHERE Module='RRProjFDMData30'

	SELECT * FROM staging_agresso..MDXQueriesForModules WHERE Module='RRProjFDMData40'

	UPDATE staging_agresso..MDXQueriesForModules
	SET MDXQuery='SELECT  
	{                       
	[Measures].[Trans Currency Amount],
	[Measures].[Group Currency Amount],
	[Measures].[Functional Currency Amount]} ON 0 ,
	NON EMPTY([Entity].[Entity].[Entity].MEMBERS,
					  [Account].[Account Code].[Account Code].MEMBERS,
					  [Account].[Account Name].[Account Name].MEMBERS,
					  [Cur Transaction Currency].[Tran Curr].[Tran Curr].MEMBERS,
					  [Tri Focus].[Trifocus Code].[Trifocus Code].MEMBERS,
					  [Tri Focus].[Tri Focus Name].[Tri Focus Name].MEMBERS
					  ,{MDXCombination} ) ON 1  
	FROM [FinanceDataMart]
	WHERE ( [Entity].[Platform].&[SYND],
					[Time Series].[Time Series].&[40],
					[Trifocus Tree].[Trifocus Tree].&[25_25])'
	WHERE Module='RRProjFDMData40'

	*/