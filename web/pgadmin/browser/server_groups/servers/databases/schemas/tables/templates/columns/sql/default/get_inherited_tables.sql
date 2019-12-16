SELECT array_to_string(array_agg(inhrelname), ', ') inhrelname, attrname
FROM
 (SELECT
   inhparent::regclass AS inhrelname,
   a.attname AS attrname
  FROM sys_inherits i
  LEFT JOIN sys_attribute a ON
   (attrelid = inhparent AND attnum > 0)
  WHERE inhrelid = {{tid}}::oid
  ORDER BY inhseqno
 ) a
GROUP BY attrname;
