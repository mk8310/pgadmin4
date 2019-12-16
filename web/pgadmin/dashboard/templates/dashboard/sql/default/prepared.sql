/*pga4dash*/
SELECT
    gid,
    database,
    owner,
    transaction,
    to_char(prepared, 'YYYY-MM-DD HH24:MI:SS TZ') AS prepared
FROM
    sys_prepared_xacts
{% if did %}WHERE
    database = (SELECT datname FROM sys_database WHERE oid = {{ did }}){% endif %}
ORDER BY
    gid, database, owner
