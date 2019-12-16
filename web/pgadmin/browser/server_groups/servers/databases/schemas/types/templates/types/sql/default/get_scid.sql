{% if tid %}
SELECT
    t.typnamespace as scid
FROM
    sys_type t
WHERE
    t.oid = {{tid}}::oid;
{% else %}
SELECT
    ns.oid as scid
FROM
    sys_namespace ns
WHERE
    ns.nspname = {{schema|qtLiteral}}::text;
{% endif %}
