SELECT 'lanacl' as deftype, COALESCE(gt.rolname, 'PUBLIC') grantee, g.rolname grantor,
    array_agg(privilege_type) as privileges, array_agg(is_grantable) as grantable
FROM
    (SELECT
        d.grantee, d.grantor, d.is_grantable,
        CASE d.privilege_type
        WHEN 'USAGE' THEN 'U'
        ELSE 'UNKNOWN'
        END AS privilege_type
    FROM
        (SELECT lanacl FROM sys_language lan
            LEFT OUTER JOIN sys_shdescription descr ON (lan.oid=descr.objoid AND descr.classoid='sys_language'::regclass)
        WHERE lan.oid = {{ lid|qtLiteral }}::OID
        ) acl,
        aclexplode(lanacl) d
    ) d
LEFT JOIN sys_catalog.sys_roles g ON (d.grantor = g.oid)
LEFT JOIN sys_catalog.sys_roles gt ON (d.grantee = gt.oid)
GROUP BY g.rolname, gt.rolname
ORDER BY grantee
