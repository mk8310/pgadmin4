SELECT opcname
FROM sys_opclass opc,
sys_am am
WHERE opcmethod=am.oid AND
      am.amname ={{indextype|qtLiteral}} AND
      NOT opcdefault
ORDER BY 1
