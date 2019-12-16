{# FETCH TEXT SEARCH TEMPLATE NAME Statement #}
{% if tid %}
SELECT
    t.tmplname AS name,
    (
    SELECT
        nspname
    FROM
        sys_namespace
    WHERE
        oid = t.tmplnamespace
    ) as schema
FROM
    sys_ts_template t LEFT JOIN sys_description d
    ON d.objoid=t.oid AND d.classoid='sys_ts_template'::regclass
WHERE
    t.oid = {{tid}}::OID;
{% endif %}

{# DROP TEXT SEARCH TEMPLATE Statement #}
{% if schema and name %}
DROP TEXT SEARCH TEMPLATE {{conn|qtIdent(schema)}}.{{conn|qtIdent(name)}} {% if cascade %}CASCADE{%endif%};
{% endif %}
