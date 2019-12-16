{% for n in range(colcnt|int) %}
{% if loop.index != 1 %}
UNION
{% endif %}
SELECT
  i.indoption[{{loop.index -1}}] AS options,
  sys_get_indexdef(i.indexrelid, {{loop.index}}, true) AS coldef,
  NULL as op.oprname,
  CASE WHEN (o.opcdefault = FALSE) THEN o.opcname ELSE null END AS opcname,
  (SELECT setting AS value
       FROM sys_settings
       WHERE name='lc_collate') AS collname,
  '' as collnspname,
  format_type(ty.oid,NULL) AS col_type
FROM sys_index i
JOIN sys_attribute a ON (a.attrelid = i.indexrelid AND attnum = {{loop.index}})
JOIN sys_type ty ON ty.oid=a.atttypid
LEFT OUTER JOIN sys_opclass o ON (o.oid = i.indclass[{{loop.index -1}}])
WHERE i.indexrelid = {{cid}}::oid
{% endfor %}
