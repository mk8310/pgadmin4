SELECT
    split_part(rolconfig, '=', 1) AS name, replace(rolconfig, split_part(rolconfig, '=', 1) || '=', '') AS value, NULL::text AS database
FROM
    (SELECT
            unnest(rolconfig) AS rolconfig, rolcanlogin, rolname
    FROM
        sys_catalog.sys_roles
    WHERE
        oid={{ rid|qtLiteral }}::OID
    ) r

UNION ALL
SELECT
    split_part(rolconfig, '=', 1) AS name, replace(rolconfig, split_part(rolconfig, '=', 1) || '=', '') AS value, datname AS database
FROM
    (SELECT
        d.datname, unnest(c.setconfig) AS rolconfig
    FROM
        (SELECT *
        FROM sys_catalog.sys_db_role_setting dr
        WHERE
            dr.setrole={{ rid|qtLiteral }}::OID AND dr.setdatabase!=0
        ) c
        LEFT JOIN sys_catalog.sys_database d ON (d.oid = c.setdatabase)
    ) a;
