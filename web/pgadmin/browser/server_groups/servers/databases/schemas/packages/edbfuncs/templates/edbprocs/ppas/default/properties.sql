SELECT  sys_proc.oid,
        proname AS name,
        pronargs,
        proallargtypes,
        proargnames AS argnames,
        pronargdefaults,
        oidvectortypes(proargtypes) AS proargtypenames,
        proargmodes,
        proargnames,
        sys_get_expr(proargdefaults, 'sys_catalog.sys_class'::regclass) AS proargdefaultvals,
        sys_get_userbyid(proowner) AS funcowner,
        sys_get_function_result(sys_proc.oid) AS prorettypename,
        prosrc,
        lanname,
        CASE
        WHEN proaccess = '+' THEN 'Public'
        WHEN proaccess = '-' THEN 'Private'
        ELSE 'Unknown' END AS visibility
FROM sys_proc, sys_namespace, sys_language lng
WHERE protype = '1'::char
AND pronamespace = {{pkgid}}::oid
AND sys_proc.pronamespace = sys_namespace.oid
AND lng.oid=prolang
{% if edbfnid %}
AND sys_proc.oid = {{edbfnid}}::oid
{% endif %}
  ORDER BY name
