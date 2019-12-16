SELECT
    pr.oid, pr.proname || '(' || COALESCE(sys_catalog
    .sys_get_function_identity_arguments(pr.oid), '') || ')' as name,
    lanname, sys_get_userbyid(proowner) as funcowner
FROM
    sys_proc pr
JOIN
    sys_type typ ON typ.oid=prorettype
JOIN
    sys_language lng ON lng.oid=prolang
JOIN
    sys_namespace nsp ON nsp.oid=pr.pronamespace
    AND nsp.nspname={{ nspname|qtLiteral }}
WHERE
    pr.prokind = 'p'
    AND typname NOT IN ('trigger', 'event_trigger')
    AND pr.proname = {{ name|qtLiteral }};
