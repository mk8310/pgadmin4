SELECT
    oid as conoid, conname, contype,
    BTRIM(substring(sys_get_constraintdef(oid, true) from '\(.+\)'), '()') as consrc,
    connoinherit, convalidated, conislocal
FROM
    sys_constraint
WHERE
    conrelid={{foid}}::oid
ORDER by conname;
