{### To fetch debug function information ###}
SELECT
    p.proname AS name, l.lanname, p.proretset, p.prorettype, y.typname AS rettype,
    CASE WHEN proallargtypes IS NOT NULL THEN
            sys_catalog.array_to_string(ARRAY(
                SELECT
                    sys_catalog.format_type(p.proallargtypes[s.i], NULL)
                FROM
                    sys_catalog.generate_series(0, sys_catalog.array_upper(
                        p.proallargtypes, 1)) AS s(i)), ',')
        ELSE
            sys_catalog.array_to_string(ARRAY(
                SELECT
                    sys_catalog.format_type(p.proargtypes[s.i], NULL)
                FROM
                    sys_catalog.generate_series(0, sys_catalog.array_upper(
                        p.proargtypes, 1)) AS s(i)), ',')
        END AS proargtypenames,
    CASE WHEN proallargtypes IS NOT NULL THEN
            sys_catalog.array_to_string(ARRAY(
                SELECT proallargtypes[s.i] FROM
                    sys_catalog.generate_series(0, sys_catalog.array_upper(proallargtypes, 1)) s(i)), ',')
        ELSE
            sys_catalog.array_to_string(ARRAY(
                SELECT proargtypes[s.i] FROM
                    sys_catalog.generate_series(0, sys_catalog.array_upper(proargtypes, 1)) s(i)), ',')
        END AS proargtypes,
    sys_catalog.array_to_string(p.proargnames, ',') AS proargnames,
    sys_catalog.array_to_string(proargmodes, ',') AS proargmodes,

	{% if is_ppas_database %}
        CASE WHEN n.nspparent <> 0 THEN n.oid ELSE 0 END AS pkg,
        CASE WHEN n.nspparent <> 0 THEN n.nspname ELSE '' END AS pkgname,
        CASE WHEN n.nspparent <> 0 THEN (SELECT oid FROM sys_proc WHERE pronamespace=n.oid AND proname='cons') ELSE 0 END AS pkgconsoid,
        CASE WHEN n.nspparent <> 0 THEN g.oid ELSE n.oid END AS schema,
        CASE WHEN n.nspparent <> 0 THEN g.nspname ELSE n.nspname END AS schemaname,
        NOT (l.lanname = 'edbspl' AND protype = '1') AS isfunc,
	{%else%}
        0 AS pkg,
        '' AS pkgname,
        0 AS pkgconsoid,
        n.oid     AS schema,
        n.nspname AS schemaname,
        true AS isfunc,
	{%endif%}
	sys_catalog.sys_get_function_identity_arguments(p.oid) AS signature,

	{% if hasFeatureFunctionDefaults %}
        sys_catalog.sys_get_expr(p.proargdefaults, 'sys_catalog.sys_class'::regclass, false) AS proargdefaults,
        p.pronargdefaults
	{%else%}
		 '' AS proargdefaults, 0 AS pronargdefaults
	{%endif%}
FROM
    sys_catalog.sys_proc p
    LEFT JOIN sys_catalog.sys_namespace n ON p.pronamespace = n.oid
    LEFT JOIN sys_catalog.sys_language l ON p.prolang = l.oid
    LEFT JOIN sys_catalog.sys_type y ON p.prorettype = y.oid
{% if is_ppas_database %}
    LEFT JOIN sys_catalog.sys_namespace g ON n.nspparent = g.oid
{% endif %}
{% if fid %}
WHERE p.oid = {{fid}}::oid;
{% endif %}
