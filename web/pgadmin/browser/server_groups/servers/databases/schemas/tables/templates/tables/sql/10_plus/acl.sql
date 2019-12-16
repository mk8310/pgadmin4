{### SQL to fetch privileges for tablespace ###}
SELECT 'relacl' as deftype, COALESCE(gt.rolname, 'PUBLIC') grantee, g.rolname grantor,
    array_agg(privilege_type) as privileges, array_agg(is_grantable) as grantable
FROM
  (SELECT
    d.grantee, d.grantor, d.is_grantable,
    CASE d.privilege_type
		WHEN 'CONNECT' THEN 'c'
		WHEN 'CREATE' THEN 'C'
		WHEN 'DELETE' THEN 'd'
		WHEN 'EXECUTE' THEN 'X'
		WHEN 'INSERT' THEN 'a'
		WHEN 'REFERENCES' THEN 'x'
		WHEN 'SELECT' THEN 'r'
		WHEN 'TEMPORARY' THEN 'T'
		WHEN 'TRIGGER' THEN 't'
		WHEN 'TRUNCATE' THEN 'D'
		WHEN 'UPDATE' THEN 'w'
		WHEN 'USAGE' THEN 'U'
		ELSE 'UNKNOWN'
	END AS privilege_type
  FROM
    (SELECT rel.relacl
        FROM sys_class rel
          LEFT OUTER JOIN sys_tablespace spc on spc.oid=rel.reltablespace
          LEFT OUTER JOIN sys_constraint con ON con.conrelid=rel.oid AND con.contype='p'
          LEFT OUTER JOIN sys_class tst ON tst.oid = rel.reltoastrelid
          LEFT JOIN sys_type typ ON rel.reloftype=typ.oid
        WHERE rel.relkind IN ('r','s','t','p') AND rel.relnamespace = {{ scid }}::oid
            AND rel.oid = {{ tid }}::oid
    ) acl,
    (SELECT (d).grantee AS grantee, (d).grantor AS grantor, (d).is_grantable
        AS is_grantable, (d).privilege_type AS privilege_type FROM (SELECT
        aclexplode(rel.relacl) as d
        FROM sys_class rel
          LEFT OUTER JOIN sys_tablespace spc on spc.oid=rel.reltablespace
          LEFT OUTER JOIN sys_constraint con ON con.conrelid=rel.oid AND con.contype='p'
          LEFT OUTER JOIN sys_class tst ON tst.oid = rel.reltoastrelid
          LEFT JOIN sys_type typ ON rel.reloftype=typ.oid
        WHERE rel.relkind IN ('r','s','t','p') AND rel.relnamespace = {{ scid }}::oid
            AND rel.oid = {{ tid }}::oid
        ) a) d
    ) d
  LEFT JOIN sys_catalog.sys_roles g ON (d.grantor = g.oid)
  LEFT JOIN sys_catalog.sys_roles gt ON (d.grantee = gt.oid)
GROUP BY g.rolname, gt.rolname
