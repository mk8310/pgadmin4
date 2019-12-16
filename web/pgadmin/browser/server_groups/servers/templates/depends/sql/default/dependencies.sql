SET LOCAL join_collapse_limit=8;
SELECT DISTINCT dep.deptype, dep.refclassid, cl.relkind, ad.adbin, ad.adsrc,
    CASE WHEN cl.relkind IS NOT NULL THEN cl.relkind || COALESCE(dep.refobjsubid::character varying, '')
        WHEN tg.oid IS NOT NULL THEN 'T'::text
        WHEN ty.oid IS NOT NULL AND ty.typbasetype = 0 THEN 'y'::text
        WHEN ty.oid IS NOT NULL AND ty.typbasetype != 0 THEN 'd'::text
        WHEN ns.oid IS NOT NULL THEN 'n'::text
        WHEN pr.oid IS NOT NULL AND prtyp.typname = 'trigger' THEN 't'::text
        WHEN pr.oid IS NOT NULL THEN 'P'::text
        WHEN la.oid IS NOT NULL THEN 'l'::text
        WHEN rw.oid IS NOT NULL THEN 'R'::text
        WHEN co.oid IS NOT NULL THEN 'C'::text || contype
        WHEN ad.oid IS NOT NULL THEN 'A'::text
    ELSE ''
    END AS type,
    COALESCE(coc.relname, clrw.relname) AS ownertable,
    CASE WHEN cl.relname IS NOT NULL OR att.attname IS NOT NULL THEN cl.relname || COALESCE('.' || att.attname, '')
    ELSE COALESCE(cl.relname, co.conname, pr.proname, tg.tgname, ty.typname, la.lanname, rw.rulename, ns.nspname)
    END AS refname,
    COALESCE(nsc.nspname, nso.nspname, nsp.nspname, nst.nspname, nsrw.nspname) AS nspname,
    CASE WHEN inhits.inhparent IS NOT NULL THEN '1' ELSE '0' END AS is_inherits,
    CASE WHEN inhed.inhparent IS NOT NULL THEN '1' ELSE '0' END AS is_inherited
FROM sys_depend dep
LEFT JOIN sys_class cl ON dep.refobjid=cl.oid
LEFT JOIN sys_attribute att ON dep.refobjid=att.attrelid AND dep.refobjsubid=att.attnum
LEFT JOIN sys_namespace nsc ON cl.relnamespace=nsc.oid
LEFT JOIN sys_proc pr ON dep.refobjid=pr.oid
LEFT JOIN sys_namespace nsp ON pr.pronamespace=nsp.oid
LEFT JOIN sys_trigger tg ON dep.refobjid=tg.oid
LEFT JOIN sys_type ty ON dep.refobjid=ty.oid
LEFT JOIN sys_namespace nst ON ty.typnamespace=nst.oid
LEFT JOIN sys_constraint co ON dep.refobjid=co.oid
LEFT JOIN sys_class coc ON co.conrelid=coc.oid
LEFT JOIN sys_namespace nso ON co.connamespace=nso.oid
LEFT JOIN sys_rewrite rw ON dep.refobjid=rw.oid
LEFT JOIN sys_class clrw ON clrw.oid=rw.ev_class
LEFT JOIN sys_namespace nsrw ON clrw.relnamespace=nsrw.oid
LEFT JOIN sys_language la ON dep.refobjid=la.oid
LEFT JOIN sys_namespace ns ON dep.refobjid=ns.oid
LEFT JOIN sys_attrdef ad ON ad.adrelid=att.attrelid AND ad.adnum=att.attnum
LEFT JOIN sys_type prtyp ON prtyp.oid = pr.prorettype
LEFT JOIN sys_inherits inhits ON (inhits.inhrelid=dep.refobjid)
LEFT JOIN sys_inherits inhed ON (inhed.inhparent=dep.refobjid)
{{where_clause}} AND
refclassid IN ( SELECT oid FROM sys_class WHERE relname IN
   ('sys_class', 'sys_constraint', 'sys_conversion', 'sys_language', 'sys_proc', 'sys_rewrite', 'sys_namespace',
   'sys_trigger', 'sys_type', 'sys_attrdef', 'sys_event_trigger', 'sys_foreign_server', 'sys_foreign_data_wrapper'))
ORDER BY refclassid, cl.relkind
