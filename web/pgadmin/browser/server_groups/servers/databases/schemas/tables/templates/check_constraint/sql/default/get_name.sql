SELECT conname as name
FROM sys_constraint ct
WHERE contype = 'c'
AND  ct.oid = {{cid}}::oid
