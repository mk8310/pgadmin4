{# ===== Fetch list of Database object types(Sequence) ===== #}
{% if node_id %}
SELECT
    cl.relname AS name,
    nsp.nspname AS nspname,
    'Sequence' AS object_type,
    'icon-sequence' AS icon
FROM
    sys_class cl
JOIN sys_namespace nsp ON nsp.oid=cl.relnamespace
LEFT OUTER JOIN sys_description des ON (des.objoid=cl.oid AND des.classoid='sys_class'::regclass)
WHERE
    relkind = 'S' AND relnamespace  = {{ node_id }}::oid
ORDER BY
    cl.relname
{% endif %}
