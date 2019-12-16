{# GET FTS CONFIGURATION name #}
{% if cfgid %}
SELECT
    cfg.cfgname as name,
    (
    SELECT
        nspname
    FROM
        sys_namespace
    WHERE
        oid = cfg.cfgnamespace
    ) as schema
FROM
    sys_ts_config cfg
WHERE
    cfg.oid = {{cfgid}}::OID;
{% endif %}
