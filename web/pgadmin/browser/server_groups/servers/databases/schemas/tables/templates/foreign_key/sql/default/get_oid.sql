SELECT ct.oid,
    true as convalidated
FROM sys_constraint ct
WHERE contype='f' AND
ct.conname = {{ name|qtLiteral }};
