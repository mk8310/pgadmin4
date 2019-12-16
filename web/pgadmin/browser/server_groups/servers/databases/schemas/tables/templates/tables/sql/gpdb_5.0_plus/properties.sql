SELECT *,
	(CASE when pre_coll_inherits is NULL then ARRAY[]::varchar[] else pre_coll_inherits END) as coll_inherits
  {% if tid %}, (CASE WHEN is_partitioned THEN (SELECT substring(sys_get_partition_def({{ tid }}::oid, true) from 14)) ELSE '' END) AS partition_scheme {% endif %}
FROM (
	SELECT rel.oid, rel.relname AS name, rel.reltablespace AS spcoid,rel.relacl AS relacl_str,
		(CASE WHEN length(spc.spcname) > 0 THEN spc.spcname ELSE
			(SELECT sp.spcname FROM sys_database dtb
			JOIN sys_tablespace sp ON dtb.dattablespace=sp.oid
			WHERE dtb.oid = {{ did }}::oid)
		END) as spcname,
		(select nspname FROM sys_namespace WHERE oid = {{scid}}::oid ) as schema,
		sys_get_userbyid(rel.relowner) AS relowner, rel.relhasoids,
		rel.relhassubclass, rel.reltuples::bigint, des.description, con.conname, con.conkey,
		EXISTS(select 1 FROM sys_trigger
				JOIN sys_proc pt ON pt.oid=tgfoid AND pt.proname='logtrigger'
				JOIN sys_proc pc ON pc.pronamespace=pt.pronamespace AND pc.proname='slonyversion'
				WHERE tgrelid=rel.oid) AS isrepl,
		(SELECT count(*) FROM sys_trigger WHERE tgrelid=rel.oid) AS triggercount,
		(SELECT ARRAY(SELECT CASE WHEN (nspname NOT LIKE 'pg\_%') THEN
							quote_ident(nspname)||'.'||quote_ident(c.relname)
							ELSE quote_ident(c.relname) END AS inherited_tables
			FROM sys_inherits i
			JOIN sys_class c ON c.oid = i.inhparent
			JOIN sys_namespace n ON n.oid=c.relnamespace
			WHERE i.inhrelid = rel.oid ORDER BY inhseqno)) AS pre_coll_inherits,
		(SELECT count(*)
			FROM sys_inherits i
				JOIN sys_class c ON c.oid = i.inhparent
				JOIN sys_namespace n ON n.oid=c.relnamespace
			WHERE i.inhrelid = rel.oid) AS inherited_tables_cnt,
		false AS relpersistence,
		substring(array_to_string(rel.reloptions, ',') FROM 'fillfactor=([0-9]*)') AS fillfactor,
		substring(array_to_string(rel.reloptions, ',') FROM 'compresslevel=([0-9]*)') AS compresslevel,
		substring(array_to_string(rel.reloptions, ',') FROM 'blocksize=([0-9]*)') AS blocksize,
		substring(array_to_string(rel.reloptions, ',') FROM 'orientation=(row|column)') AS orientation,
		substring(array_to_string(rel.reloptions, ',') FROM 'appendonly=(true|false)')::boolean AS appendonly,
		substring(array_to_string(rel.reloptions, ',') FROM 'compresstype=(zlib|quicklz|rle_type|none)') AS compresstype,
		(CASE WHEN (substring(array_to_string(rel.reloptions, ',') FROM 'autovacuum_enabled=([a-z|0-9]*)') = 'true')
			THEN true ELSE false END) AS autovacuum_enabled,
		substring(array_to_string(rel.reloptions, ',') FROM 'autovacuum_vacuum_threshold=([0-9]*)') AS autovacuum_vacuum_threshold,
		substring(array_to_string(rel.reloptions, ',') FROM 'autovacuum_vacuum_scale_factor=([0-9]*[.]?[0-9]*)') AS autovacuum_vacuum_scale_factor,
		substring(array_to_string(rel.reloptions, ',') FROM 'autovacuum_analyze_threshold=([0-9]*)') AS autovacuum_analyze_threshold,
		substring(array_to_string(rel.reloptions, ',') FROM 'autovacuum_analyze_scale_factor=([0-9]*[.]?[0-9]*)') AS autovacuum_analyze_scale_factor,
		substring(array_to_string(rel.reloptions, ',') FROM 'autovacuum_vacuum_cost_delay=([0-9]*)') AS autovacuum_vacuum_cost_delay,
		substring(array_to_string(rel.reloptions, ',') FROM 'autovacuum_vacuum_cost_limit=([0-9]*)') AS autovacuum_vacuum_cost_limit,
		substring(array_to_string(rel.reloptions, ',') FROM 'autovacuum_freeze_min_age=([0-9]*)') AS autovacuum_freeze_min_age,
		substring(array_to_string(rel.reloptions, ',') FROM 'autovacuum_freeze_max_age=([0-9]*)') AS autovacuum_freeze_max_age,
		substring(array_to_string(rel.reloptions, ',') FROM 'autovacuum_freeze_table_age=([0-9]*)') AS autovacuum_freeze_table_age,
		(CASE WHEN (substring(array_to_string(tst.reloptions, ',') FROM 'autovacuum_enabled=([a-z|0-9]*)') =  'true')
			THEN true ELSE false END) AS toast_autovacuum_enabled,
		substring(array_to_string(tst.reloptions, ',') FROM 'autovacuum_vacuum_threshold=([0-9]*)') AS toast_autovacuum_vacuum_threshold,
		substring(array_to_string(tst.reloptions, ',') FROM 'autovacuum_vacuum_scale_factor=([0-9]*[.]?[0-9]*)') AS toast_autovacuum_vacuum_scale_factor,
		substring(array_to_string(tst.reloptions, ',') FROM 'autovacuum_analyze_threshold=([0-9]*)') AS toast_autovacuum_analyze_threshold,
		substring(array_to_string(tst.reloptions, ',') FROM 'autovacuum_analyze_scale_factor=([0-9]*[.]?[0-9]*)') AS toast_autovacuum_analyze_scale_factor,
		substring(array_to_string(tst.reloptions, ',') FROM 'autovacuum_vacuum_cost_delay=([0-9]*)') AS toast_autovacuum_vacuum_cost_delay,
		substring(array_to_string(tst.reloptions, ',') FROM 'autovacuum_vacuum_cost_limit=([0-9]*)') AS toast_autovacuum_vacuum_cost_limit,
		substring(array_to_string(tst.reloptions, ',') FROM 'autovacuum_freeze_min_age=([0-9]*)') AS toast_autovacuum_freeze_min_age,
		substring(array_to_string(tst.reloptions, ',') FROM 'autovacuum_freeze_max_age=([0-9]*)') AS toast_autovacuum_freeze_max_age,
		substring(array_to_string(tst.reloptions, ',') FROM 'autovacuum_freeze_table_age=([0-9]*)') AS toast_autovacuum_freeze_table_age,
		array_to_string(rel.reloptions, ',') AS table_vacuum_settings_str,
		array_to_string(tst.reloptions, ',') AS toast_table_vacuum_settings_str,
		rel.reloptions AS reloptions, tst.reloptions AS toast_reloptions, NULL AS reloftype, typ.typname AS typname,
		typ.typrelid AS typoid,
		(CASE WHEN rel.reltoastrelid = 0 THEN false ELSE true END) AS hastoasttable,
			-- Added for pgAdmin4
		(CASE WHEN array_length(rel.reloptions, 1) > 0 THEN true ELSE false END) AS autovacuum_custom,
		(CASE WHEN array_length(tst.reloptions, 1) > 0 AND rel.reltoastrelid != 0 THEN true ELSE false END) AS toast_autovacuum,

		ARRAY[]::varchar[] AS seclabels,
		(CASE WHEN rel.oid <= {{ datlastsysoid}}::oid THEN true ElSE false END) AS is_sys_table,

		gdp.attrnums AS distribution,
    (CASE WHEN (SELECT count(*) from sys_partition where parrelid = rel.oid) > 0 THEN true ELSE false END) AS is_partitioned


	FROM sys_class rel
		LEFT OUTER JOIN sys_tablespace spc on spc.oid=rel.reltablespace
		LEFT OUTER JOIN sys_description des ON (des.objoid=rel.oid AND des.objsubid=0 AND des.classoid='sys_class'::regclass)
		LEFT OUTER JOIN sys_constraint con ON con.conrelid=rel.oid AND con.contype='p'
		LEFT OUTER JOIN sys_class tst ON tst.oid = rel.reltoastrelid
		LEFT OUTER JOIN gp_distribution_policy gdp ON gdp.localoid = rel.oid
		LEFT OUTER JOIN sys_type typ ON typ.oid = rel.reltype

	 WHERE rel.relkind IN ('r','s','t') AND rel.relnamespace = {{ scid }}
	{% if tid %}  AND rel.oid = {{ tid }}::oid {% endif %}
) AS TableInformation
 ORDER BY name
