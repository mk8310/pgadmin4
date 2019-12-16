SELECT
    oid, conname as name,
    NOT convalidated as convalidated
FROM
    sys_constraint
WHERE
    conrelid = {{tid}}::oid
    AND conname={{ name|qtLiteral }};
