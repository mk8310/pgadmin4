{# ============= SELECT Language templates ============= #}
SELECT
    tmplname
FROM sys_pltemplate
LEFT JOIN sys_language ON tmplname=lanname
WHERE lanname IS NULL
ORDER BY tmplname;
