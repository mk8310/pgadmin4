SELECT
    pr.oid, pr.xmin, pr.*, pr.prosrc AS prosrc_c,
    pr.proname AS name, sys_get_function_result(pr.oid) AS prorettypename,
    typns.nspname AS typnsp, lanname, proargnames, oidvectortypes(proargtypes) AS proargtypenames,
    sys_get_expr(proargdefaults, 'sys_catalog.sys_class'::regclass) AS proargdefaultvals,
    pronargdefaults, proconfig, sys_get_userbyid(proowner) AS funcowner, description,
    CASE WHEN prosupport = 0::oid THEN '' ELSE prosupport::text END AS prosupportfunc,
    (SELECT
        array_agg(provider || '=' || label)
    FROM
        sys_seclabel sl1
    WHERE
        sl1.objoid=pr.oid) AS seclabels
FROM
    sys_proc pr
JOIN
    sys_type typ ON typ.oid=prorettype
JOIN
    sys_namespace typns ON typns.oid=typ.typnamespace
JOIN
    sys_language lng ON lng.oid=prolang
LEFT OUTER JOIN
    sys_description des ON (des.objoid=pr.oid AND des.classoid='sys_proc'::regclass)
WHERE
    pr.prokind IN ('f', 'w')
    AND typname NOT IN ('trigger', 'event_trigger')
{% if fnid %}
    AND pr.oid = {{fnid}}::oid
{% else %}
    AND pronamespace = {{scid}}::oid
{% endif %}
ORDER BY
    proname;
