{% for n in range(colcnt|int) %}
{% if loop.index != 1 %}
UNION
{% endif %}
SELECT
  i.indoption[{{loop.index -1}}] AS options,
  sys_get_indexdef(i.indexrelid, {{loop.index}}, true) AS coldef,
  op.oprname,
  CASE WHEN (o.opcdefault = FALSE) THEN o.opcname ELSE null END AS opcname
,
  coll.collname,
  nspc.nspname as collnspname,
  format_type(ty.oid,NULL) AS datatype
FROM sys_index i
JOIN sys_attribute a ON (a.attrelid = i.indexrelid AND attnum = {{loop.index}})
JOIN sys_type ty ON ty.oid=a.atttypid
LEFT OUTER JOIN sys_opclass o ON (o.oid = i.indclass[{{loop.index -1}}])
LEFT OUTER JOIN sys_constraint c ON (c.conindid = i.indexrelid) LEFT OUTER JOIN sys_operator op ON (op.oid = c.conexclop[{{loop.index}}])
LEFT OUTER JOIN sys_collation coll ON a.attcollation=coll.oid
LEFT OUTER JOIN sys_namespace nspc ON coll.collnamespace=nspc.oid
WHERE i.indexrelid = {{cid}}::oid
{% endfor %}
