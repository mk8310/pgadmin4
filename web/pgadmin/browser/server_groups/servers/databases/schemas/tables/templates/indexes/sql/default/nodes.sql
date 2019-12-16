SELECT DISTINCT ON(cls.relname) cls.oid, cls.relname as name
FROM sys_index idx
    JOIN sys_class cls ON cls.oid=indexrelid
    JOIN sys_class tab ON tab.oid=indrelid
    LEFT OUTER JOIN sys_tablespace ta on ta.oid=cls.reltablespace
    JOIN sys_namespace n ON n.oid=tab.relnamespace
    JOIN sys_am am ON am.oid=cls.relam
    LEFT JOIN sys_depend dep ON (dep.classid = cls.tableoid AND dep.objid = cls.oid AND dep.refobjsubid = '0' AND dep.refclassid=(SELECT oid FROM sys_class WHERE relname='sys_constraint') AND dep.deptype='i')
    LEFT OUTER JOIN sys_constraint con ON (con.tableoid = dep.refclassid AND con.oid = dep.refobjid)
WHERE indrelid = {{tid}}::OID
    AND conname is NULL
{% if idx %}
    AND cls.oid = {{ idx }}::OID
{% endif %}
    ORDER BY cls.relname
