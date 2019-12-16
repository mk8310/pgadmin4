{% if fetch_database %}
SELECT 'd' as type, datname,
    datallowconn AND sys_catalog.has_database_privilege(datname, 'CONNECT') AS datallowconn,
    datdba, datlastsysoid
FROM sys_database db
UNION
SELECT 'M', spcname, null, null, null
    FROM sys_tablespace where spcowner={{rid}}::oid
ORDER BY 1, 2
{% endif %}

{% if fetch_dependents %}
SELECT cl.relkind, COALESCE(cin.nspname, cln.nspname) as nspname,
    COALESCE(ci.relname, cl.relname) as relname, cl.relname as indname
FROM sys_class cl
JOIN sys_namespace cln ON cl.relnamespace=cln.oid
LEFT OUTER JOIN sys_index ind ON ind.indexrelid=cl.oid
LEFT OUTER JOIN sys_class ci ON ind.indrelid=ci.oid
LEFT OUTER JOIN sys_namespace cin ON ci.relnamespace=cin.oid
WHERE cl.oid IN (SELECT objid FROM sys_shdepend WHERE refobjid={{rid}}::oid) AND cl.oid > {{lastsysoid}}::oid
UNION ALL SELECT 'n', null, nspname, null
    FROM sys_namespace nsp
    WHERE nsp.oid IN (SELECT objid FROM sys_shdepend WHERE refobjid={{rid}}::oid) AND nsp.oid > {{lastsysoid}}::oid
UNION ALL SELECT CASE WHEN typtype='d' THEN 'd' ELSE 'y' END, null, typname, null
    FROM sys_type ty
    WHERE ty.oid IN (SELECT objid FROM sys_shdepend WHERE refobjid={{rid}}::oid) AND ty.oid > {{lastsysoid}}::oid
UNION ALL SELECT 'C', null, conname, null
    FROM sys_conversion co
    WHERE co.oid IN (SELECT objid FROM sys_shdepend WHERE refobjid={{rid}}::oid) AND co.oid > {{lastsysoid}}::oid
UNION ALL SELECT CASE WHEN prorettype=2279 THEN 'T' ELSE 'p' END, null, proname, null
    FROM sys_proc pr
    WHERE pr.oid IN (SELECT objid FROM sys_shdepend WHERE refobjid={{rid}}::oid) AND pr.oid > {{lastsysoid}}::oid
UNION ALL SELECT 'o', null, oprname || '('::text || COALESCE(tl.typname, ''::text) || CASE WHEN tl.oid IS NOT NULL
        AND tr.oid IS NOT NULL THEN ','::text END || COALESCE(tr.typname, ''::text) || ')'::text, null
    FROM sys_operator op
    LEFT JOIN sys_type tl ON tl.oid=op.oprleft
    LEFT JOIN sys_type tr ON tr.oid=op.oprright
    WHERE op.oid IN (SELECT objid FROM sys_shdepend WHERE refobjid={{rid}}::oid) AND op.oid > {{lastsysoid}}::oid
ORDER BY 1,2,3
{% endif %}
