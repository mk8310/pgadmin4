{% import 'columns/macros/security.macros' as SECLABEL %}
{% import 'columns/macros/privilege.macros' as PRIVILEGE %}
{% import 'macros/variable.macros' as VARIABLE %}
{% import 'types/macros/get_full_type_sql_format.macros' as GET_TYPE %}
{###  Add column ###}
{% if data.name and  data.cltype %}
ALTER TABLE {{conn|qtIdent(data.schema, data.table)}}
    ADD COLUMN {{conn|qtIdent(data.name)}} {% if is_sql %}{{data.displaytypname}}{% else %}{{ GET_TYPE.CREATE_TYPE_SQL(conn, data.cltype, data.attlen, data.attprecision, data.hasSqrBracket) }}{% endif %}{% if data.collspcname %}
 COLLATE {{data.collspcname}}{% endif %}{% if data.attnotnull %}
 NOT NULL{% endif %}{% if data.defval is defined and data.defval is not none and data.defval != '' %}
 DEFAULT {{data.defval}}{% endif %};

{% endif %}
{###  Add comments ###}
{% if data and data.description %}
COMMENT ON COLUMN {{conn|qtIdent(data.schema, data.table, data.name)}}
    IS {{data.description|qtLiteral}};

{% endif %}
{###  Add variables to column ###}
{% if data.attoptions %}
ALTER TABLE {{conn|qtIdent(data.schema, data.table)}}
    {{ VARIABLE.SET(conn, 'COLUMN', data.name, data.attoptions) }}

{% endif %}
{###  Alter column statistics value ###}
{% if data.attstattarget is defined and data.attstattarget > -1 %}
ALTER TABLE {{conn|qtIdent(data.schema, data.table)}}
    ALTER COLUMN {{conn|qtTypeIdent(data.name)}} SET STATISTICS {{data.attstattarget}};

{% endif %}
{###  Alter column storage value ###}
{% if data.attstorage is defined and data.attstorage != data.defaultstorage %}
ALTER TABLE {{conn|qtIdent(data.schema, data.table)}}
    ALTER COLUMN {{conn|qtTypeIdent(data.name)}} SET STORAGE {%if data.attstorage == 'p' %}
PLAIN{% elif data.attstorage == 'm'%}MAIN{% elif data.attstorage == 'e'%}
EXTERNAL{% elif data.attstorage == 'x'%}EXTENDED{% endif %};

{% endif %}
{###  ACL ###}
{% if data.attacl %}
{% for priv in data.attacl %}
{{ PRIVILEGE.APPLY(conn, data.schema, data.table, data.name, priv.grantee, priv.without_grant, priv.with_grant) }}
{% endfor %}
{% endif %}
{###  Security Lables ###}
{% if data.seclabels %}
{% for r in data.seclabels %}
{{ SECLABEL.APPLY(conn, 'COLUMN',data.schema, data.table, data.name, r.provider, r.label) }}
{% endfor %}
{% endif %}
