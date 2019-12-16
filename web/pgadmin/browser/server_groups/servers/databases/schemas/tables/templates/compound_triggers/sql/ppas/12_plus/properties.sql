SELECT t.oid,t.tgname AS name, t.xmin, t.tgenabled AS is_enable_trigger, t.tgtype, t.tgattr, relname,
    CASE WHEN relkind = 'r' THEN TRUE ELSE FALSE END AS parentistable,
    nspname, des.description,
    regexp_replace(regexp_replace(sys_get_triggerdef(t.oid),
        'CREATE TRIGGER (.*) FOR (.*) ON (.*) \nCOMPOUND TRIGGER (.*)\n', ''), '[\n]?END$', ''
    ) AS prosrc,
{% if datlastsysoid %}
    (CASE WHEN t.oid <= {{ datlastsysoid}}::oid THEN true ElSE false END) AS is_sys_trigger,
{% endif %}
    COALESCE(substring(sys_get_triggerdef(t.oid), 'WHEN (.*) \nCOMPOUND'), NULL) AS whenclause
FROM sys_trigger t
    JOIN sys_class cl ON cl.oid=tgrelid
    JOIN sys_namespace na ON na.oid=relnamespace
    LEFT OUTER JOIN sys_description des ON (des.objoid=t.oid AND des.classoid='sys_trigger'::regclass)
WHERE NOT tgisinternal
    AND tgrelid = {{tid}}::OID
    AND tgpackageoid != 0
{% if trid %}
    AND t.oid = {{trid}}::OID
{% endif %}
ORDER BY tgname;
