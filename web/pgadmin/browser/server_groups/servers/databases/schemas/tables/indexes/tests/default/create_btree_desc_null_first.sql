-- Index: Idx_$%{}[]()&*^!@"'`\/#

-- DROP INDEX public."Idx_$%{}[]()&*^!@""'`\/#";

CREATE UNIQUE INDEX "Idx_$%{}[]()&*^!@""'`\/#"
    ON public.test_table_for_indexes USING btree
    (id DESC NULLS FIRST, name COLLATE sys_catalog."POSIX" text_pattern_ops DESC NULLS FIRST)
    TABLESPACE sys_default;
