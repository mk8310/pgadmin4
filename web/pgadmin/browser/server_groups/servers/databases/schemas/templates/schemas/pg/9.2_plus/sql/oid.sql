SELECT nsp.oid FROM sys_namespace nsp WHERE nsp.nspname = {{ schema|qtLiteral }};
