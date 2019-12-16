-- FOREIGN TABLE: public."FT1_$%{}[]()&*^!@""'`\/#"

-- DROP FOREIGN TABLE public."FT1_$%{}[]()&*^!@""'`\/#";

CREATE FOREIGN TABLE public."FT1_$%{}[]()&*^!@""'`\/#"(
    col1 bigint NULL,
    col2 text NULL COLLATE sys_catalog."default"
)
    SERVER test_fs_for_foreign_table
    OPTIONS (schema_name 'public', table_name 'test_table');

ALTER FOREIGN TABLE public."FT1_$%{}[]()&*^!@""'`\/#"
    OWNER TO enterprisedb;

ALTER FOREIGN TABLE public."FT1_$%{}[]()&*^!@""'`\/#"
    ADD CONSTRAINT cons1 CHECK (true) NO INHERIT;

COMMENT ON FOREIGN TABLE public."FT1_$%{}[]()&*^!@""'`\/#"
    IS 'Test Comment';

GRANT INSERT, SELECT ON TABLE public."FT1_$%{}[]()&*^!@""'`\/#" TO PUBLIC;

GRANT ALL ON TABLE public."FT1_$%{}[]()&*^!@""'`\/#" TO enterprisedb;
