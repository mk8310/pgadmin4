SELECT
    nspname
FROM
    sys_namespace
WHERE
    oid = {{ scid }}::oid;
