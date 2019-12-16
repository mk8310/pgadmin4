SELECT
    c.oid, c.relname as name, r.rolname AS owner, description
FROM
    sys_class c
    LEFT OUTER JOIN sys_description d
        ON d.objoid=c.oid AND d.classoid='sys_class'::regclass
    LEFT JOIN sys_roles r ON c.relowner = r.oid
WHERE
    relnamespace = {{scid}}::oid
{% if coid %} AND
    c.oid = {{coid}}::oid
{% endif %} ORDER BY relname;
