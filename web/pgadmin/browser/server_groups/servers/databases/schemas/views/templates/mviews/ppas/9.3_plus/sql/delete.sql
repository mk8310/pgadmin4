{# =================== Drop/Cascade materialized view by name ====================#}
{% if vid %}
SELECT
    c.relname As name,
    nsp.nspname
FROM
    sys_class c
LEFT JOIN sys_namespace nsp ON c.relnamespace = nsp.oid
WHERE
    c.relfilenode = {{ vid }};
{% elif (name and nspname) %}
DROP MATERIALIZED VIEW {{ conn|qtIdent(nspname, name) }} {% if cascade %} CASCADE {% endif %}
{% endif %}
