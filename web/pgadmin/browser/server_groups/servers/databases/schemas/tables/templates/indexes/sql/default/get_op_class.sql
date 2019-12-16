SELECT opcname,  opcmethod
FROM sys_opclass
    WHERE opcmethod = {{oid}}::OID
    AND NOT opcdefault
    ORDER BY 1;
