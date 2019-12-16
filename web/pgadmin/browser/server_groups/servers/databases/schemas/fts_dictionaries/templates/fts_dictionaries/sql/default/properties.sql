{# FETCH properties for FTS DICTIONARY #}
SELECT
    dict.oid,
    dict.dictname as name,
    sys_get_userbyid(dict.dictowner) as owner,
    t.tmplname as template,
    (SELECT nspname FROM sys_namespace n WHERE n.oid = t.tmplnamespace) as template_schema,
    dict.dictinitoption as options,
    dict.dictnamespace as schema,
    des.description
FROM
    sys_ts_dict dict
    LEFT OUTER JOIN sys_ts_template t ON t.oid=dict.dicttemplate
    LEFT OUTER JOIN sys_description des ON (des.objoid=dict.oid AND des.classoid='sys_ts_dict'::regclass)
WHERE
{% if scid %}
    dict.dictnamespace = {{scid}}::OID
{% endif %}
{% if name %}
    {% if scid %}AND {% endif %}dict.dictname = {{name|qtLiteral}}
{% endif %}
{% if dcid %}
    {% if scid %}AND {% else %}{% if name %}AND {% endif %}{% endif %}dict.oid = {{dcid}}::OID
{% endif %}
ORDER BY
    dict.dictname
