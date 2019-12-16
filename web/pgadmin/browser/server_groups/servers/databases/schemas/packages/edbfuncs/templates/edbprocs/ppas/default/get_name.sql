SELECT  proname AS name
FROM sys_proc
WHERE oid = {{edbfnid}}::oid
