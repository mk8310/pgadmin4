SELECT synname as name
FROM sys_synonym s
    JOIN sys_namespace ns ON s.synnamespace = ns.oid
    AND s.synnamespace = {{scid}}::oid
ORDER BY synname;
