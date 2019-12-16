SELECT ct.oid,
    ct.conname as name,
    NOT convalidated as convalidated
FROM sys_constraint ct
WHERE contype='c' AND
    conrelid = {{tid}}::oid LIMIT 1;
