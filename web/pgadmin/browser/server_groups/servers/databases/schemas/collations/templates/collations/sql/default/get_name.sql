SELECT nspname AS schema, collname AS name
FROM sys_collation c, sys_namespace n
WHERE c.collnamespace = n.oid AND
    n.oid = {{ scid }}::oid AND
    c.oid = {{ coid }}::oid;
