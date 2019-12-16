SELECT x.urilocation, x.execlocation, x.fmttype, x.fmtopts, x.command,
    x.rejectlimit, x.rejectlimittype,
    (SELECT relname
        FROM sys_catalog.sys_class
      WHERE Oid=x.fmterrtbl) AS errtblname,
    x.fmterrtbl = x.reloid AS errortofile ,
    sys_catalog.sys_encoding_to_char(x.encoding),
    x.writable,
    array_to_string(ARRAY(
      SELECT sys_catalog.quote_ident(option_name) || ' ' ||
      sys_catalog.quote_literal(option_value)
      FROM sys_options_to_table(x.options)
      ORDER BY option_name
      ), E',\n    ') AS options,
    gdp.attrnums AS distribution,
    c.relname AS name,
    nsp.nspname AS namespace
FROM sys_catalog.sys_exttable x,
  sys_catalog.sys_class c
  LEFT JOIN sys_catalog.sys_namespace nsp ON nsp.oid = c.relnamespace
  LEFT JOIN gp_distribution_policy gdp ON gdp.localoid = c.oid
WHERE x.reloid = c.oid AND c.oid = {{ table_oid }}::oid;
