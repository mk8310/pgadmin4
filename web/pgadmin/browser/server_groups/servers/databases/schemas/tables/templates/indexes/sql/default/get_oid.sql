SELECT DISTINCT ON(cls.relname) cls.oid
FROM sys_index idx
    JOIN sys_class cls ON cls.oid=indexrelid
    JOIN sys_class tab ON tab.oid=indrelid
    JOIN sys_namespace n ON n.oid=tab.relnamespace
WHERE indrelid = {{tid}}::OID
    AND cls.relname = {{data.name|qtLiteral}};
