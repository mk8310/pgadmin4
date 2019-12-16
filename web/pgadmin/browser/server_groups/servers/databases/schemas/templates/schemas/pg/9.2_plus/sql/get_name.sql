SELECT nsp.nspname FROM sys_namespace nsp WHERE nsp.oid = {{ scid|qtLiteral }};
