SELECT --nspname, collname,
    CASE WHEN length(nspname) > 0 AND length(collname) > 0  THEN
    concat(nspname, '."', collname,'"')
    ELSE '' END AS copy_collation
FROM
    sys_collation c, sys_namespace n
WHERE
    c.collnamespace=n.oid
ORDER BY nspname, collname;
