SELECT
    a.attname AS name, format_type(a.atttypid, NULL) AS cltype,
    quote_ident(n.nspname)||'.'||quote_ident(c.relname) as inheritedfrom,
    c.oid as inheritedid
FROM
    sys_class c
JOIN
    sys_namespace n ON c.relnamespace=n.oid
JOIN
    sys_attribute a ON a.attrelid = c.oid AND NOT a.attisdropped AND a.attnum > 0
WHERE
{% if tid %}
    c.oid = {{tid}}::OID
{% else %}
    c.relname = {{tname|qtLiteral}}
{% endif %}
