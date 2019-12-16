{# ============= Fetch the primary keys for given object id ============= #}
{% if obj_id %}
SELECT at.attname, at.attnum, ty.typname
FROM sys_attribute at LEFT JOIN sys_type ty ON (ty.oid = at.atttypid)
WHERE attrelid={{obj_id}}::oid AND attnum = ANY (
    (SELECT con.conkey FROM sys_class rel LEFT OUTER JOIN sys_constraint con ON con.conrelid=rel.oid
    AND con.contype='p' WHERE rel.relkind IN ('r','s','t') AND rel.oid = {{obj_id}}::oid)::oid[])
{% endif %}
