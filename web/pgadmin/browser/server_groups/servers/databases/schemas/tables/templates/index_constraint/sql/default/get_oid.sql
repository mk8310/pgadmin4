SELECT ct.conindid as oid
FROM sys_constraint ct
WHERE contype='{{constraint_type}}' AND
ct.conname = {{ name|qtLiteral }};
