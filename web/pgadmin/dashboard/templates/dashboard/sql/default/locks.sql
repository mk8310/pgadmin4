/*pga4dash*/
SELECT
    pid,
    locktype,
    datname,
    relation::regclass,
    page,
    tuple,
    virtualxid
    transactionid,
    classid::regclass,
    objid,
    objsubid,
    virtualtransaction,
    mode,
    granted,
    fastpath
FROM
    sys_locks l
    LEFT OUTER JOIN sys_database d ON (l.database = d.oid)
{% if did %}WHERE
    datname = (SELECT datname FROM sys_database WHERE oid = {{ did }}){% endif %}
ORDER BY
    pid, locktype
