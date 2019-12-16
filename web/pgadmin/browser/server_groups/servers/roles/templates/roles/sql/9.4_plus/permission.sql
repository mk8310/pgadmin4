SELECT
    rolname, rolcanlogin, rolsuper AS rolcatupdate, rolsuper
FROM
    sys_roles
WHERE oid = {{ rid }}::OID
