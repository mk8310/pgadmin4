SELECT
    lan.oid as oid, lanname as name, lanpltrusted as trusted,
    array_to_string(lanacl::text[], ', ') as acl, hp.proname as lanproc,
    vp.proname as lanval, description,
    sys_get_userbyid(lan.lanowner) as lanowner, ip.proname as laninl
FROM
    sys_language lan JOIN sys_proc hp ON hp.oid=lanplcallfoid
    LEFT OUTER JOIN sys_proc ip ON ip.oid=laninline
    LEFT OUTER JOIN sys_proc vp ON vp.oid=lanvalidator
    LEFT OUTER JOIN sys_description des
        ON (
            des.objoid=lan.oid AND des.objsubid=0 AND
            des.classoid='sys_language'::regclass
        )
WHERE lanispl IS TRUE
{% if lid %} AND
    lan.oid={{lid}}::oid
{% endif %}
{% if lanname %} AND
    lanname={{ lanname|qtLiteral }}::text
{% endif %}
ORDER BY lanname
