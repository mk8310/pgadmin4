{% if scid %}
SELECT
    cl.oid as oid,
    relname as name,
    nsp.nspname as schema,
    sys_get_userbyid(relowner) AS seqowner,
    description as comment,
    array_to_string(relacl::text[], ', ') as acl,
    (SELECT array_agg(provider || '=' || label) FROM sys_seclabels sl1 WHERE sl1.objoid=cl.oid) AS securities
FROM sys_class cl
    LEFT OUTER JOIN sys_namespace nsp ON cl.relnamespace = nsp.oid
    LEFT OUTER JOIN sys_description des ON (des.objoid=cl.oid
        AND des.classoid='sys_class'::regclass)
WHERE relkind = 'S' AND relnamespace  = {{scid}}::oid
{% if seid %}AND cl.oid = {{seid}}::oid {% endif %}
ORDER BY relname
{% endif %}
