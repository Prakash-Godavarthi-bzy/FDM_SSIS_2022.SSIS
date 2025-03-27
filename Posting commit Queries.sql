SELECT case count(*) when 0 then 'No' else 'Yes' end CanPost
FROM aaguser a
FULL JOIN aagusersec b on a.user_id = b.user_id
FULL JOIN aaguserdetail c ON b.user_id = c.user_id 
FULL JOIN agladdress d ON a.user_id = d.dim_value AND d.attribute_id = 'GN'
WHERE a.user_id = 'KUREA' and
c.role_id NOT LIKE 'WF%'

SELECT        CASE Status WHEN 'N' THEN 'Open' WHEN 'P' THEN 'Password' ELSE 'Closed' END AS PeriodStatus
FROM            acrperiod
WHERE        (client = 'TB') AND (period_id = 'GL') AND (period = 202206)

SELECT * FROM acrperiod WHERE (client = 'TB') AND (period_id = 'GL') AND (period = 202206)


