{# Below will provide oid for newly created type #}
SELECT t.oid
FROM sys_type t
    LEFT OUTER JOIN sys_type e ON e.oid=t.typelem
    LEFT OUTER JOIN sys_class ct ON ct.oid=t.typrelid AND ct.relkind <> 'c'
    LEFT OUTER JOIN sys_description des ON (des.objoid=t.oid AND des.classoid='sys_type'::regclass)
WHERE t.typtype != 'd' AND t.typname NOT LIKE E'\\_%' AND t.typnamespace = {{scid}}::oid
{% if data %}
    AND t.typname = {{data.name|qtLiteral}}
{% endif %}
ORDER BY t.typname;
