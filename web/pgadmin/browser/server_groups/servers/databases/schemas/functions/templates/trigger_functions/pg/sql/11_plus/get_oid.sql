SELECT
    pr.oid, pr.proname || '(' || COALESCE(sys_catalog
    .sys_get_function_identity_arguments(pr.oid), '') || ')' as name,
    lanname, sys_get_userbyid(proowner) as funcowner, pr.pronamespace AS nsp
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
    pr.prokind IN ('f', 'w')
    AND typname IN ('trigger', 'event_trigger')
    AND lanname NOT IN ('edbspl', 'sql', 'internal')
    AND pr.proname = {{ name|qtLiteral }};
