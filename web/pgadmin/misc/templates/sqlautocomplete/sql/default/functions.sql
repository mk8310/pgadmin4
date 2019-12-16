{# ============= Fetch the list of functions based on given schema_names ============= #}
SELECT n.nspname schema_name,
    p.proname func_name,
    p.proargnames arg_names,
    COALESCE(proallargtypes::regtype[], proargtypes::regtype[])::text[] arg_types,
    p.proargmodes arg_modes,
    prorettype::regtype::text return_type,
    p.proisagg is_aggregate,
    p.proiswindow is_window,
    p.proretset is_set_returning,
    sys_get_expr(proargdefaults, 0) AS arg_defaults
FROM sys_catalog.sys_proc p
    INNER JOIN sys_catalog.sys_namespace n ON n.oid = p.pronamespace
WHERE p.prorettype::regtype != 'trigger'::regtype
    AND n.nspname IN ({{schema_names}})
ORDER BY 1, 2
