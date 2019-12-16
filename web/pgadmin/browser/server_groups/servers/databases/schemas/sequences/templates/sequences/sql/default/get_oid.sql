SELECT cl.oid as oid, relnamespace
FROM sys_class cl
LEFT OUTER JOIN sys_description des ON (des.objoid=cl.oid AND des.classoid='sys_class'::regclass)
LEFT OUTER JOIN sys_namespace nsp ON (nsp.oid = cl.relnamespace)
WHERE relkind = 'S'
AND relname = {{ name|qtLiteral }}
AND nspname = {{ schema|qtLiteral }}
