SELECT att.attname as name, att.attnum as OID, format_type(ty.oid,NULL) AS datatype,
att.attnotnull as not_null, att.atthasdef as has_default_val
FROM sys_attribute att
  JOIN sys_type ty ON ty.oid=atttypid
  JOIN sys_namespace tn ON tn.oid=ty.typnamespace
  JOIN sys_class cl ON cl.oid=att.attrelid
  JOIN sys_namespace na ON na.oid=cl.relnamespace
  LEFT OUTER JOIN sys_type et ON et.oid=ty.typelem
  LEFT OUTER JOIN sys_attrdef def ON adrelid=att.attrelid AND adnum=att.attnum
  LEFT OUTER JOIN (sys_depend JOIN sys_class cs ON classid='sys_class'::regclass AND objid=cs.oid AND cs.relkind='S') ON refobjid=att.attrelid AND refobjsubid=att.attnum
  LEFT OUTER JOIN sys_namespace ns ON ns.oid=cs.relnamespace
  LEFT OUTER JOIN sys_index pi ON pi.indrelid=att.attrelid AND indisprimary
WHERE
    att.attrelid = {{ tid|qtLiteral }}::oid
{% if clid %}
    AND att.attnum = {{ clid|qtLiteral }}
{% endif %}
{### To show system objects ###}
{% if not show_sys_objects and not has_oids %}
    AND att.attnum > 0
{% endif %}
{### To show oids in view data ###}
{% if has_oids %}
    AND (att.attnum > 0 OR (att.attname = 'oid' AND att.attnum < 0))
{% endif %}
    AND att.attisdropped IS FALSE
ORDER BY att.attnum
