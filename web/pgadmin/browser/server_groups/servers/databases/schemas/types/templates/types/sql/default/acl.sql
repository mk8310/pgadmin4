SELECT 'typacl' as deftype, COALESCE(gt.rolname, 'PUBLIC') grantee, g.rolname grantor, array_agg(privilege_type) as privileges, array_agg(is_grantable) as grantable
FROM
    (SELECT
        d.grantee, d.grantor, d.is_grantable,
        CASE d.privilege_type
        WHEN 'USAGE' THEN 'U'
        ELSE 'UNKNOWN'
        END AS privilege_type
    FROM
        (SELECT t.typacl
            FROM sys_type t
            LEFT OUTER JOIN sys_type e ON e.oid=t.typelem
            LEFT OUTER JOIN sys_class ct ON ct.oid=t.typrelid AND ct.relkind <> 'c'
            LEFT OUTER JOIN sys_description des ON (des.objoid=t.oid AND des.classoid='sys_type'::regclass)
            WHERE t.typtype != 'd' AND t.typname NOT LIKE E'\\_%' AND t.typnamespace = {{scid}}::oid
            {% if tid %}
            AND t.oid = {{tid}}::oid
            {% endif %}
        ) acl,
        (SELECT (d).grantee AS grantee, (d).grantor AS grantor, (d).is_grantable
            AS is_grantable, (d).privilege_type AS privilege_type FROM (SELECT
            aclexplode(t.typacl) as d FROM sys_type t WHERE t.oid = {{tid}}::oid) a) d
        ) d
    LEFT JOIN sys_catalog.sys_roles g ON (d.grantor = g.oid)
    LEFT JOIN sys_catalog.sys_roles gt ON (d.grantee = gt.oid)
GROUP BY g.rolname, gt.rolname
ORDER BY grantee
