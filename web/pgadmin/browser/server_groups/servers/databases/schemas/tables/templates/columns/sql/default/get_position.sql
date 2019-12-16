SELECT att.attnum
FROM sys_attribute att
    WHERE att.attrelid = {{tid}}::oid
    AND att.attname = {{data.name|qtLiteral(True)}}
