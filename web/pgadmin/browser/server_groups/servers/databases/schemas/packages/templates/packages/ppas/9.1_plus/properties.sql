SELECT nsp.oid, nsp.xmin, nspname AS name,
    sys_catalog.edb_get_packagebodydef(nsp.oid) AS pkgbodysrc,
    sys_catalog.edb_get_packageheaddef(nsp.oid) AS pkgheadsrc,
    sys_get_userbyid(nspowner) AS owner,
    array_to_string(nsp.nspacl::text[], ', ') as acl,
    description,
    CASE
      WHEN nspname LIKE E'pg\\_%' THEN true
      ELSE false
      END AS is_sys_object
FROM sys_namespace nsp
LEFT OUTER JOIN sys_description des ON (des.objoid=nsp.oid AND des.classoid='sys_namespace'::regclass)
WHERE nspparent = {{scid}}::oid
{% if pkgid %}
AND nsp.oid = {{pkgid}}::oid
{% endif %}
ORDER BY nspname;
