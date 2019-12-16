SELECT ct.conindid AS oid
FROM sys_constraint ct
WHERE contype='x' AND
ct.conname = {{ name|qtLiteral }};
