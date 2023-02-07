CREATE TABLE GL_ACTNAME
(
	acctype  VARCHAR2(10)  NOT NULL ENABLE,
	accname  VARCHAR2(255) NOT NULL ENABLE,
	pl_act   CHAR(1) DEFAULT 'N' NOT NULL ENABLE,
	fl_ctrl  CHAR(1) DEFAULT 'N' NOT NULL ENABLE,
	tech_act CHAR(1),
	/*
	CONSTRAINT nn01_gl_actname_acctype  CHECK (acctype  IS NOT NULL ) ENABLE,
	CONSTRAINT nn01_gl_actname_pl_act   CHECK (pl_act   IS NOT NULL ) ENABLE,
	CONSTRAINT nn01_gl_actname_accname  CHECK (accname  IS NOT NULL ) ENABLE,
	CONSTRAINT nn01_gl_actname_fl_ctrl  CHECK (fl_ctrl  IS NOT NULL ) ENABLE,
	CONSTRAINT nn01_gl_actname_tech_act CHECK (tech_act IS NOT NULL ) ENABLE,
	*/
	SUPPLEMENTAL LOG DATA (ALL) COLUMNS
);

CREATE UNIQUE INDEX pk01_gl_actname ON gl_actname (acctype);

ALTER TABLE gl_actname ADD CONSTRAINT pk01_gl_actname PRIMARY KEY (acctype)
	USING INDEX pk01_gl_actname  ENABLE;

COMMENT ON TABLE gl_actname IS 'Внутренний план счетов';
COMMENT ON COLUMN gl_actname.acctype  IS 'Accounting type';
COMMENT ON COLUMN gl_actname.accname  IS 'Account Type Name';
COMMENT ON COLUMN gl_actname.pl_act   IS 'BARS PL Account opening is allowed';
COMMENT ON COLUMN gl_actname.fl_ctrl  IS 'Checked account flag';
COMMENT ON COLUMN gl_actname.tech_act IS 'Tech account flag';
