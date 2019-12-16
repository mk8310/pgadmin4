SELECT
    ts.oid AS oid, spcname AS name, spcowner as owner
FROM
    sys_tablespace ts
{% if tsid %}
WHERE
    ts.oid={{ tsid|qtLiteral }}::OID
{% endif %}
ORDER BY name;
