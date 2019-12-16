{# SQL query for getting datatypes #}
SELECT n.nspname schema_name,
    t.typname object_name
FROM sys_catalog.sys_type t
    INNER JOIN sys_catalog.sys_namespace n ON n.oid = t.typnamespace
WHERE (t.typrelid = 0 OR (SELECT c.relkind = 'c' FROM sys_catalog.sys_class c WHERE c.oid = t.typrelid))
    AND NOT EXISTS(SELECT 1 FROM sys_catalog.sys_type el WHERE el.oid = t.typelem AND el.typarray = t.oid)
    AND n.nspname IN ({{schema_names}})
ORDER BY 1, 2;
