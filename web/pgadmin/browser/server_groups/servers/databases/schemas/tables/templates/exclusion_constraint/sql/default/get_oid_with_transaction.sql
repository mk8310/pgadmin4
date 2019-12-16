SELECT ct.conindid AS oid,
    ct.conname AS name,
    true AS convalidated
FROM sys_constraint ct
WHERE contype='x' AND
    conrelid = {{tid}}::oid LIMIT 1;
