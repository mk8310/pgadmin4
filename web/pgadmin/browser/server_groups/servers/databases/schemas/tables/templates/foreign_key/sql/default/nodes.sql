SELECT ct.oid,
    conname as name,
    true as convalidated
FROM sys_constraint ct
WHERE contype='f' AND
    conrelid = {{tid}}::oid
ORDER BY conname
