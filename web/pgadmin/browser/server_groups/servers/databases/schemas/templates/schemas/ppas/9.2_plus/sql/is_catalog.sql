{% import 'catalog/ppas/macros/catalogs.sql' as CATALOGS %}
SELECT
    nsp.nspname as schema_name,
    {{ CATALOGS.LIST('nsp') }} AS is_catalog,
    {{ CATALOGS.DB_SUPPORT('nsp') }} AS db_support
FROM
    sys_catalog.sys_namespace nsp
WHERE
    nsp.oid = {{ scid|qtLiteral }}::OID;
