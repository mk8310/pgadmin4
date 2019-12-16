SELECT t.oid
FROM sys_trigger t
    WHERE NOT tgisinternal
    AND tgrelid = {{tid}}::OID
    AND tgname = {{data.name|qtLiteral}};
