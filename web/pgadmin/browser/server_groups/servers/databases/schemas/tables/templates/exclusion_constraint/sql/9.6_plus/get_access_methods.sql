SELECT amname
FROM sys_am
WHERE EXISTS (SELECT 1
              FROM sys_proc
              WHERE oid=amhandler)
ORDER BY amname;
