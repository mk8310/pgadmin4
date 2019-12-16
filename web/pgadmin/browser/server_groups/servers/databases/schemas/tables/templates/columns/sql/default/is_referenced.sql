SELECT COUNT(1)
FROM sys_depend dep
    JOIN sys_class cl ON dep.classid=cl.oid AND relname='sys_rewrite'
    WHERE refobjid= {{tid}}::oid
    AND classid='sys_class'::regclass
    AND refobjsubid= {{clid|qtLiteral}};
