USE [master]
GO
CREATE LOGIN [BFL\App.FinanceDataMartCube.GLReporting.RO.TST] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
GO
USE [FDM_DB]
GO
CREATE USER [BFL\App.FinanceDataMartCube.GLReporting.RO.TST] FOR LOGIN [BFL\App.FinanceDataMartCube.GLReporting.RO.TST]
GO
USE [FDM_DB]
GO
ALTER ROLE [db_datareader] ADD MEMBER [BFL\App.FinanceDataMartCube.GLReporting.RO.TST]
GO
USE [FDM_PROCESS]
GO
CREATE USER [BFL\App.FinanceDataMartCube.GLReporting.RO.TST] FOR LOGIN [BFL\App.FinanceDataMartCube.GLReporting.RO.TST]
GO
USE [FDM_PROCESS]
GO
ALTER ROLE [db_datareader] ADD MEMBER [BFL\App.FinanceDataMartCube.GLReporting.RO.TST]
GO
USE [msdb]
GO
CREATE USER [BFL\App.FinanceDataMartCube.GLReporting.RO.TST] FOR LOGIN [BFL\App.FinanceDataMartCube.GLReporting.RO.TST]
GO
USE [msdb]
GO
ALTER ROLE [db_datareader] ADD MEMBER [BFL\App.FinanceDataMartCube.GLReporting.RO.TST]
GO
USE [staging_agresso]
GO
CREATE USER [BFL\App.FinanceDataMartCube.GLReporting.RO.TST] FOR LOGIN [BFL\App.FinanceDataMartCube.GLReporting.RO.TST]
GO
USE [staging_agresso]
GO
ALTER ROLE [db_datareader] ADD MEMBER [BFL\App.FinanceDataMartCube.GLReporting.RO.TST]
GO
