SELECT cls.relname as name
FROM sys_index idx
JOIN sys_class cls ON cls.oid=indexrelid
LEFT JOIN sys_depend dep ON (dep.classid = cls.tableoid AND
                            dep.objid = cls.oid AND
                            dep.refobjsubid = '0'
                            AND dep.refclassid=(SELECT oid
                                                FROM sys_class
                                                WHERE relname='sys_constraint') AND
                            dep.deptype='i')
LEFT OUTER JOIN sys_constraint con ON (con.tableoid = dep.refclassid AND
                                      con.oid = dep.refobjid)
WHERE indrelid = {{tid}}::oid
AND contype='{{constraint_type}}'
AND cls.oid = {{cid}}::oid;
