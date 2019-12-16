SELECT c.oid, c.collname AS name, c.collcollate AS lc_collate, c.collctype AS lc_type,
    sys_get_userbyid(c.collowner) AS owner, description, n.nspname AS schema
FROM sys_collation c
    JOIN sys_namespace n ON n.oid=c.collnamespace
    LEFT OUTER JOIN sys_description des ON (des.objoid=c.oid AND des.classoid='sys_collation'::regclass)
WHERE c.collnamespace = {{scid}}::oid
{% if coid %}    AND c.oid = {{coid}}::oid {% endif %}
ORDER BY c.collname;
