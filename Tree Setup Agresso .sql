select TOP 100 * from agresso.dbo.acrtrees WHERE client = 'TB' ORDER BY last_update DESC
select TOP 100 * from agresso.dbo.acrtrees WHERE client = 'TB' AND att_agrid = 47 ORDER BY last_update DESC


select * from agresso.dbo.acrtreesetup(nolock) WHERE att_1_col = 'dim_2'

select TOP 100 * from agresso.dbo.agldimvalue(nolock)
WHERE Client = 'TB' AND attribute_id = 'ZZ02' ORDER BY last_update DESC

select B.* from agresso.dbo.acrtreesetup(nolock) A
 LEFT JOIN agresso.dbo.acrtrees B
    ON A.att_agrid = B.att_agrid
	--AND B.client = 'TB'
 WHERE att_1_col = 'dim_2'   
   AND B.att_agrid IS NULL


   DECLARE @att_agrid as integer = 40 ,@cutoverClient as varchar(5) = 'TB'

	SELECT distinct
	[pkDimAccountTree] = cast(@att_agrid as nvarchar(25)) + '_' + cast(t.dim_a as nvarchar(255))
	,[Description] = cast(v.description as nvarchar(255))
	,[pkDimAccountTreeParent] = cast(@att_agrid as nvarchar(25)) + '_' + cast(s.[att_agrid] as nvarchar(255))
     ,att_2_id 
  FROM 
	[dbo].[acrtreesetup] s join 
	[dbo].[acrtrees] t on (s.client = @cutoverClient OR s.client ='*') and s.[att_agrid] = t.[att_agrid] left outer join
	dbo.agldimvalue v on CASE WHEN s.client='*' THEN @cutoverClient ELSE s.client END =v.client and v.attribute_id = att_id_a and t.dim_a=v.dim_value
  where (s.client = @cutoverClient OR s.client ='*') 
  and s.[att_agrid] =@att_agrid and len(t.dim_a)>0 
  and len(t.cat_2) = 0 
  and len(ltrim(rtrim(att_2_id))) = 0


select * from agresso.dbo.acrtreesetup(nolock) WHERE att_1_col = 'dim_2'-- AND att_agrid = 40



select * from agresso.dbo.acrtrees 
 WHERE client = 'TB' 
   AND att_agrid IN (40)
   and len(dim_a)>0 and len(cat_2) = 0 
 ORDER BY last_update DESC


select TOP 100 * from agresso.dbo.agldimvalue(nolock)
WHERE Client = 'TB' 
 AND attribute_id = 'ZZ45'
 AND dim_value IN('H','F')
 ORDER BY last_update DESC