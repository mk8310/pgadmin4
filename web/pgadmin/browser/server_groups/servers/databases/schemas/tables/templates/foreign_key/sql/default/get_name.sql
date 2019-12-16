SELECT conname as name
FROM sys_constraint ct
WHERE ct.oid = {{fkid}}::oid
