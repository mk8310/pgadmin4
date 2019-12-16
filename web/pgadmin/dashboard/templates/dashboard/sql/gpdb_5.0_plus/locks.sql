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
    granted
FROM
    sys_locks l
    LEFT OUTER JOIN sys_database d ON (l.database = d.oid)
{% if did %}WHERE
    database = {{ did }}{% endif %}
ORDER BY
    pid, locktype
