{% if scid and fnid %}
SELECT
    pr.proname as name, '(' || COALESCE(sys_catalog
    .sys_get_function_identity_arguments(pr.oid), '') || ')' as func_args,
    nspname
FROM
    sys_proc pr
JOIN
    sys_type typ ON typ.oid=prorettype
JOIN
    sys_namespace nsp ON nsp.oid=pr.pronamespace
WHERE
    proisagg = FALSE
    AND pronamespace = {{scid}}::oid
    AND typname NOT IN ('trigger', 'event_trigger')
    AND pr.oid = {{fnid}};
{% endif %}

{% if name %}
DROP FUNCTION {{ conn|qtIdent(nspname, name) }}{{func_args}}{% if cascade%} CASCADE{%
endif %};
{% endif %}
