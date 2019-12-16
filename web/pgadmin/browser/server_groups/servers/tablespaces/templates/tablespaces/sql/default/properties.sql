{### SQL to fetch tablespace object properties ###}
SELECT
    ts.oid, spcname AS name, spclocation, spcoptions,
    sys_get_userbyid(spcowner) as spcuser,
    sys_catalog.shobj_description(oid, 'sys_tablespace') AS description,
    array_to_string(spcacl::text[], ', ') as acl
FROM
    sys_tablespace ts
{% if tsid %}
WHERE ts.oid={{ tsid|qtLiteral }}::OID
{% endif %}
ORDER BY name
