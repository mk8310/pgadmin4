{# FETCH templates for FTS DICTIONARY #}
{% if template %}
SELECT
    tmplname,
    nspname,
    n.oid as schemaoid
FROM
    sys_ts_template JOIN sys_namespace n ON n.oid=tmplnamespace
ORDER BY
    tmplname
{% endif %}
