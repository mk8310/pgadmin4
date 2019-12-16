SELECT
    pr.oid, pr.proname || '()' AS name,
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
{% if fnid %}
    AND pr.oid = {{ fnid|qtLiteral }}
{% endif %}
{% if scid %}
    AND pronamespace = {{scid}}::oid
{% endif %}
    AND typname IN ('trigger', 'event_trigger')
    AND lanname NOT IN ('edbspl', 'sql', 'internal')
ORDER BY
    proname;
