{# Reverse engineered sql for FTS TEMPLATE #}
SELECT
    array_to_string(array_agg(sql), E'\n\n') as sql
FROM
    (
    SELECT
        E'-- Text Search Template: ' || quote_ident(nspname) || E'.' || quote_ident(tmpl.tmplname) ||
        E'\n\n-- DROP TEXT SEARCH TEMPLATE ' || quote_ident(nspname) || E'.' || quote_ident(tmpl.tmplname) ||
        E'\n\nCREATE TEXT SEARCH TEMPLATE ' || quote_ident(nspname) || E'.' || quote_ident(tmpl.tmplname) || E' (\n' ||
        CASE
            WHEN tmpl.tmplinit != '-'::regclass THEN E'    INIT = ' || tmpl.tmplinit || E',\n'
            ELSE '' END ||
        E'    LEXIZE = ' || tmpl.tmpllexize || E'\n);' ||
        CASE
            WHEN a.description IS NOT NULL THEN
                E'\n\nCOMMENT ON TEXT SEARCH TEMPLATE ' || quote_ident(nspname) || E'.' || quote_ident(tmpl.tmplname) ||
                E' IS ' || sys_catalog.quote_literal(description) || E';'
            ELSE ''  END as sql
FROM
    sys_ts_template tmpl
    LEFT JOIN (
        SELECT
            des.description as description,
            des.objoid as descoid
        FROM
            sys_description des
        WHERE
            des.objoid={{tid}}::OID AND des.classoid='sys_ts_template'::regclass
    ) a ON (a.descoid = tmpl.oid)
    LEFT JOIN (
        SELECT
            nspname,
            nsp.oid as noid
        FROM
            sys_namespace nsp
        WHERE
            oid = {{scid}}::OID
    ) b ON (b.noid = tmpl.tmplnamespace)
WHERE
    tmpl.oid={{tid}}::OID
) as c;
