SELECT CASE WHEN number_of_rows > 0
  THEN TRUE
       ELSE FALSE END AS ptable
FROM (
       SELECT count(*) AS number_of_rows
       FROM sys_class
         INNER JOIN sys_partitions ON relname = tablename
       WHERE sys_class.oid = {{ tid }}::oid
     ) AS number_of_partitions
