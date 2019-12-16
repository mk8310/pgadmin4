SELECT
    nsp.oid, nspname AS name
FROM
    sys_namespace nsp
WHERE nspparent = {{scid}}::oid
ORDER BY nspname;
