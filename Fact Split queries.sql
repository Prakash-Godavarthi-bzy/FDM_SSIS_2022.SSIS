	SELECT
     [ToHost], [TriFocus] TriFocusCode
      ,[YOA]
      ,[Host] Entity
  FROM [FDM_DC].[vFactToHost]
  WHERE [ReviewCycle] = '2023Q4' AND [Host] <> '6050' AND [Host] <> '6107' AND [Host] <> '5623' AND [Host] <> '3623'   
  UNION ALL 
  
  SELECT
     [ToHost], [TriFocus] TriFocusCode
      ,[YOA]
      ,[Host] Entity
  FROM [FDM_DC].[vFactToHost]
  WHERE [ReviewCycle] = '2023Q4' AND [Host] = '3623' AND YOA>= '2024'  --ORDER BY YOA, Entity

  UNION ALL 
  SELECT
     [ToHost], [TriFocus] TriFocusCode
      ,[YOA]
      ,[Host] Entity
  FROM [FDM_DC].[vFactToHost]
  WHERE [ReviewCycle] = '2023Q4' AND [Host] = '3623' AND YOA< '2023'  ORDER BY YOA, Entity

  SELECT * FROM FDM_DB.[FDM_DC].[vFactToHost] WHERE Host = '5623'
  ---------------------------------------------------------------------------
	SELECT B.TrifocusName,C.EntityName,C.EntityCode
		     ,A.* 
		  FROM FDM_DB.dbo.vw_FactFDMExternal A
		 INNER JOIN FDM_DB.dbo.DimTrifocus B
			ON A.fk_TriFocus = B.pk_Trifocus
		 INNER JOIN FDM_DB.dbo.DimEntity C
		    ON A.fk_Entity = C.pk_Entity
		 WHERE RunProcessLogID = 750727
		   AND B.TrifocusGroup = 'BUSA'
		   --AND C.EntityCode = '3623'
  ---------------------------------------------------------------------

  SELECT H.* , S.Syndicate,S.PercentageSplit,TrifocusGroup
   FROM
  (
  SELECT 
     [ToHost], [TriFocus] TriFocusCode
      ,[YOA]
      ,[Host] Entity
	  , B.TrifocusGroup
  FROM [FDM_DC].[vFactToHost] A
  INNER JOIN FDM_DB.dbo.DimTrifocus B
	ON A.[TriFocus] = B.TrifocusCode
  WHERE [ReviewCycle] = '2023Q4' --AND [Host] = '3623' --AND YOA< '2023'  --ORDER BY YOA, Entity
  ) AS H
  INNER JOIN 
  (
   SELECT 
		  [Host] Entity
		  ,[ToSyndicate] PercentageSplit
						 ,[YOA]
						  ,[Entity] Syndicate
	  FROM [FDM_DC].[vFactToSyndicate] 
	  WHERE ReviewCycle = '2023Q4'
	  ) AS S
	  ON H.Entity = S.Entity
	  AND H.YOA = S.YOA
	  --WHERE H.ReviewCycle = '2023Q4'
	  AND S.Syndicate IN ('623','2623')
	ORDER BY H.YOA, H.Entity,H.TrifocusGroup
	