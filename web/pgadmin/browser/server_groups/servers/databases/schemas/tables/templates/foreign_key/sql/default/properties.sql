SELECT
      convalidated,
      ct.oid,
      conname as name,
      condeferrable,
      condeferred,
      confupdtype,
      confdeltype,
      CASE confmatchtype
        WHEN 's' THEN FALSE
        WHEN 'f' THEN TRUE
      END AS confmatchtype,
      conkey,
      confkey,
      confrelid,
      nl.nspname as fknsp,
      cl.relname as fktab,
      nr.nspname as refnsp,
      cr.relname as reftab,
      description as comment
FROM sys_constraint ct
JOIN sys_class cl ON cl.oid=conrelid
JOIN sys_namespace nl ON nl.oid=cl.relnamespace
JOIN sys_class cr ON cr.oid=confrelid
JOIN sys_namespace nr ON nr.oid=cr.relnamespace
LEFT OUTER JOIN sys_description des ON (des.objoid=ct.oid AND des.classoid='sys_constraint'::regclass)
WHERE contype='f' AND
conrelid = {{tid}}::oid
{% if cid %}
AND ct.oid = {{cid}}::oid
{% endif %}
ORDER BY conname
