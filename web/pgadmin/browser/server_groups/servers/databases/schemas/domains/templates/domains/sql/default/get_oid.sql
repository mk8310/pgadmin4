{% if doid %}
SELECT
    d.typnamespace as scid
FROM
    sys_type d
WHERE
    d.oid={{ doid }}::oid;
{% else %}
SELECT
    d.oid
FROM
    sys_type d
JOIN
    sys_namespace bn ON bn.oid=d.typnamespace
WHERE
    bn.nspname = {{ basensp|qtLiteral }}
    AND d.typname={{ name|qtLiteral }};
{% endif %}
