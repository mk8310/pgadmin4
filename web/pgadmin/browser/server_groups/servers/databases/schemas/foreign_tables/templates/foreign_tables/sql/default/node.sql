SELECT
    c.oid, c.relname AS name, sys_get_userbyid(relowner) AS owner,
    ftoptions, nspname as basensp, description
FROM
    sys_class c
JOIN
    sys_foreign_table ft ON c.oid=ft.ftrelid
LEFT OUTER JOIN
    sys_namespace nsp ON (nsp.oid=c.relnamespace)
LEFT OUTER JOIN
    sys_description des ON (des.objoid=c.oid AND des.classoid='sys_class'::regclass)
WHERE
{% if scid %}
    c.relnamespace = {{scid}}::oid
{% elif foid %}
    c.oid = {{foid}}::oid
{% endif %}
ORDER BY c.relname;
