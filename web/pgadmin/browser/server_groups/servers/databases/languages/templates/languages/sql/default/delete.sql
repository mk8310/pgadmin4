{# ============= Get the language name using oid ============= #}
{% if lid %}
    SELECT lanname FROM sys_language WHERE oid = {{lid}}::oid;
{% endif %}
{# ============= Drop the language ============= #}
{% if lname %}
    DROP LANGUAGE {{ conn|qtIdent(lname) }} {% if cascade %}CASCADE{% endif%};
{% endif %}
