SELECT DISTINCT dep.deptype, dep.classid, cl.relkind, ad.adbin, sys_get_expr(ad.adbin, ad.adrelid) as adsrc,
    CASE WHEN cl.relkind IS NOT NULL THEN cl.relkind || COALESCE(dep.objsubid::text, '')
        WHEN tg.oid IS NOT NULL THEN 'T'::text
        WHEN ty.oid IS NOT NULL THEN 'y'::text
        WHEN ns.oid IS NOT NULL THEN 'n'::text
        WHEN pr.oid IS NOT NULL AND prtyp.typname = 'trigger' THEN 't'::text
        WHEN pr.oid IS NOT NULL THEN 'P'::text
        WHEN la.oid IS NOT NULL THEN 'l'::text
        WHEN rw.oid IS NOT NULL THEN 'R'::text
        WHEN co.oid IS NOT NULL THEN 'C'::text || contype
        WHEN ad.oid IS NOT NULL THEN 'A'::text
        WHEN fs.oid IS NOT NULL THEN 'F'::text
        WHEN fdw.oid IS NOT NULL THEN 'f'::text
        ELSE ''
    END AS type,
    COALESCE(coc.relname, clrw.relname) AS ownertable,
    CASE WHEN cl.relname IS NOT NULL AND att.attname IS NOT NULL THEN cl.relname || COALESCE('.' || att.attname, '')
    ELSE COALESCE(cl.relname, co.conname, pr.proname, tg.tgname, ty.typname, la.lanname, rw.rulename, ns.nspname, fs.srvname, fdw.fdwname)
    END AS refname,
    COALESCE(nsc.nspname, nso.nspname, nsp.nspname, nst.nspname, nsrw.nspname) AS nspname,
    CASE WHEN inhits.inhparent IS NOT NULL THEN '1' ELSE '0' END AS is_inherits,
    CASE WHEN inhed.inhparent IS NOT NULL THEN '1' ELSE '0' END AS is_inherited
FROM sys_depend dep
LEFT JOIN sys_class cl ON dep.objid=cl.oid
LEFT JOIN sys_attribute att ON dep.objid=att.attrelid AND dep.objsubid=att.attnum
LEFT JOIN sys_namespace nsc ON cl.relnamespace=nsc.oid
LEFT JOIN sys_proc pr ON dep.objid=pr.oid
LEFT JOIN sys_namespace nsp ON pr.pronamespace=nsp.oid
LEFT JOIN sys_trigger tg ON dep.objid=tg.oid
LEFT JOIN sys_type ty ON dep.objid=ty.oid
LEFT JOIN sys_namespace nst ON ty.typnamespace=nst.oid
LEFT JOIN sys_constraint co ON dep.objid=co.oid
LEFT JOIN sys_class coc ON co.conrelid=coc.oid
LEFT JOIN sys_namespace nso ON co.connamespace=nso.oid
LEFT JOIN sys_rewrite rw ON dep.objid=rw.oid
LEFT JOIN sys_class clrw ON clrw.oid=rw.ev_class
LEFT JOIN sys_namespace nsrw ON clrw.relnamespace=nsrw.oid
LEFT JOIN sys_language la ON dep.objid=la.oid
LEFT JOIN sys_namespace ns ON dep.objid=ns.oid
LEFT JOIN sys_attrdef ad ON ad.oid=dep.objid
LEFT JOIN sys_foreign_server fs ON fs.oid=dep.objid
LEFT JOIN sys_foreign_data_wrapper fdw ON fdw.oid=dep.objid
LEFT JOIN sys_type prtyp ON prtyp.oid = pr.prorettype
LEFT JOIN sys_inherits inhits ON (inhits.inhrelid=dep.objid)
LEFT JOIN sys_inherits inhed ON (inhed.inhparent=dep.objid)
{{where_clause}} AND
classid IN ( SELECT oid FROM sys_class WHERE relname IN
   ('sys_class', 'sys_constraint', 'sys_conversion', 'sys_language', 'sys_proc', 'sys_rewrite', 'sys_namespace',
   'sys_trigger', 'sys_type', 'sys_attrdef', 'sys_event_trigger', 'sys_foreign_server', 'sys_foreign_data_wrapper'))
ORDER BY classid, cl.relkind
