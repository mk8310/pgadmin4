{% import 'tables/sql/macros/db_catalogs.macro' as CATALOG %}
SELECT c.oid,
  quote_ident(n.nspname)||'.'||quote_ident(c.relname) AS typname
  FROM sys_namespace n, sys_class c
WHERE c.relkind = 'c' AND c.relnamespace=n.oid
{% if not show_system_objects %}
{{ CATALOG.VALID_CATALOGS(server_type) }}
{% endif %}
ORDER BY typname;
