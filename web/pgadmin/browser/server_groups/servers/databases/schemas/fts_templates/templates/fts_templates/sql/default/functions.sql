{# FETCH lexize functions for TEXT SEARCH TEMPLATE #}
{% if lexize %}
SELECT
    proname, nspname
FROM
    sys_proc JOIN sys_namespace n ON n.oid=pronamespace
WHERE
    prorettype=2281
    AND proargtypes='2281 2281 2281 2281'
ORDER BY proname;
{% endif %}

{# FETCH init functions for TEXT SEARCH TEMPLATE #}
{% if init %}
SELECT
    proname, nspname
FROM
    sys_proc JOIN sys_namespace n ON n.oid=pronamespace
WHERE
    prorettype=2281 and proargtypes='2281'
ORDER BY
    proname;
{% endif %}
