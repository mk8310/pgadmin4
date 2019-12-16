SELECT c.oid, conname as name
    FROM sys_constraint c
WHERE contype = 'c'
    AND conrelid = {{ tid }}::oid
{% if cid %}
    AND c.oid = {{ cid }}::oid
{% endif %}
