{# ============= Get the handlers of foreign data wrapper ============= #}
SELECT nspname, proname as fdwhan,
       quote_ident(nspname)||'.'||quote_ident(proname) AS schema_prefix_fdw_hand
FROM sys_proc p JOIN sys_namespace nsp ON nsp.oid=pronamespace
WHERE pronargs=0 AND prorettype=3115;
