SELECT
    d.typname as domain, bn.nspname as schema
FROM
    sys_type d
JOIN
    sys_namespace bn ON bn.oid=d.typnamespace
WHERE
    d.oid = {{doid}};
