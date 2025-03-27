select * from
(Select 
PK_LEVEL1,DESC_LEVEL1,PK_LEVEL2,DESC_LEVEL2,PK_LEVEL3,DESC_LEVEL3,PK_LEVEL4,DESC_LEVEL4,PK_LEVEL5,DESC_LEVEL5,PK_LEVEL6,DESC_LEVEL6,
PK_LEVEL7,DESC_LEVEL7,N.pkDimAccountTree PK_LEVEL8,N.Description DESC_LEVEL8 from
(Select 
PK_LEVEL1,DESC_LEVEL1,PK_LEVEL2,DESC_LEVEL2,PK_LEVEL3,DESC_LEVEL3,PK_LEVEL4,DESC_LEVEL4,PK_LEVEL5,DESC_LEVEL5,PK_LEVEL6,DESC_LEVEL6,
L.pkDimAccountTree PK_LEVEL7,L.Description DESC_LEVEL7 from
(SELECT PK_LEVEL1,DESC_LEVEL1,PK_LEVEL2,DESC_LEVEL2,PK_LEVEL3,DESC_LEVEL3,PK_LEVEL4,DESC_LEVEL4,PK_LEVEL5,DESC_LEVEL5,j.pkDimAccountTree PK_LEVEL6,j.Description DESC_LEVEL6 FROM
(SELECT PK_LEVEL1,DESC_LEVEL1,PK_LEVEL2,DESC_LEVEL2,PK_LEVEL3,DESC_LEVEL3,PK_LEVEL4,DESC_LEVEL4,h.pkDimAccountTree PK_LEVEL5,h.Description DESC_LEVEL5 FROM
(SELECT PK_LEVEL1,DESC_LEVEL1,PK_LEVEL2,DESC_LEVEL2,PK_LEVEL3,DESC_LEVEL3,f.pkDimAccountTree PK_LEVEL4,f.Description DESC_LEVEL4  FROM
(SELECT PK_LEVEL1,DESC_LEVEL1,PK_LEVEL2,DESC_LEVEL2,pkDimAccountTree PK_LEVEL3,Description DESC_LEVEL3 FROM 
(select PK_LEVEL1,DESC_LEVEL1,pkDimAccountTree AS PK_LEVEL2,Description AS DESC_LEVEL2 from (
select pkDimAccountTree AS PK_LEVEL1,Description AS DESC_LEVEL1 from DimAccountTree
where pkDimAccountTree in('71_L102_L211','71_L102_L212')) A
left join DimAccountTree B ON A.PK_LEVEL1=B.pkDimAccountTreeParent)C
left JOIN DimAccountTree D ON C.PK_LEVEL2=D.pkDimAccountTreeParent)E
Left JOIN DimAccountTree F ON E.PK_LEVEL3=F.pkDimAccountTreeParent)G
left JOIN DimAccountTree H ON G.PK_LEVEL4=H.pkDimAccountTreeParent)I
left JOIN DimAccountTree J ON I.PK_LEVEL5=J.pkDimAccountTreeParent)K
left JOIN DimAccountTree L ON K.PK_LEVEL6=L.pkDimAccountTreeParent)M
left JOIN DimAccountTree N ON M.PK_LEVEL6=N.pkDimAccountTreeParent)O

SELECT * FROM DimAccountTree WHERE pkDimAccountTree in('71_L102_L211','71_L102_L212')
SELECT * FROM DimAccountTree WHERE pkDimAccountTreeParent in('71_L102_L211','71_L102_L212')
SELECT * FROM DimAccountTree WHERE pkDimAccountTreeParent in('71_L102_L211_L310')
SELECT * FROM DimAccountTree WHERE pkDimAccountTreeParent in('71_L102_L211_L310_L413')
SELECT * FROM DimAccountTree WHERE pkDimAccountTreeParent in('71_L102_L211_L310_L413_L513')
SELECT * FROM briAccountAccountTree WHERE pkDimAccountTree LIKE '71_%'
SELECT * FROM briAccountAccountTree WHERE pk_Account LIKE '77050%'
SELECT * FROM DimAccount WHERE AccountCode = '77050'

	--SP_Depends 'briAccountAccountTree'


	WITH CTETREE AS
		(
		SELECT *, 1 AS Levels FROM DimAccountTree WHERE pkDimAccountTreeParent = '71_L102'--'71_L102_L211'
		UNION ALL
		SELECT A.*,Levels +1 AS Levels FROM DimAccountTree A
		 INNER JOIN CTETREE B
		    ON A.pkDimAccountTreeParent = B.pkDimAccountTree
		 --WHERE pkDimAccountTreeParent = '71_L102'
		) 

		--SELECT * FROM CTETREE ORDER BY pkDimAccountTree--pkDimAccountTreeParent
		SELECT TOut1.pkDimAccountTreeParent,[1] AS Level1,[2] AS Level2,[3] AS Level3,[4] AS Level4,[5] AS Level5,[6]  AS Level6
		  FROM
			(
			SELECT * FROM CTETREE
			) AS T
			PIVOT 
			(
				MAX(pkDimAccountTree) FOR Levels IN ([1],[2],[3],[4],[5],[6])
			) AS TOut1
			--PIVOT 
			--(
			--	MAX([Description]) FOR Levels IN ([1],[2],[3],[4],[5],[6])
			--) AS TOut2
			--ORDER BY TOut1.pkDimAccountTreeParent