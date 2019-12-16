{% if (vid and datlastsysoid) or scid %}
SELECT
    c.oid,
    c.xmin,
    c.relname AS name,
    description AS comment,
    c.reltablespace AS spcoid,
    (CASE WHEN length(spc.spcname) > 0 THEN spc.spcname ELSE 'sys_default' END) as spcname,
    sys_get_userbyid(c.relowner) AS owner,
    description As comment,
    sys_get_viewdef(c.oid, true) AS definition,
    nsp.nspname AS schema,
    array_to_string(c.relacl::text[], ', ') AS acl,
    {#=============Checks if it is system view================#}
    {% if vid and datlastsysoid %}
    CASE WHEN {{vid}} <= {{datlastsysoid}} THEN True ELSE False END AS system_view,
    {% endif %}
    (SELECT
        array_agg(provider || '=' || label)
     FROM
        sys_seclabels sl1
     WHERE
        sl1.objoid=c.oid AND sl1.objsubid=0
    ) AS seclabels,
    (substring(array_to_string(c.reloptions, ',')
        FROM 'security_barrier=([a-z|0-9]*)'))::boolean AS security_barrier
FROM sys_class c
LEFT OUTER JOIN sys_namespace nsp on nsp.oid = c.relnamespace
LEFT OUTER JOIN sys_tablespace spc on spc.oid=c.reltablespace
LEFT OUTER JOIN sys_description des ON (des.objoid=c.oid and des.objsubid=0 AND des.classoid='sys_class'::regclass)
    WHERE ((c.relhasrules AND (EXISTS (
            SELECT
                r.rulename
            FROM
                sys_rewrite r
            WHERE
                ((r.ev_class = c.oid)
                    AND (bpchar(r.ev_type) = '1'::bpchar)
                ) ))
           ) AND (c.relkind = 'v'::char)
          )
{% if (vid and datlastsysoid) %}
    AND c.oid = {{vid}}::oid
{% elif scid %}
    AND c.relnamespace = {{scid}}::oid ORDER BY c.relname
{% endif %}

{% elif type == 'roles' %}
SELECT
    pr.rolname
FROM
    sys_roles pr
WHERE
    pr.rolcanlogin
ORDER BY
    pr.rolname

{% elif type == 'schemas' %}
SELECT
    nsp.nspname
FROM
    sys_namespace nsp
WHERE
    (nsp.nspname NOT LIKE E'pg\\_%'
        AND nsp.nspname != 'information_schema')
{% endif %}
