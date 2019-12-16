SELECT proretset, prosrc, probin,
  sys_catalog.sys_get_function_arguments(sys_proc.oid) AS funcargs,
  sys_catalog.sys_get_function_identity_arguments(sys_proc.oid) AS funciargs,
  sys_catalog.sys_get_function_result(sys_proc.oid) AS funcresult,
  proiswin, provolatile, proisstrict, prosecdef,
  proconfig, procost, prorows, prodataaccess,
  'a' as proexeclocation,
  (SELECT lanname FROM sys_catalog.sys_language WHERE sys_proc.oid = prolang) as lanname,
  COALESCE(sys_catalog.sys_get_function_identity_arguments(sys_proc.oid), '') AS func_with_identity_arguments,
  nspname,
  proname,
  COALESCE(sys_catalog.sys_get_function_arguments(sys_proc.oid), '') AS func_args
FROM sys_catalog.sys_proc
  JOIN sys_namespace nsp ON nsp.oid=sys_proc.pronamespace
WHERE proisagg = FALSE
  AND pronamespace = {{scid}}::oid
  AND sys_proc.oid = {{fnid}}::oid;
