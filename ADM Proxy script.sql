	-- DEV
	USE FDM_DB;
	IF EXISTS (SELECT * FROM sys.database_principals where (type='S' or type = 'U') AND [name] = 'PXY_GrpActrRes')
		DROP USER [PXY_GrpActrRes]

	CREATE USER [PXY_GrpActrRes] FOR LOGIN [BFL\PXY_GrpActrRes_DEV] WITH DEFAULT_SCHEMA=[dbo]	

	-- SYS
	USE FDM_DB;
	IF EXISTS (SELECT * FROM sys.database_principals where (type='S' or type = 'U') AND [name] = 'PXY_GrpActrRes')
		DROP USER [PXY_GrpActrRes]

	CREATE USER [PXY_GrpActrRes] FOR LOGIN [BFL\PXY_GrpActrRes_SYS] WITH DEFAULT_SCHEMA=[dbo]	
	

	-- UAT
	USE FDM_DB;
	IF EXISTS (SELECT * FROM sys.database_principals where (type='S' or type = 'U') AND [name] = 'PXY_GrpActrRes')
		DROP USER [PXY_GrpActrRes]

	CREATE USER [PXY_GrpActrRes] FOR LOGIN [BFL\PXY_GrpActrRes_UAT] WITH DEFAULT_SCHEMA=[dbo]