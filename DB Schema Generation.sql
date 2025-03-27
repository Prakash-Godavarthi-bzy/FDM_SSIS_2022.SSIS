select 
--Case When Rank()over(partition by A.name order by B.column_id)=1 then 'WL' else '' end as SchemaName, 
      Case When Rank()over(partition by A.name order by B.column_id)=1 then a.name 
             Else '' end as TableName,
             B.name AS [Column Name],c.name AS [Data Type],
      Case When c.name like 'n%char' then 
                  case when B.max_length>0 then cast(B.max_length/2 AS nvarchar) else 'MAX' end
             When c.name like '%char' then 
                  case when B.max_length>0 then cast(B.max_length AS nvarchar) else 'MAX' end
             Else '' end as [Column Length]
From sys.tables A
inner join sys.columns B on A.object_id =b.object_id 
inner join sys.types C on B.user_type_id =C.user_type_id 
 where 1=1--A.schema_id =1 
 --and left(a.name,3)<>'HST'
 AND a.name IN ('PremiumForecastPremiumStage','PFT_SYND_WITH_CEDE')
 
		--('WriteTable_01 Premium','WriteTable_zOverridePremium','WriteTable_zFact To Lloyds'
		--		,'WriteTable_zFact To Host','WriteTable_zFact To Syndicate','WriteTable_02 External Commission'
		--		,'WriteTable_03 Internal Commission')
 order by A.name,B.column_id


 --SELECT * FROM sys.tables
 --SELECT * FROM sys.schemas