{### SQL to fetch tablespace object stats ###}
{% if tsid %}
SELECT sys_tablespace_size({{ tsid|qtLiteral }}::OID) AS {{ conn|qtIdent(_('Size')) }}
{% else %}
SELECT ts.spcname AS {{ conn|qtIdent(_('Name')) }},
    sys_tablespace_size(ts.oid) AS {{ conn|qtIdent(_('Size')) }}
FROM
    sys_catalog.sys_tablespace ts;
{% endif %}
