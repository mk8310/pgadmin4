{% if fetch_database %}
SELECT datname,
    datallowconn AND sys_catalog.has_database_privilege(datname, 'CONNECT') AS datallowconn,
    dattablespace
FROM sys_database db
ORDER BY datname
{% endif %}

{% if fetch_dependents %}
SELECT cl.relkind, COALESCE(cin.nspname, cln.nspname) as nspname,
    COALESCE(ci.relname, cl.relname) as relname, cl.relname as indname
FROM sys_class cl
JOIN sys_namespace cln ON cl.relnamespace=cln.oid
LEFT OUTER JOIN sys_index ind ON ind.indexrelid=cl.oid
LEFT OUTER JOIN sys_class ci ON ind.indrelid=ci.oid
LEFT OUTER JOIN sys_namespace cin ON ci.relnamespace=cin.oid,
sys_database WHERE datname = current_database() AND
(cl.reltablespace = {{tsid}}::oid OR (cl.reltablespace=0 AND dattablespace = {{tsid}}::oid))
ORDER BY 1,2,3
{% endif %}
