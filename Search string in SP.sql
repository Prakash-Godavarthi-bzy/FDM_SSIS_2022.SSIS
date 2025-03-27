SELECT DISTINCT
       o.name AS Object_Name,
       o.type_desc
FROM sys.sql_modules m
       INNER JOIN
       sys.objects o
         ON m.object_id = o.object_id
WHERE m.definition Like '%vFactToSyndicateCurrent%';
--WHERE m.definition Like '%\[WriteTable_04 RI\]%' ESCAPE '\'

-----------------------------------------------------

	select schema_name(o.schema_id) + '.' + o.name as [table],
       'is used by' as ref,
       schema_name(ref_o.schema_id) + '.' + ref_o.name as [object],
       ref_o.type_desc as object_type
	from sys.objects o
	join sys.sql_expression_dependencies dep
    	 on o.object_id = dep.referenced_id
	join sys.objects ref_o
    	 on dep.referencing_id = ref_o.object_id
	where 1 = 1 --o.type in ('V', 'U')
     	  --and schema_name(o.schema_id) = 'dbo'  -- put schema name here
     	  and o.name LIKE ('%vFactToSyndicateCurrent%')   -- put table/view name here
	order by [object]

	SELECT * FROM sys.objects WHERE type_desc LIKE '%Function%';

	SP_Depends 'FDM_DB.[dbo].[tf_PFT_CombinedPremiumIncCede]'