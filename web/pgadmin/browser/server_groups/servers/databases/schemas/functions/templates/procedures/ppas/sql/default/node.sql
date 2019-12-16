SELECT
    pr.oid,
    CASE WHEN
        sys_catalog.sys_get_function_identity_arguments(pr.oid) <> ''
    THEN
        pr.proname || '(' || sys_catalog.sys_get_function_identity_arguments(pr.oid) || ')'
    ELSE
        pr.proname::text
    END AS name,
    lanname, sys_get_userbyid(proowner) AS funcowner, description
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
    AND pr.protype = '1'::char
{% if fnid %}
    AND pr.oid = {{ fnid|qtLiteral }}
{% endif %}
{% if scid %}
    AND pronamespace = {{scid}}::oid
{% endif %}
    AND typname NOT IN ('trigger', 'event_trigger')
ORDER BY
    proname;
