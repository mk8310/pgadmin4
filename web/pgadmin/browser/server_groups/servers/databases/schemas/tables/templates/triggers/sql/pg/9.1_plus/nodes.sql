SELECT t.oid, t.tgname as name, t.tgenabled AS is_enable_trigger
FROM sys_trigger t
    WHERE NOT tgisinternal
    AND tgrelid = {{tid}}::OID
{% if trid %}
    AND t.oid = {{trid}}::OID
{% endif %}
    ORDER BY tgname;
