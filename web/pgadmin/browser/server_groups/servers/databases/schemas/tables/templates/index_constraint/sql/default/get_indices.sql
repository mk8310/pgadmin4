SELECT relname FROM sys_class, sys_index
WHERE sys_class.oid=indexrelid
AND indrelid={{ tid }}
