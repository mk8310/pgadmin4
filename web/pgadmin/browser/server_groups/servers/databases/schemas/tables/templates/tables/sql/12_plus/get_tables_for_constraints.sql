SELECT cl.oid as value, quote_ident(nspname)||'.'||quote_ident(relname) AS label
FROM sys_namespace nsp, sys_class cl
WHERE relnamespace=nsp.oid AND relkind in ('r', 'p')
   AND nsp.nspname NOT LIKE E'pg\_temp\_%'
   {% if not show_sysobj %}
   AND (nsp.nspname NOT LIKE 'pg\_%' AND nsp.nspname NOT in ('information_schema'))
   {% endif %}
ORDER BY nspname, relname
