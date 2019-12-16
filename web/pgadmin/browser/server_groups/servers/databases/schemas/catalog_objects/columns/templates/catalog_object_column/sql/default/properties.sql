SELECT
    att.*, def.*, sys_catalog.sys_get_expr(def.adbin, def.adrelid) AS defval,
        CASE WHEN att.attndims > 0 THEN 1 ELSE 0 END AS isarray,
        format_type(ty.oid,NULL) AS typname,
        format_type(ty.oid,att.atttypmod) AS displaytypname,
        tn.nspname as typnspname, et.typname as elemtypname,
        ty.typstorage AS defaultstorage, cl.relname, na.nspname,
	att.attstattarget, description, cs.relname AS sername,
	ns.nspname AS serschema,
	(SELECT count(1) FROM sys_type t2 WHERE t2.typname=ty.typname) > 1 AS isdup,
	indkey, coll.collname, nspc.nspname as collnspname , attoptions,
	-- Start pgAdmin4, added to save time on client side parsing
	CASE WHEN length(coll.collname) > 0 AND length(nspc.nspname) > 0  THEN
	  concat(quote_ident(nspc.nspname),'.',quote_ident(coll.collname))
	ELSE '' END AS collspcname,
	CASE WHEN strpos(format_type(ty.oid,att.atttypmod), '.') > 0 THEN
	  split_part(format_type(ty.oid,att.atttypmod), '.', 2)
	ELSE format_type(ty.oid,att.atttypmod) END AS cltype,
	-- End pgAdmin4
	EXISTS(SELECT 1 FROM sys_constraint WHERE conrelid=att.attrelid AND contype='f' AND att.attnum=ANY(conkey)) As isfk,
	(SELECT array_agg(label) FROM sys_seclabels sl1 WHERE sl1.objoid=att.attrelid AND sl1.objsubid=att.attnum) AS labels,
	(SELECT array_agg(provider) FROM sys_seclabels sl2 WHERE sl2.objoid=att.attrelid AND sl2.objsubid=att.attnum) AS providers
FROM sys_attribute att
  JOIN sys_type ty ON ty.oid=atttypid
  JOIN sys_namespace tn ON tn.oid=ty.typnamespace
  JOIN sys_class cl ON cl.oid=att.attrelid
  JOIN sys_namespace na ON na.oid=cl.relnamespace
  LEFT OUTER JOIN sys_type et ON et.oid=ty.typelem
  LEFT OUTER JOIN sys_attrdef def ON adrelid=att.attrelid AND adnum=att.attnum
  LEFT OUTER JOIN sys_description des ON (des.objoid=att.attrelid AND des.objsubid=att.attnum AND des.classoid='sys_class'::regclass)
  LEFT OUTER JOIN (sys_depend JOIN sys_class cs ON objid=cs.oid AND classid='sys_class'::regclass AND cs.relkind='S') ON refobjid=att.attrelid AND refobjsubid=att.attnum
  LEFT OUTER JOIN sys_namespace ns ON ns.oid=cs.relnamespace
  LEFT OUTER JOIN sys_index pi ON pi.indrelid=att.attrelid AND indisprimary
  LEFT OUTER JOIN sys_collation coll ON att.attcollation=coll.oid
  LEFT OUTER JOIN sys_namespace nspc ON coll.collnamespace=nspc.oid
WHERE att.attrelid = {{coid}}::oid{% if clid %}
  AND att.attnum = {{clid}}::int
{% endif %}
  AND att.attnum > 0
  AND att.attisdropped IS FALSE
ORDER BY att.attnum
