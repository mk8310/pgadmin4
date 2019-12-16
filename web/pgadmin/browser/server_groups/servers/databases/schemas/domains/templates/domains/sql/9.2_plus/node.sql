SELECT
    d.oid, d.typname as name, sys_get_userbyid(d.typowner) as owner,
    bn.nspname as basensp
FROM
    sys_type d
JOIN
    sys_type b ON b.oid = d.typbasetype
JOIN
    sys_namespace bn ON bn.oid=d.typnamespace
{% if scid is defined %}
WHERE
    d.typnamespace = {{scid}}::oid
{% elif doid %}
WHERE d.oid = {{doid}}::oid
{% endif %}
ORDER BY
    d.typname;
