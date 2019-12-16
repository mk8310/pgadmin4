SELECT
    oid, conname as name
FROM
    sys_constraint
WHERE
    contypid = {{doid}}::oid
    AND conname={{ name|qtLiteral }};
