{# ============= Give all the properties of foreign server ============= #}
{% if fdwid %}
SELECT fdw.oid as fdwoid,
       fdwname as name
FROM sys_foreign_data_wrapper fdw
LEFT OUTER JOIN sys_description des ON (des.objoid=fdw.oid AND des.objsubid=0 AND des.classoid='sys_foreign_data_wrapper'::regclass)
WHERE fdw.oid={{fdwid}}::oid
{% else %}
SELECT srv.oid as fsrvid, srvname as name, srvtype as fsrvtype, srvversion as fsrvversion, fdw.fdwname as fdwname, description,
array_to_string(srvoptions, ',') AS fsrvoptions,
sys_get_userbyid(srvowner) as fsrvowner, array_to_string(srvacl::text[], ', ') as acl
FROM sys_foreign_server srv
LEFT OUTER JOIN sys_foreign_data_wrapper fdw on fdw.oid=srvfdw
LEFT OUTER JOIN sys_description des ON (des.objoid=srv.oid AND des.objsubid=0 AND des.classoid='sys_foreign_server'::regclass)
{% if data and fdwdata %}
WHERE fdw.fdwname = {{ fdwdata.name|qtLiteral }}::text and srvname = {{ data.name|qtLiteral }}::text
{% elif fdwdata %}
WHERE fdw.fdwname = {{fdwdata.name|qtLiteral}}::text
{% endif %}
{% if fid %}
WHERE srvfdw={{fid}}::oid
{% endif %}
{% if fsid %}
WHERE srv.oid={{fsid}}::oid
{% endif %}
ORDER BY srvname;
{% endif %}
