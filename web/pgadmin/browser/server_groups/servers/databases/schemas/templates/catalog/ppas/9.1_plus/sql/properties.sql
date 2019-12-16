{% import 'catalog/ppas/macros/catalogs.sql' as CATALOGS %}
SELECT
    2 AS nsptyp,
    nsp.nspname AS name,
    nsp.oid,
    array_to_string(nsp.nspacl::text[], ', ') as acl,
    r.rolname AS namespaceowner, description,
    has_schema_privilege(nsp.oid, 'CREATE') AS can_create,
    CASE
    WHEN nspname LIKE E'pg\\_%' THEN true
    ELSE false END AS is_sys_object,
    (SELECT array_to_string(defaclacl::text[], ', ') FROM sys_default_acl WHERE defaclobjtype = 'r' AND defaclnamespace = nsp.oid) AS tblacl,
    (SELECT array_to_string(defaclacl::text[], ', ') FROM sys_default_acl WHERE defaclobjtype = 'S' AND defaclnamespace = nsp.oid) AS seqacl,
    (SELECT array_to_string(defaclacl::text[], ', ') FROM sys_default_acl WHERE defaclobjtype = 'f' AND defaclnamespace = nsp.oid) AS funcacl,
    (SELECT array_agg(provider || '=' || label) FROM sys_seclabels sl1 WHERE sl1.objoid=nsp.oid) AS seclabels
FROM
    sys_namespace nsp
    LEFT OUTER JOIN sys_description des ON
        (des.objoid=nsp.oid AND des.classoid='sys_namespace'::regclass)
    LEFT JOIN sys_roles r ON (r.oid = nsp.nspowner)
WHERE
    {% if scid %}
    nsp.oid={{scid}}::oid AND
    {% endif %}
    nsp.nspparent = 0 AND
    (
{{ CATALOGS.LIST('nsp') }}
    )
ORDER BY 1, nspname;
