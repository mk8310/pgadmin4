{# PARSER name from FTS CONFIGURATION OID #}
{% if cfgid %}
SELECT
    cfgparser
FROM
    sys_ts_config
where
    oid = {{cfgid}}::OID
{% endif %}


{# PARSER list #}
{% if parser %}
SELECT
    prsname,
    nspname,
    n.oid as schemaoid
FROM
    sys_ts_parser
    JOIN sys_namespace n
    ON n.oid=prsnamespace
ORDER BY
    prsname;
{% endif %}
