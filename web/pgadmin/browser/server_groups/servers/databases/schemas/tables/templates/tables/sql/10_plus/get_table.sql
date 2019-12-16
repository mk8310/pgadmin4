SELECT
    rel.relname AS name
FROM
    sys_class rel
WHERE
    rel.relkind IN ('r','s','t','p')
    AND rel.relnamespace = {{ scid }}::oid
    AND rel.oid = {{ tid }}::oid;
