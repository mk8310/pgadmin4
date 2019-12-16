-- Type: composite_type_$%{}[]()&*^!@"'`\/#

-- DROP TYPE public."composite_type_$%{}[]()&*^!@""'`\/#";

CREATE TYPE public."composite_type_$%{}[]()&*^!@""'`\/#" AS
(
	mname1 bigint,
	mname2 character varying(50) COLLATE sys_catalog."C",
	mname3 text[] COLLATE sys_catalog."C",
	mname4 bigint
);

ALTER TYPE public."composite_type_$%{}[]()&*^!@""'`\/#"
    OWNER TO <OWNER>;
