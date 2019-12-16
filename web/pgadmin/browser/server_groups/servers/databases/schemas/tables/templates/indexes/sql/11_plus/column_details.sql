SELECT
    i.indexrelid,
    CASE i.indoption[i.attnum - 1]
    WHEN 0 THEN ARRAY['ASC', 'NULLS LAST']
    WHEN 1 THEN ARRAY['DESC', 'NULLS LAST']
    WHEN 2 THEN ARRAY['ASC', 'NULLS FIRST']
    WHEN 3 THEN ARRAY['DESC', 'NULLS FIRST']
    ELSE ARRAY['UNKNOWN OPTION' || i.indoption[i.attnum - 1]::text, '']
    END::text[] AS options,
    i.attnum,
    sys_get_indexdef(i.indexrelid, i.attnum, true) as attdef,
    CASE WHEN (o.opcdefault = FALSE) THEN o.opcname ELSE null END AS opcname,
    op.oprname AS oprname,
	CASE WHEN length(nspc.nspname) > 0 AND length(coll.collname) > 0  THEN
	  concat(quote_ident(nspc.nspname), '.', quote_ident(coll.collname))
	ELSE '' END AS collnspname
FROM (
      SELECT
          indexrelid, i.indoption, i.indclass,
          unnest(ARRAY(SELECT generate_series(1, i.indnkeyatts) AS n)) AS attnum
      FROM
          sys_index i
      WHERE i.indexrelid = {{idx}}::OID
) i
    LEFT JOIN sys_opclass o ON (o.oid = i.indclass[i.attnum - 1])
    LEFT OUTER JOIN sys_constraint c ON (c.conindid = i.indexrelid)
    LEFT OUTER JOIN sys_operator op ON (op.oid = c.conexclop[i.attnum])
    LEFT JOIN sys_attribute a ON (a.attrelid = i.indexrelid AND a.attnum = i.attnum)
    LEFT OUTER JOIN sys_collation coll ON a.attcollation=coll.oid
    LEFT OUTER JOIN sys_namespace nspc ON coll.collnamespace=nspc.oid
ORDER BY i.attnum;
