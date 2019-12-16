{# ===== fetch schema name against schema oid ===== #}
SELECT
    nspname
FROM
    sys_namespace
WHERE
    oid = {{ scid }}::oid;
