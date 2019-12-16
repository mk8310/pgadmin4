SELECT att.attname as name, att.*, def.*, sys_catalog.sys_get_expr(def.adbin, def.adrelid) AS defval,
        CASE WHEN att.attndims > 0 THEN 1 ELSE 0 END AS isarray,
        format_type(ty.oid,NULL) AS typname,
        format_type(ty.oid,att.atttypmod) AS displaytypname,
        CASE WHEN ty.typelem > 0 THEN ty.typelem ELSE ty.oid END as elemoid,
        tn.nspname as typnspname, et.typname as elemtypname,
        ty.typstorage AS defaultstorage, cl.relname, na.nspname,
        quote_ident(na.nspname) || '.' || quote_ident(cl.relname) AS parent_tbl,
	att.attstattarget, description, cs.relname AS sername,
	ns.nspname AS serschema,
	(SELECT count(1) FROM sys_type t2 WHERE t2.typname=ty.typname) > 1 AS isdup,
	indkey, NULL as attoptions,
	format_type(ty.oid,att.atttypmod) AS cltype,
	EXISTS(SELECT 1 FROM sys_constraint WHERE conrelid=att.attrelid AND contype='f' AND att.attnum=ANY(conkey)) As is_fk,
	NULL AS seclabels,
	(CASE WHEN (att.attnum < 1) THEN true ElSE false END) AS is_sys_column
FROM sys_attribute att
  JOIN sys_type ty ON ty.oid=atttypid
  JOIN sys_namespace tn ON tn.oid=ty.typnamespace
  JOIN sys_class cl ON cl.oid=att.attrelid
  JOIN sys_namespace na ON na.oid=cl.relnamespace
  LEFT OUTER JOIN sys_type et ON et.oid=ty.typelem
  LEFT OUTER JOIN sys_attrdef def ON adrelid=att.attrelid AND adnum=att.attnum
  LEFT OUTER JOIN sys_description des ON (des.objoid=att.attrelid AND des.objsubid=att.attnum AND des.classoid='sys_class'::regclass)
  LEFT OUTER JOIN (sys_depend JOIN sys_class cs ON classid='sys_class'::regclass AND objid=cs.oid AND cs.relkind='S') ON refobjid=att.attrelid AND refobjsubid=att.attnum
  LEFT OUTER JOIN sys_namespace ns ON ns.oid=cs.relnamespace
  LEFT OUTER JOIN sys_index pi ON pi.indrelid=att.attrelid AND indisprimary
WHERE att.attrelid = {{tid}}::oid
{% if clid %}
    AND att.attnum = {{clid}}::int
{% endif %}
{### To show system objects ###}
{% if not show_sys_objects %}
    AND att.attnum > 0
{% endif %}
    AND att.attisdropped IS FALSE
    ORDER BY att.attnum;
