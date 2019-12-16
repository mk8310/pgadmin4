{# Fetch token/dictionary list for FTS CONFIGURATION #}
{% if cfgid %}
SELECT
    (
    SELECT
        t.alias
    FROM
        sys_catalog.ts_token_type(cfgparser) AS t
    WHERE
        t.tokid = maptokentype
    ) AS token,
    array_agg(dictname) AS dictname
FROM
    sys_ts_config_map
    LEFT OUTER JOIN sys_ts_config ON mapcfg = sys_ts_config.oid
    LEFT OUTER JOIN sys_ts_dict ON mapdict = sys_ts_dict.oid
WHERE
    mapcfg={{cfgid}}::OID
GROUP BY
    token
ORDER BY
    1
{% endif %}
