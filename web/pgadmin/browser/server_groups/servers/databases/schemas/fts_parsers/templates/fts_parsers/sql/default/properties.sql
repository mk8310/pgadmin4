{# FETCH properties for FTS PARSER #}
SELECT
    prs.oid,
    prs.prsname as name,
    prs.prsstart,
    prs.prstoken,
    prs.prsend,
    prs.prslextype,
    prs.prsheadline,
    description,
    prs.prsnamespace AS schema
FROM
    sys_ts_parser prs
    LEFT OUTER JOIN sys_description des
ON
    (
    des.objoid=prs.oid
    AND des.classoid='sys_ts_parser'::regclass
    )
WHERE
{% if scid %}
    prs.prsnamespace = {{scid}}::OID
{% endif %}
{% if name %}
    {% if scid %}AND {% endif %}prs.prsname = {{name|qtLiteral}}
{% endif %}
{% if pid %}
    {% if name %}AND {% else %}{% if scid %}AND {% endif %}{% endif %}prs.oid = {{pid}}::OID
{% endif %}
ORDER BY prs.prsname;
