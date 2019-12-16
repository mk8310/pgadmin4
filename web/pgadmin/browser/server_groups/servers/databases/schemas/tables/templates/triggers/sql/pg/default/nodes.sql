SELECT t.oid, t.tgname as name, t.tgenabled AS is_enable_trigger
FROM sys_trigger t
    WHERE tgrelid = {{tid}}::OID
{% if trid %}
    AND t.oid = {{trid}}::OID
{% endif %}
    ORDER BY tgname;
