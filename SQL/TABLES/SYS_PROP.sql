CREATE TABLE sys_prop
(
    id_prp   VARCHAR2(30) NOT NULL,
	id_prn   VARCHAR2(30) NOT NULL,
	required CHAR(1) NOT NULL,
	prptp    VARCHAR2(32) NOT NULL,
	descrp   VARCHAR2(255) NOT NULL,
	decimal_value NUMBER(22,6),
	string_value  VARCHAR2(1024),
	number_value  NUMBER(10,0),
	boolean_value VARCHAR2(5),
	CONSTRAINT ch_sys_prop_required CHECK (required IN ('Y', 'N')),
	CONSTRAINT ch_sys_prop_prptp CHECK (prptp IN ('DECIMAL_TYPE', 'NUMBER_TYPE', 'STRING_TYPE')),
	CONSTRAINT ch_sys_prop_bool CHECK (boolean_value IN ('true', 'false'))
);

CREATE UNIQUE INDEX pk01_sys_prop ON sys_prop (id_prp);
ALTER TABLE sys_prop ADD CONSTRAINT pk01_sys_prop PRIMARY KEY (id_prp) USING INDEX pk01_sys_prop;
