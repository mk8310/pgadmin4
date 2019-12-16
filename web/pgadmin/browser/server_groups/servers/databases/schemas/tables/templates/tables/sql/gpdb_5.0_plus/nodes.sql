SELECT rel.oid, rel.relname AS name,
    (SELECT count(*) FROM sys_trigger WHERE tgrelid=rel.oid) AS triggercount,
    (SELECT count(*) FROM sys_trigger WHERE tgrelid=rel.oid AND tgenabled = 'O') AS has_enable_triggers,
    (CASE WHEN (SELECT count(*) from sys_partition where parrelid = rel.oid) > 0 THEN true ELSE false END) AS is_partitioned,
    (SELECT count(1) FROM sys_inherits WHERE inhrelid=rel.oid LIMIT 1) as is_inherits,
    (SELECT count(1) FROM sys_inherits WHERE inhparent=rel.oid LIMIT 1) as is_inherited
FROM sys_class rel
    WHERE rel.relkind IN ('r','s','t') AND rel.relnamespace = {{ scid }}::oid
      AND rel.relname NOT IN (SELECT partitiontablename FROM sys_partitions)
      AND rel.oid NOT IN (SELECT reloid from sys_exttable)
    {% if tid %}
      AND rel.oid = {{tid}}::OID
    {% endif %}
    ORDER BY rel.relname;
