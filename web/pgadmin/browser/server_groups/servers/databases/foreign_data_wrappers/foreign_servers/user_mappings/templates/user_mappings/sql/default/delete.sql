{# ============= Get the foreing server name from id ============= #}
{% if fsid %}
SELECT srvname as name FROM sys_foreign_server srv LEFT OUTER JOIN sys_foreign_data_wrapper fdw on fdw.oid=srvfdw
    WHERE srv.oid={{fsid}}::oid;
{% endif %}
{# ============= Drop/Delete cascade user mapping ============= #}
{% if name and data %}
DROP USER MAPPING FOR {% if data.name == "CURRENT_USER" or data.name == "PUBLIC" %}{{ data.name }}{% else %}{{ conn|qtIdent(data.name) }}{% endif %} SERVER {{ conn|qtIdent(name) }}
{% endif %}
