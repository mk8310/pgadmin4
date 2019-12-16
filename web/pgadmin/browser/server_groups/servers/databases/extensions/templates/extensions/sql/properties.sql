{#===================Fetch properties of each extension by name or oid===================#}
SELECT
    x.oid AS eid, sys_get_userbyid(extowner) AS owner,
    x.extname AS name, n.nspname AS schema,
    x.extrelocatable AS relocatable, x.extversion AS version,
    e.comment
FROM
    sys_extension x
    LEFT JOIN sys_namespace n ON x.extnamespace=n.oid
    JOIN sys_available_extensions() e(name, default_version, comment) ON x.extname=e.name
{%- if eid %}
 WHERE x.oid = {{eid}}::oid
{% elif ename %}
 WHERE x.extname = {{ename|qtLiteral}}::text
{% else %}
 ORDER BY x.extname
{% endif %}
