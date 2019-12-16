SELECT cls.oid,
    cls.relname as name,
    indnatts as col_count,
    amname,
    CASE WHEN length(spcname) > 0 THEN spcname ELSE
        (SELECT sp.spcname FROM sys_database dtb
        JOIN sys_tablespace sp ON dtb.dattablespace=sp.oid
        WHERE dtb.oid = {{ did }}::oid)
    END as spcname,
    CASE contype
        WHEN 'p' THEN desp.description
        WHEN 'u' THEN desp.description
        WHEN 'x' THEN desp.description
        ELSE des.description
    END AS comment,
    condeferrable,
    condeferred,
    substring(array_to_string(cls.reloptions, ',') from 'fillfactor=([0-9]*)') AS fillfactor,
    sys_get_expr(idx.indpred, idx.indrelid, true) AS indconstraint
FROM sys_index idx
JOIN sys_class cls ON cls.oid=indexrelid
JOIN sys_class tab ON tab.oid=indrelid
LEFT OUTER JOIN sys_tablespace ta on ta.oid=cls.reltablespace
JOIN sys_namespace n ON n.oid=tab.relnamespace
JOIN sys_am am ON am.oid=cls.relam
LEFT JOIN sys_depend dep ON (dep.classid = cls.tableoid AND dep.objid = cls.oid AND dep.refobjsubid = '0' AND dep.refclassid=(SELECT oid FROM sys_class WHERE relname='sys_constraint') AND dep.deptype='i')
LEFT OUTER JOIN sys_constraint con ON (con.tableoid = dep.refclassid AND con.oid = dep.refobjid)
LEFT OUTER JOIN sys_description des ON (des.objoid=cls.oid AND des.classoid='sys_class'::regclass)
LEFT OUTER JOIN sys_description desp ON (desp.objoid=con.oid AND desp.objsubid = 0 AND desp.classoid='sys_constraint'::regclass)
WHERE indrelid = {{tid}}::oid
{% if cid %}
AND cls.oid = {{cid}}::oid
{% endif %}
AND contype='x'
ORDER BY cls.relname
