SELECT rel.oid, rel.relname AS name,
    (SELECT count(*) FROM sys_trigger WHERE tgrelid=rel.oid) AS triggercount,
    (SELECT count(*) FROM sys_trigger WHERE tgrelid=rel.oid AND tgenabled = 'O') AS has_enable_triggers,
    (SELECT count(1) FROM sys_inherits WHERE inhrelid=rel.oid LIMIT 1) as is_inherits,
    (SELECT count(1) FROM sys_inherits WHERE inhparent=rel.oid LIMIT 1) as is_inherited
FROM sys_class rel
    WHERE rel.relkind IN ('r','s','t') AND rel.relnamespace = {{ scid }}::oid
    {% if tid %} AND rel.oid = {{tid}}::OID {% endif %}
    ORDER BY rel.relname;
