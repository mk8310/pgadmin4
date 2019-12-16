SELECT
    conname, contype, consrc, conislocal
FROM
    sys_constraint
WHERE
    conrelid={{foid}}::oid
ORDER by conname;
