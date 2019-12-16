SELECT quote_ident(nspname) || '.' || quote_ident(proname) AS tfname
FROM sys_proc p, sys_namespace n, sys_language l
WHERE p.pronamespace = n.oid AND p.prolang = l.oid AND p.pronargs = 0 AND l.lanname != 'sql' AND prorettype::regtype::text = 'event_trigger'
ORDER BY nspname ASC, proname ASC
