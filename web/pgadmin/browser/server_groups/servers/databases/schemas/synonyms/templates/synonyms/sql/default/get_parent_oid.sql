SELECT synnamespace as scid
    FROM sys_synonym s
WHERE synname = {{ data.name|qtLiteral }}
AND synnamespace IN
    ( SELECT oid FROM sys_namespace WHERE nspname = {{ data.schema|qtLiteral }} );
