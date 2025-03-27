	SELECT TOP 100 * FROM FDM_PROCESS.Admin.RunProcessLog ORDER BY 1 DESC

	SELECT pkDimTrifocusTree,COUNT(1)
	FROM staging_agresso.dbo.TrifocusTreeStage
	WHERE [Description] IS NOT NULL
	GROUP BY pkDimTrifocusTree
	HAVING COUNT(1) > 1

	
	SELECT * FROM acrtrees t WHERE (client = 'TB' OR client = '*') AND  len(t.cat_2) = 0 and t.dim_a!='' ORDER BY last_update DESC
	SELECT * FROM acrtreesetup s WHERE  s.att_agrid = 25
	SELECT * FROM dbo.agldimvalue vc WHERE vc.client = 'TB' AND vc.attribute_id = 'C1' AND dim_value = 'TRI00003'

	--25_C1_TRI00003
--SELECT * FROM 



    SELECT * FROM FDM_DB.dbo.DimTrifocusTree WHERE RTRIM(LTRIM(pkDimTrifocusTree)) NOT IN (SELECT RTRIM(LTRIM(pkDimTrifocusTree)) FROM staging_agresso.dbo.TrifocusTreeStage)
	SELECT * FROM staging_agresso.dbo.TrifocusTreeStage WHERE RTRIM(LTRIM(pkDimTrifocusTree)) = '266_266'
	25_25_ZZ
	266_266
    IF @count>=1
        --TRUNCATE TABLE FDM_DB.dbo.DimTrifocusTree

		SELECT * FROM FDM_DB.dbo.DimTrifocusTree

		-----------------------------------------------------
		
	DECLARE @att_agrid as integer = 25 ,@cutoverClient as varchar(5) = 'TB'

	SELECT * from 
	acrtrees t join
	acrtreesetup s on t.att_agrid = s.att_agrid
	WHERE (t.client = @cutoverClient OR t.client ='*') 
	and s.att_agrid = @att_agrid
	and len(t.cat_2) = 0 and len(ltrim(rtrim(att_2_id))) = 0 and t.dim_a!=''
	AND cast(ltrim(rtrim(s.att_1_id)) as nvarchar(255)) = 'C1'
	AND cast(cat_1  as nvarchar(255)) IN ('TRI00003','TRI00001')

	SELECT * FROM dbo.agldimvalue vc WHERE vc.client = 'TB' AND vc.attribute_id = 'C1' AND dim_value = 'TRI00003'

	SELECT * FROM
(
  select distinct
	[pkDimAccountTree]= cast(s.att_agrid as nvarchar(255)) + '_' + cast(ltrim(rtrim(s.att_1_id)) as nvarchar(255)) + '_' + cast(cat_1  as nvarchar(255)) collate SQL_Latin1_General_CP1_CI_AS
	--,[Description] = cast(cat_1  as nvarchar(255)) + ' ' + cast(vc.description as nvarchar(255)) collate SQL_Latin1_General_CP1_CI_AS
	,[pkDimAccountTreeParent] = cast(@att_agrid as nvarchar(25)) + '_' + cast(t.dim_a as nvarchar(255)) + '_' + cast(t.dim_b as nvarchar(255)) + '_' + cast(t.dim_c as nvarchar(255)) + '_' + cast(t.dim_d as nvarchar(255)) + '_' + cast(t.dim_e as nvarchar(255)) + '_' + cast(t.dim_f as nvarchar(255)) + '_' + cast(t.dim_g as nvarchar(255)) + '_' + cast(t.dim_h as nvarchar(255)) + '_' + cast(t.dim_i as nvarchar(255)) + '_' + cast(t.dim_j as nvarchar(255)) + '_' + cast(t.dim_k as nvarchar(255)) + '_' + cast(t.dim_l as nvarchar(255))
from 
	acrtrees t join
	acrtreesetup s on t.att_agrid = s.att_agrid 
	--left outer join
	--dbo.agldimvalue vc on CASE WHEN s.client='*' THEN @cutoverClient ELSE s.client END =vc.client and ltrim(rtrim(vc.attribute_id)) = ltrim(rtrim(s.att_1_id)) and ltrim(rtrim(t.cat_1))=ltrim(rtrim(vc.dim_value)) 

where
	(t.client = @cutoverClient OR t.client ='*') 
--	and 
--cat_1 in (
--select dim_value from agldimvalue
--where
--(client = @cutoverClient OR client ='*')
--and ltrim(rtrim(attribute_id)) = ltrim(rtrim(s.att_1_id))
--and dim_value <>'1'
--) 
and s.att_agrid = @att_agrid
and len(t.cat_2) = 0 and len(ltrim(rtrim(att_2_id))) = 0 and t.dim_a!=''
) AS T
WHERE T.pkDimAccountTree = '25_C1_TRI00003'
