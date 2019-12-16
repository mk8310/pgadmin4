SELECT t.oid
FROM sys_trigger t
    WHERE tgrelid = {{tid}}::OID
    AND tgname = {{data.name|qtLiteral}};
