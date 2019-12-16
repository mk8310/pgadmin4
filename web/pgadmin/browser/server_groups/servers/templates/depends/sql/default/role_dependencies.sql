SELECT rolname AS refname, refclassid, deptype
FROM sys_shdepend dep
LEFT JOIN sys_roles r ON refclassid=1260 AND refobjid=r.oid
{{where_clause}} ORDER BY 1
