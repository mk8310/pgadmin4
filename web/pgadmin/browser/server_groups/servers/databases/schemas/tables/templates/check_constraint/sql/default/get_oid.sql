SELECT
    oid, conname as name
FROM
    sys_constraint
WHERE
    conrelid = {{tid}}::oid
    AND conname={{ name|qtLiteral }};
