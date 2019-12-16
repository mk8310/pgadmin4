SELECT
    d.oid, d.typname as name, d.typbasetype, format_type(b.oid,NULL) as basetype,
    sys_get_userbyid(d.typowner) as owner,
    NULL AS colloid, format_type(b.oid, d.typtypmod) AS fulltype,
    '' AS collname,
    d.typtypmod, d.typnotnull, d.typdefault, d.typndims, d.typdelim, bn.nspname as basensp,
    description, (SELECT COUNT(1) FROM sys_type t2 WHERE t2.typname=d.typname) > 1 AS domisdup,
    (SELECT COUNT(1) FROM sys_type t3 WHERE t3.typname=b.typname) > 1 AS baseisdup,
    ARRAY [] :: TEXT []         AS seclabels

FROM
    sys_type d
JOIN
    sys_type b ON b.oid = d.typbasetype
JOIN
    sys_namespace bn ON bn.oid=d.typnamespace
LEFT OUTER JOIN
    sys_description des ON (des.objoid=d.oid AND des.classoid='sys_type'::regclass)
WHERE
    d.typnamespace = {{scid}}::oid
    {% if doid %}
    AND d.oid={{doid}}::oid
    {% endif %}
ORDER BY
    d.typname;
