SELECT sys_class.oid, relname as name
FROM sys_class
WHERE relkind = 'r'
 AND  relstorage = 'x'
 AND sys_class.oid = {{ external_table_id }}::oid;
