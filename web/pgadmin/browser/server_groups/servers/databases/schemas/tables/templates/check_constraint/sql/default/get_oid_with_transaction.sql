SELECT ct.oid,
    ct.conname as name
FROM sys_constraint ct
WHERE contype='c' AND
    conrelid = {{tid}}::oid LIMIT 1;
