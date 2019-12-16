SELECT
    attnum, attname
FROM sys_attribute att
WHERE att.attrelid = {{coid}}::oid
  AND att.attnum > 0
  AND att.attisdropped IS FALSE
ORDER BY att.attnum
