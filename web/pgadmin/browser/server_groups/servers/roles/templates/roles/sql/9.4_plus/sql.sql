SELECT
	array_to_string(array_agg(sql), E'\n\n') AS sql
FROM
(SELECT
	    '-- Role: ' ||
		sys_catalog.quote_ident(rolname) ||
		E'\n-- DROP ROLE ' ||
		sys_catalog.quote_ident(rolname) || E';\n\nCREATE ROLE ' ||
		sys_catalog.quote_ident(rolname) || E' WITH\n  ' ||
		CASE WHEN rolcanlogin THEN 'LOGIN' ELSE 'NOLOGIN' END || E'\n  ' ||
		CASE WHEN rolsuper THEN 'SUPERUSER' ELSE 'NOSUPERUSER' END || E'\n  ' ||
		CASE WHEN rolinherit THEN 'INHERIT' ELSE 'NOINHERIT' END || E'\n  ' ||
		CASE WHEN rolcreatedb THEN 'CREATEDB' ELSE 'NOCREATEDB' END || E'\n  ' ||
		CASE WHEN rolcreaterole THEN 'CREATEROLE' ELSE 'NOCREATEROLE' END || E'\n  ' ||
		-- PostgreSQL >=  9.1
		CASE WHEN rolreplication THEN 'REPLICATION' ELSE 'NOREPLICATION' END ||
		CASE WHEN rolconnlimit > 0 THEN E'\n  CONNECTION LIMIT ' || rolconnlimit ELSE '' END ||
{% if show_password %}
        (SELECT CASE
            WHEN (rolpassword LIKE 'md5%%' or rolpassword LIKE 'SCRAM%%') THEN E'\n  ENCRYPTED PASSWORD ''' || rolpassword || ''''
            WHEN rolpassword IS NOT NULL THEN E'\n  PASSWORD ''' || rolpassword || ''''
            ELSE '' END FROM sys_authid au WHERE au.oid=r.oid) ||
{% endif %}
		CASE WHEN rolvaliduntil IS NOT NULL THEN E'\n  VALID UNTIL ' || quote_literal(rolvaliduntil::text) ELSE '' END || ';' AS sql
FROM
	sys_roles r
WHERE
	r.oid=%(rid)s::OID
UNION ALL
(SELECT
	array_to_string(array_agg(sql), E'\n') AS sql
FROM
(SELECT
	'GRANT ' || array_to_string(array_agg(rolname), ', ') || ' TO ' || sys_catalog.quote_ident(sys_get_userbyid(%(rid)s::OID)) ||
	CASE WHEN admin_option THEN ' WITH ADMIN OPTION;' ELSE ';' END AS sql
FROM
	(SELECT
		quote_ident(r.rolname) AS rolname, m.admin_option AS admin_option
	FROM
		sys_auth_members m
		LEFT JOIN sys_roles r ON (m.roleid = r.oid)
	WHERE
		m.member=%(rid)s::OID
	ORDER BY
		r.rolname
	) a
GROUP BY admin_option) s)
UNION ALL
(SELECT
	array_to_string(array_agg(sql), E'\n') AS sql
FROM
(SELECT
	'ALTER ROLE ' || sys_catalog.quote_ident(rolname) || ' SET ' || param || ' TO ' || CASE WHEN param IN ('search_path', 'temp_tablespaces') THEN value ELSE quote_literal(value) END || ';' AS sql
FROM
(SELECT
	rolcanlogin, rolname, split_part(rolconfig, '=', 1) AS param, replace(rolconfig, split_part(rolconfig, '=', 1) || '=', '') AS value
FROM
	(SELECT
			unnest(rolconfig) AS rolconfig, rolcanlogin, rolname
	FROM
		sys_catalog.sys_roles
	WHERE
		oid=%(rid)s::OID
	) r
) a) b)
-- PostgreSQL >= 9.0
UNION ALL
(SELECT
	array_to_string(array_agg(sql), E'\n') AS sql
FROM
	(SELECT
		'ALTER ROLE ' || sys_catalog.quote_ident(sys_get_userbyid(%(rid)s::OID)) ||
		' IN DATABASE ' || sys_catalog.quote_ident(datname) ||
		' SET ' || param|| ' TO ' ||
		CASE
		WHEN param IN ('search_path', 'temp_tablespaces') THEN value
		ELSE quote_literal(value)
		END || ';' AS sql
	FROM
		(SELECT
			datname, split_part(rolconfig, '=', 1) AS param, replace(rolconfig, split_part(rolconfig, '=', 1) || '=', '') AS value
		FROM
			(SELECT
				d.datname, unnest(c.setconfig) AS rolconfig
			FROM
				(SELECT *
				FROM
					sys_catalog.sys_db_role_setting dr
				WHERE
					dr.setrole=%(rid)s::OID AND dr.setdatabase!=0) c
				LEFT JOIN sys_catalog.sys_database d ON (d.oid = c.setdatabase)
			) a
		) b
	) d
)
UNION ALL
(SELECT
	'COMMENT ON ROLE ' || sys_catalog.quote_ident(sys_get_userbyid(%(rid)s::OID)) || ' IS ' ||  sys_catalog.quote_literal(description) || ';' AS sql
FROM
	(SELECT	sys_catalog.shobj_description(%(rid)s::OID, 'sys_authid') AS description) a
WHERE
	description IS NOT NULL)
-- PostgreSQL >= 9.2
UNION ALL
(SELECT
	array_to_string(array_agg(sql), E'\n') AS sql
FROM
	(SELECT
		'SECURITY LABEL FOR ' || provider ||
		E'\n  ON ROLE ' || sys_catalog.quote_ident(rolname) ||
		E'\n  IS ' || sys_catalog.quote_literal(label) || ';' AS sql
	FROM
		(SELECT
			label, provider, rolname
		FROM
			(SELECT *
			FROM
				sys_shseclabel sl1
			WHERE sl1.objoid=%(rid)s::OID) s
			LEFT JOIN sys_catalog.sys_roles r ON (s.objoid=r.oid)) a) b
)) AS a
