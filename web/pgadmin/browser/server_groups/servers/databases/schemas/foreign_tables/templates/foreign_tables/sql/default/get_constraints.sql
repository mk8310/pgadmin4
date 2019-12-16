SELECT
    conname, contype, consrc
FROM
    sys_constraint
WHERE
    conrelid={{foid}}::oid
ORDER by conname;
