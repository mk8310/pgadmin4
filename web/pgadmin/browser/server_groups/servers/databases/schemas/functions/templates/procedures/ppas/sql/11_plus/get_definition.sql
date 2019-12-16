SELECT
    sys_get_functiondef({{fnid}}::oid) AS func_def,
    COALESCE(sys_catalog.sys_get_function_identity_arguments(pr.oid), '') as
    func_with_identity_arguments,
    nspname,
    pr.proname as proname,
    COALESCE(sys_catalog.sys_get_function_arguments(pr.oid), '') as func_args
FROM
    sys_proc pr
JOIN
    sys_namespace nsp ON nsp.oid=pr.pronamespace
WHERE
    pr.prokind = 'p'::char
    AND pronamespace = {{scid}}::oid
    AND pr.oid = {{fnid}}::oid;
