SELECT att.attname as name
FROM sys_attribute att
    WHERE att.attrelid = {{tid}}::oid
    AND att.attnum IN ({{ clist }})
    AND att.attisdropped IS FALSE
    ORDER BY att.attnum
