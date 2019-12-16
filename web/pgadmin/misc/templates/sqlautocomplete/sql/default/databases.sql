{# SQL query for getting databases #}
SELECT d.datname
    FROM sys_catalog.sys_database d
    ORDER BY 1
