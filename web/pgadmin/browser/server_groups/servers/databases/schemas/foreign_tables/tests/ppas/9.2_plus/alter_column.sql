-- FOREIGN TABLE: public."FT1_$%{}[]()&*^!@""'`\/#"

-- DROP FOREIGN TABLE public."FT1_$%{}[]()&*^!@""'`\/#";

CREATE FOREIGN TABLE public."FT1_$%{}[]()&*^!@""'`\/#"(
    col1 integer NULL,
    col3 bigint NULL,
    col4 text NULL COLLATE sys_catalog."default"
)
    SERVER test_fs_for_foreign_table;

ALTER FOREIGN TABLE public."FT1_$%{}[]()&*^!@""'`\/#"
    OWNER TO enterprisedb;

COMMENT ON FOREIGN TABLE public."FT1_$%{}[]()&*^!@""'`\/#"
    IS 'Test Comment';

GRANT INSERT, SELECT ON TABLE public."FT1_$%{}[]()&*^!@""'`\/#" TO PUBLIC;

GRANT ALL ON TABLE public."FT1_$%{}[]()&*^!@""'`\/#" TO enterprisedb;
