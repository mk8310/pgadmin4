SELECT
    attname, attndims, atttypmod, attoptions, attfdwoptions, format_type(t.oid,NULL) AS datatype,
    attnotnull, attstattarget, attnum, format_type(t.oid, att.atttypmod) AS fulltype,
    CASE WHEN length(cn.nspname) > 0 AND length(cl.collname) > 0 THEN
    concat(cn.nspname, '."', cl.collname,'"') ELSE '' END AS collname,
    (SELECT COUNT(1) from sys_type t2 WHERE t2.typname=t.typname) > 1 AS isdup,
    sys_catalog.sys_get_expr(def.adbin, def.adrelid) AS typdefault
FROM
    sys_attribute att
JOIN
    sys_type t ON t.oid=atttypid
JOIN
    sys_namespace nsp ON t.typnamespace=nsp.oid
LEFT OUTER JOIN
    sys_attrdef def ON adrelid=att.attrelid AND adnum=att.attnum
LEFT OUTER JOIN
    sys_type b ON t.typelem=b.oid
LEFT OUTER JOIN
    sys_collation cl ON t.typcollation=cl.oid
LEFT OUTER JOIN
    sys_namespace cn ON cl.collnamespace=cn.oid
WHERE
    att.attrelid={{foid}}::oid
    AND attnum>0
ORDER by attnum;
