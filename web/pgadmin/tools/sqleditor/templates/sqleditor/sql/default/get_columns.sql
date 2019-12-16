{# ============= Fetch the columns ============= #}
{% if obj_id %}
SELECT at.attname, ty.typname, at.attnum
    FROM sys_attribute at
    LEFT JOIN sys_type ty ON (ty.oid = at.atttypid)
WHERE attrelid={{obj_id}}::oid
    AND at.attnum > 0
    AND at.attisdropped = FALSE
{% endif %}
