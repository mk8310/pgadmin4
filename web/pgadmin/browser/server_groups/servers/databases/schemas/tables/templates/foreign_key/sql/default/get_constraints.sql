SELECT   cls.oid, cls.relname as idxname, indnatts as col_count
  FROM sys_index idx
  JOIN sys_class cls ON cls.oid=indexrelid
  LEFT JOIN sys_depend dep ON (dep.classid = cls.tableoid AND dep.objid = cls.oid AND dep.refobjsubid = '0' AND dep.refclassid=(SELECT oid FROM sys_class WHERE relname='sys_constraint') AND dep.deptype='i')
  LEFT OUTER JOIN sys_constraint con ON (con.tableoid = dep.refclassid AND con.oid = dep.refobjid)
WHERE idx.indrelid = {{tid}}::oid
    AND con.contype='p'

UNION

SELECT  cls.oid, cls.relname as idxname, indnatts
    FROM sys_index idx
    JOIN sys_class cls ON cls.oid=indexrelid
    LEFT JOIN sys_depend dep ON (dep.classid = cls.tableoid AND dep.objid = cls.oid AND dep.refobjsubid = '0' AND dep.refclassid=(SELECT oid FROM sys_class WHERE relname='sys_constraint') AND dep.deptype='i')
    LEFT OUTER JOIN sys_constraint con ON (con.tableoid = dep.refclassid AND con.oid = dep.refobjid)
WHERE idx.indrelid = {{tid}}::oid
    AND con.contype='x'

UNION

SELECT  cls.oid, cls.relname as idxname, indnatts
    FROM sys_index idx
    JOIN sys_class cls ON cls.oid=indexrelid
    LEFT JOIN sys_depend dep ON (dep.classid = cls.tableoid AND dep.objid = cls.oid AND dep.refobjsubid = '0' AND dep.refclassid=(SELECT oid FROM sys_class WHERE relname='sys_constraint') AND dep.deptype='i')
    LEFT OUTER JOIN sys_constraint con ON (con.tableoid = dep.refclassid AND con.oid = dep.refobjid)
WHERE idx.indrelid = {{tid}}::oid
    AND con.contype='u'

UNION

SELECT  cls.oid, cls.relname as idxname, indnatts
    FROM sys_index idx
    JOIN sys_class cls ON cls.oid=indexrelid
    LEFT JOIN sys_depend dep ON (dep.classid = cls.tableoid AND dep.objid = cls.oid AND dep.refobjsubid = '0' AND dep.refclassid=(SELECT oid FROM sys_class WHERE relname='sys_constraint') AND dep.deptype='i')
    LEFT OUTER JOIN sys_constraint con ON (con.tableoid = dep.refclassid AND con.oid = dep.refobjid)
WHERE idx.indrelid = {{tid}}::oid
   AND conname IS NULL
