SELECT
	r.oid, r.*,
	sys_catalog.shobj_description(r.oid, 'sys_authid') AS description,
	ARRAY(
		SELECT
			CASE WHEN am.admin_option THEN '1' ELSE '0' END || rm.rolname
		FROM
			(SELECT * FROM sys_auth_members WHERE member = r.oid) am
			LEFT JOIN sys_catalog.sys_roles rm ON (rm.oid = am.roleid)
	) rolmembership,
	(SELECT array_agg(provider || '=' || label) FROM sys_shseclabel sl1 WHERE sl1.objoid=r.oid) AS seclabels
FROM
	sys_roles r
{% if rid %}
WHERE r.oid = {{ rid|qtLiteral }}::oid
{% endif %}
ORDER BY r.rolcanlogin, r.rolname
