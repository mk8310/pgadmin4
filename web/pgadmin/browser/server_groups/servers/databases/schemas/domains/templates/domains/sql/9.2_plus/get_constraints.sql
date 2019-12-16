SELECT
    'DOMAIN' AS objectkind, c.oid as conoid, conname, typname as relname, nspname, description,
    regexp_replace(sys_get_constraintdef(c.oid, true), E'CHECK \\((.*)\\).*', E'\\1') as consrc, connoinherit, convalidated
FROM
    sys_constraint c
JOIN
    sys_type t ON t.oid=contypid
JOIN
    sys_namespace nl ON nl.oid=typnamespace
LEFT OUTER JOIN
    sys_description des ON (des.objoid=t.oid AND des.classoid='sys_constraint'::regclass)
WHERE
    contype = 'c' AND contypid =  {{doid}}::oid
ORDER BY
    conname;
