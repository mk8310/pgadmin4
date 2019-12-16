SELECT
    blks_read AS {{ conn|qtIdent(_('Blocks read')) }},
    blks_hit AS {{ conn|qtIdent(_('Blocks hit')) }}
FROM
    sys_statio_all_sequences
WHERE
    relid = {{ seid }}::OID
