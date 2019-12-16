{# ===== get view name against view id ==== #}
{% if vid %}
SELECT
    c.relname AS name,
    nsp.nspname AS schema
FROM
    sys_class c
    LEFT OUTER JOIN sys_namespace nsp on nsp.oid = c.relnamespace
WHERE
    c.oid = {{vid}}
{% endif %}
