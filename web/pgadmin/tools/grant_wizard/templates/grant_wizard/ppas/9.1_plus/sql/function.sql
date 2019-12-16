{# ===== Fetch list of Database object types(Functions) ====== #}
{% if type and node_id %}
{% set func_type = 'Trigger Function' if type == 'trigger_function' else 'Procedure' if type == 'procedure' else 'Function' %}
{% set icon = 'icon-function' if type == 'function' else 'icon-procedure' if type == 'procedure' else 'icon-trigger_function' %}
SELECT
    pr.oid,
    sys_get_function_identity_arguments(pr.oid) AS proargs,
    pr.proname AS name,
    nsp.nspname AS nspname,
    '{{ func_type }}' AS object_type,
    '{{ icon }}' AS icon
FROM
    sys_proc pr
JOIN sys_namespace nsp ON nsp.oid=pr.pronamespace
JOIN sys_type typ ON typ.oid=prorettype
JOIN sys_namespace typns ON typns.oid=typ.typnamespace
JOIN sys_language lng ON lng.oid=prolang
LEFT OUTER JOIN sys_description des ON (des.objoid=pr.oid AND des.classoid='sys_proc'::regclass)
WHERE
    proisagg = FALSE AND pronamespace = {{ node_id }}::oid
    AND typname {{ 'NOT' if type != 'trigger_function' else '' }} IN ('trigger', 'event_trigger')
    AND pr.protype = {{'0' if type != 'procedure' else '1'}}::char
ORDER BY
    proname
{% endif %}
