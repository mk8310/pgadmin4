SELECT  sys_proc.oid,
        sys_proc.proname || '(' || COALESCE(sys_catalog.sys_get_function_identity_arguments(sys_proc.oid), '') || ')' AS name,
        sys_get_userbyid(proowner) AS funcowner
FROM sys_proc, sys_namespace
WHERE protype = '0'::char
{% if fnid %}
AND sys_proc.oid = {{ fnid|qtLiteral }}
{% endif %}
AND pronamespace = {{pkgid|qtLiteral}}::oid
AND sys_proc.pronamespace = sys_namespace.oid
