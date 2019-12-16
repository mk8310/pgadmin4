SELECT
    oid as conoid, conname, contype, consrc, connoinherit, convalidated, conislocal
FROM
    sys_constraint
WHERE
    conrelid={{foid}}::oid
ORDER by conname;
