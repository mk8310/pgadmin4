{# FETCH statement for SCHEMA name #}
{% if data.schema %}
SELECT
    nspname
FROM
    sys_namespace
WHERE
    oid = {{data.schema}}::OID

{% elif data.id %}
SELECT
    nspname
FROM
    sys_namespace nsp
    LEFT JOIN sys_ts_config cfg
    ON cfg.cfgnamespace = nsp.oid
WHERE
    cfg.oid = {{data.id}}::OID
{% endif %}
