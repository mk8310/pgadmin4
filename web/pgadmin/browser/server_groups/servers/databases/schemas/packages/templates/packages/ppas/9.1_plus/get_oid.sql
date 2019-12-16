SELECT nsp.oid
FROM sys_namespace nsp
WHERE nspparent = {{scid}}::oid
AND nspname = {{ name|qtLiteral }};
