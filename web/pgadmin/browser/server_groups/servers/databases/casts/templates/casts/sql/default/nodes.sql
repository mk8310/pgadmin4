    SELECT
        ca.oid,
        concat(format_type(st.oid,NULL),'->',format_type(tt.oid,tt.typtypmod)) as name
    FROM sys_cast ca
    JOIN sys_type st ON st.oid=castsource
    JOIN sys_namespace ns ON ns.oid=st.typnamespace
    JOIN sys_type tt ON tt.oid=casttarget
    JOIN sys_namespace nt ON nt.oid=tt.typnamespace
    LEFT JOIN sys_proc pr ON pr.oid=castfunc
    LEFT JOIN sys_namespace np ON np.oid=pr.pronamespace
    LEFT OUTER JOIN sys_description des ON (des.objoid=ca.oid AND des.objsubid=0 AND des.classoid='sys_cast'::regclass)
    {% if cid %}
        WHERE ca.oid={{cid}}::oid
    {% endif %}
    {# Check for Show system object #}
    {% if (not showsysobj) and datlastsysoid %}
        {% if cid %}
            AND
        {% else %}
            WHERE
        {% endif %}
        ca.oid > {{datlastsysoid}}::OID
    {% endif %}
    ORDER BY st.typname, tt.typname
