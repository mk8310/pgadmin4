SELECT sys_class.oid, relname as name
FROM sys_class
LEFT JOIN sys_namespace ON sys_namespace.oid=sys_class.relnamespace::oid
WHERE relkind = 'r'
 AND  relstorage = 'x'
 AND sys_namespace.nspname not like 'gp_toolkit';
