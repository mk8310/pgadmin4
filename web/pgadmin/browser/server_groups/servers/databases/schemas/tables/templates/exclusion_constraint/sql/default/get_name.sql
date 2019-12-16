SELECT conname as name
FROM sys_constraint ct
WHERE ct.conindid = {{cid}}::oid
