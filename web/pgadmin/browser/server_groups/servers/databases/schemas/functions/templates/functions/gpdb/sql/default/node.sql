SELECT
    pr.oid, pr.proname || '(' || COALESCE(sys_catalog.sys_get_function_identity_arguments(pr.oid), '') || ')' as name,
    lanname, sys_get_userbyid(proowner) as funcowner, description
FROM
    sys_proc pr
JOIN
    sys_type typ ON typ.oid=prorettype
JOIN
    sys_language lng ON lng.oid=prolang
LEFT OUTER JOIN
    sys_description des ON (des.objoid=pr.oid AND des.classoid='sys_proc'::regclass)
WHERE
    proisagg = FALSE
{% if fnid %}
    AND pr.oid = {{ fnid|qtLiteral }}
{% endif %}
{% if scid %}
    AND pronamespace = {{scid}}::oid
{% endif %}
    AND typname NOT IN ('trigger', 'event_trigger')
ORDER BY
    proname;
