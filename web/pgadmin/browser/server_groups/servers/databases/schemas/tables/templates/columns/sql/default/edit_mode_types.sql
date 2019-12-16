SELECT tt.oid, format_type(tt.oid,NULL) AS typname
FROM sys_type tt
WHERE tt.oid in (
	SELECT casttarget from sys_cast
	WHERE castsource = {{type_id}}
	AND castcontext IN ('i', 'a')
	UNION
	SELECT typbasetype from sys_type where oid = {{type_id}}
	UNION
	SELECT oid FROM sys_type WHERE typbasetype = {{type_id}}
)
