{# SQL query for getting foreign keys #}
SELECT s_p.nspname AS parentschema,
   t_p.relname AS parenttable,
   unnest((
    select
        array_agg(attname ORDER BY i)
    from
        (select unnest(confkey) as attnum, generate_subscripts(confkey, 1) as i) x
        JOIN sys_catalog.sys_attribute c USING(attnum)
        WHERE c.attrelid = fk.confrelid
    )) AS parentcolumn,
   s_c.nspname AS childschema,
   t_c.relname AS childtable,
   unnest((
    select
        array_agg(attname ORDER BY i)
    from
        (select unnest(conkey) as attnum, generate_subscripts(conkey, 1) as i) x
        JOIN sys_catalog.sys_attribute c USING(attnum)
        WHERE c.attrelid = fk.conrelid
    )) AS childcolumn
FROM sys_catalog.sys_constraint fk
JOIN sys_catalog.sys_class      t_p ON t_p.oid = fk.confrelid
JOIN sys_catalog.sys_namespace  s_p ON s_p.oid = t_p.relnamespace
JOIN sys_catalog.sys_class      t_c ON t_c.oid = fk.conrelid
JOIN sys_catalog.sys_namespace  s_c ON s_c.oid = t_c.relnamespace
WHERE fk.contype = 'f' AND s_p.nspname IN ({{schema_names}})
