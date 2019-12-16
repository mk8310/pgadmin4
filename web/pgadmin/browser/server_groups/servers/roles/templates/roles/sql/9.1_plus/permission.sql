SELECT
    rolname, rolcanlogin, rolcatupdate, rolsuper
FROM
    sys_roles
WHERE oid = {{ rid }}::OID
