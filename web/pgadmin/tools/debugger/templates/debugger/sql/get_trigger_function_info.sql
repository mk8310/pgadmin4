{### To fetch trigger function information ###}
SELECT t.oid, t.xmin, t.*, relname, CASE WHEN relkind = 'r' THEN TRUE ELSE FALSE END AS parentistable,   nspname, des.description, l.lanname, p.prosrc,
  COALESCE(substring(sys_get_triggerdef(t.oid), 'WHEN (.*) EXECUTE PROCEDURE'), substring(sys_get_triggerdef(t.oid), 'WHEN (.*)  \$trigger')) AS whenclause
  FROM sys_trigger t
  JOIN sys_class cl ON cl.oid=tgrelid
  JOIN sys_namespace na ON na.oid=relnamespace
  LEFT OUTER JOIN sys_description des ON (des.objoid=t.oid AND des.classoid='sys_trigger'::regclass)
  LEFT OUTER JOIN sys_proc p ON p.oid=t.tgfoid
  LEFT OUTER JOIN sys_language l ON l.oid=p.prolang
 WHERE NOT tgisinternal
  AND tgrelid = {{table_id}}::oid AND t.oid = {{trigger_id}}::oid
 ORDER BY tgname
