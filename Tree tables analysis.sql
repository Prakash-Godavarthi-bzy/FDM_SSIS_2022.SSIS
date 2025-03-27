----------------------Entity-------------------------------------

SELECT        pkDimEntityTree, pk_Entity, pk_AccountingPeriod
FROM            briEntityEntityTree -- 539

SELECT        pkDimEntityTree, Description, pkDimEntityTreeParent, SortOrder
FROM            DimEntityTree -- 716

SELECT        pk_Entity, EntityCode, EntityName, pk_EntityParent, Status, FunctionalCurrency, ExcludeFromFXCalcs, TargetEntityIdentifier, CASE WHEN Platform = 'EIC' THEN 'BID' ELSE Platform END AS Platform
FROM            DimEntity -- 320


SELECT        A.pkDimEntityTree, pk_Entity, pk_AccountingPeriod
FROM            briEntityEntityTree A
LEFT JOIN DimEntityTree B
  ON A.pkDimEntityTree = B.pkDimEntityTree
WHERE B.pkDimEntityTree IS NULL


SELECT        A.pkDimEntityTree, A.pk_Entity, pk_AccountingPeriod
FROM            briEntityEntityTree A
LEFT JOIN DimEntity B
  ON A.pk_Entity = B.pk_Entity
WHERE B.pk_Entity IS NULL


SELECT        A.pkDimEntityTree, A.pk_Entity, pk_AccountingPeriod
FROM            briEntityEntityTree A
LEFT JOIN DimEntityTree B
  ON A.pkDimEntityTree = B.pkDimEntityTree
LEFT JOIN DimEntity C
  ON A.pk_Entity = C.pk_Entity
WHERE B.pkDimEntityTree IS NULL OR C.pk_Entity IS NULL
SELECT * FROM DimProductTree WHERE pkDimProductTree = '40_ZZ02_AFAT'
----------------------Product-------------------------------------
SELECT        A.pkDimProductTree, pk_Product, pk_AccountingPeriod
FROM            briProductProductTree A
INNER JOIN DimProductTree B
  ON A.pkDimProductTree = B.pkDimProductTree
WHERE B.pkDimProductTree IS NULL


SELECT        A.pkDimProductTree, A.pk_Product, pk_AccountingPeriod
FROM            briProductProductTree A
LEFT JOIN DimProduct B
  ON A.pk_Product = B.pk_Product
WHERE B.pk_Product IS NULL


SELECT        A.pkDimProductTree, A.pk_Product, pk_AccountingPeriod
FROM            briProductProductTree A
LEFT JOIN DimProductTree B
  ON A.pkDimProductTree = B.pkDimProductTree
LEFT JOIN DimProduct C
  ON A.pk_Product = C.pk_Product
WHERE B.pkDimProductTree IS NULL OR C.pk_Product IS NULL

----------------------Account-------------------------------------

SELECT        A.pkDimAccountTree, pk_Account, pk_AccountingPeriod
FROM            briAccountAccountTree A
LEFT JOIN DimAccountTree B
  ON A.pkDimAccountTree = B.pkDimAccountTree
WHERE B.pkDimAccountTree IS NULL


SELECT        A.pkDimAccountTree, A.pk_Account, pk_AccountingPeriod
FROM            briAccountAccountTree A
LEFT JOIN DimAccount B
  ON A.pk_Account = B.pk_Account
WHERE B.pk_Account IS NULL


SELECT        A.pkDimAccountTree, A.pk_Account, pk_AccountingPeriod
FROM            briAccountAccountTree A
LEFT JOIN DimAccountTree B
  ON A.pkDimAccountTree = B.pkDimAccountTree
LEFT JOIN DimAccount C
  ON A.pk_Account = C.pk_Account
WHERE B.pkDimAccountTree IS NULL OR C.pk_Account IS NULL

----------------------TriFocus-------------------------------------

SELECT        A.pkDimTrifocusTree, pk_Trifocus, pk_AccountingPeriod
FROM            briTrifocusTrifocusTree A
LEFT JOIN DimTrifocusTree B
  ON A.pkDimTrifocusTree = B.pkDimTrifocusTree
WHERE B.pkDimTrifocusTree IS NULL


SELECT        A.pkDimTrifocusTree, A.pk_Trifocus, pk_AccountingPeriod
FROM            briTrifocusTrifocusTree A
LEFT JOIN DimTrifocus B
  ON A.pk_Trifocus = B.pk_Trifocus
WHERE B.pk_Trifocus IS NULL


SELECT        A.pkDimTrifocusTree, A.pk_Trifocus, pk_AccountingPeriod
FROM            briTrifocusTrifocusTree A
LEFT JOIN DimTrifocusTree B
  ON A.pkDimTrifocusTree = B.pkDimTrifocusTree
LEFT JOIN DimTrifocus C
  ON A.pk_Trifocus = C.pk_Trifocus
WHERE B.pkDimTrifocusTree IS NULL OR C.pk_Trifocus IS NULL

-----------------------------------------------------------------

	--------------------------------------------------------------

	select * from staging_agresso.dbo.acrtreesetup(nolock) WHERE att_1_col = 'dim_2'-- AND att_agrid = 40



select * from staging_agresso.dbo.acrtrees 
 WHERE client = 'TB' 
   AND att_agrid IN (40)
   and len(dim_a)>0 and len(cat_2) = 0 
 ORDER BY last_update DESC


select TOP 100 * from staging_agresso.dbo.agldimvalue(nolock)
WHERE Client = 'TB' 
 AND attribute_id = 'ZZ45'
 AND dim_value IN('H','F')
 ORDER BY last_update DESC