{### SQL to fetch tablespace object properties ###}
SELECT
    ts.oid, spcname AS name, spcoptions, sys_get_userbyid(spcowner) as spcuser,
    sys_catalog.sys_tablespace_location(ts.oid) AS spclocation,
    array_to_string(spcacl::text[], ', ') as acl,
    sys_catalog.shobj_description(oid, 'sys_tablespace') AS description,
    (SELECT
        array_agg(provider || '=' || label)
    FROM sys_shseclabel sl1
    WHERE sl1.objoid=ts.oid) AS seclabels
FROM
    sys_tablespace ts
{% if tsid %}
WHERE ts.oid={{ tsid|qtLiteral }}::OID
{% endif %}
ORDER BY name
