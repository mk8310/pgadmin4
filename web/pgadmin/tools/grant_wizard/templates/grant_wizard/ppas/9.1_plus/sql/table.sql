{# ===== Fetch list of Database object types(Tables) ===== #}
{% if node_id %}
SELECT
    rel.relname AS name,
    nsp.nspname AS nspname,
    'Table' AS object_type,
    'icon-table' AS icon
FROM
    sys_class rel
JOIN sys_namespace nsp ON nsp.oid=rel.relnamespace
LEFT OUTER JOIN sys_tablespace spc ON spc.oid=rel.reltablespace
LEFT OUTER JOIN sys_description des ON (des.objoid=rel.oid AND des.objsubid=0 AND des.classoid='sys_class'::regclass)
LEFT OUTER JOIN sys_constraint con ON con.conrelid=rel.oid AND con.contype='p'
LEFT OUTER JOIN sys_class tst ON tst.oid = rel.reltoastrelid
LEFT JOIN sys_type typ ON rel.reloftype=typ.oid
WHERE
    rel.relkind IN ('r','s','t') AND rel.relnamespace = {{ node_id }}::oid
ORDER BY
    rel.relname
{% endif %}
