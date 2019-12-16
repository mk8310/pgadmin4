SELECT nsp.nspname AS schema,
    rel.relname AS table
FROM
    sys_class rel
JOIN sys_namespace nsp
ON rel.relnamespace = nsp.oid::oid
WHERE rel.oid = {{tid}}::oid
