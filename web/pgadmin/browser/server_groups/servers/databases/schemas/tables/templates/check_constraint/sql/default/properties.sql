SELECT c.oid, conname as name, relname, nspname, description as comment ,
       sys_get_expr(conbin, conrelid, true) as consrc
    FROM sys_constraint c
    JOIN sys_class cl ON cl.oid=conrelid
    JOIN sys_namespace nl ON nl.oid=relnamespace
LEFT OUTER JOIN
    sys_description des ON (des.objoid=c.oid AND
                           des.classoid='sys_constraint'::regclass)
WHERE contype = 'c'
    AND conrelid = {{ tid }}::oid
{% if cid %}
    AND c.oid = {{ cid }}::oid
{% endif %}
