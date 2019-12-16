SELECT
    funcname AS {{ conn|qtIdent(_('Name')) }},
    calls AS {{ conn|qtIdent(_('Number of calls')) }},
    total_time AS {{ conn|qtIdent(_('Total time')) }},
    self_time AS {{ conn|qtIdent(_('Self time')) }}
FROM
    sys_stat_user_functions
WHERE
    schemaname = {{schema_name|qtLiteral}}
    AND funcid IN (
        SELECT p.oid
        FROM
            sys_proc p
        JOIN
            sys_type typ ON typ.oid=p.prorettype
        WHERE
            p.prokind IN ('f', 'w')
            AND typname IN ('trigger', 'event_trigger')
    )
ORDER BY funcname;
