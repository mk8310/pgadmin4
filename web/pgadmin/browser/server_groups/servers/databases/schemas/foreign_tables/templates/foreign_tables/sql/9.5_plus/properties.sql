SELECT
    c.oid, c.relname AS name, c.relacl, sys_get_userbyid(relowner) AS owner,
    ftoptions, srvname AS ftsrvname, description, nspname AS basensp,
    (SELECT
        array_agg(provider || '=' || label)
    FROM
        sys_seclabel sl1
    WHERE
        sl1.objoid=c.oid) AS seclabels
    {% if foid %},
    (SELECT
        array_agg(i.inhparent) FROM sys_inherits i
    WHERE
        i.inhrelid = {{foid}}::oid GROUP BY i.inhrelid) AS inherits
    {% endif %}
FROM
    sys_class c
JOIN
    sys_foreign_table ft ON c.oid=ft.ftrelid
LEFT OUTER JOIN
    sys_foreign_server fs ON ft.ftserver=fs.oid
LEFT OUTER JOIN
    sys_description des ON (des.objoid=c.oid AND des.classoid='sys_class'::regclass)
LEFT OUTER JOIN
    sys_namespace nsp ON (nsp.oid=c.relnamespace)
WHERE
    c.relnamespace = {{scid}}::oid
    {% if foid %}
    AND c.oid = {{foid}}::oid
    {% endif %}
ORDER BY c.relname;
