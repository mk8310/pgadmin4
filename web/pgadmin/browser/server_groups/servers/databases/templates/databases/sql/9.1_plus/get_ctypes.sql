SELECT DISTINCT(datctype) AS cname
FROM sys_database
UNION
SELECT DISTINCT(datcollate) AS cname
FROM sys_database
