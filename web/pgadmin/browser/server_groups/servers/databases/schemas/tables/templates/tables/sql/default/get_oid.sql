SELECT rel.oid as tid
FROM sys_class rel
WHERE rel.relkind IN ('r','s','t')
AND rel.relnamespace = {{ scid }}::oid
AND rel.relname = {{data.name|qtLiteral}}
