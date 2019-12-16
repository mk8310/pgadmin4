SELECT conindid as oid,
    conname as name,
    NOT convalidated as convalidated
FROM sys_constraint ct
WHERE contype='x' AND
    conrelid = {{tid}}::oid
{% if exid %}
    AND conindid = {{exid}}::oid
{% endif %}
ORDER BY conname
