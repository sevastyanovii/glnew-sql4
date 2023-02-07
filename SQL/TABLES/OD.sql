CREATE TABLE od (
    curdate DATE PRIMARY KEY,
    phase   VARCHAR2(16 CHAR) NOT NULL UNIQUE,
    lwdate  DATE NOT NULL UNIQUE,
    lwdate_status VARCHAR2(16 CHAR) NOT NULL UNIQUE,
    pdmod   VARCHAR2(32 CHAR)	DEFAULT	'DIRECT' NOT NULL,
	prc     VARCHAR2(32 CHAR)	DEFAULT	'ALLOWED',
	acsmode	VARCHAR2(10 CHAR)	DEFAULT	'FULL',
    CONSTRAINT ch_od_phase      CHECK (phase         in ('ONLINE','PRE_COB','COB')),
    CONSTRAINT ch_od_lwd_status CHECK (lwdate_status in ('OPEN', 'CLOSED')),
    CONSTRAINT ch_od_pdmod      CHECK (pdmod         in ('DIRECT', 'BUFFER')),
    CONSTRAINT ch_od_prc        CHECK (prc           in ('REQUIRED', 'STOPPED', 'ALLOWED', 'STARTED')),
    CONSTRAINT ch_od_acsmd      CHECK (acsmode       in ('FULL', 'LIMIT'))
);

COMMENT ON TABLE od IS 'Операционный день';
COMMENT ON COLUMN od.curdate   IS 'Current operday';
COMMENT ON COLUMN od.phase     IS 'Фаза опердня';
COMMENT ON COLUMN od.lwdate    IS 'Last working operday';
COMMENT ON COLUMN od.lwdate_status IS 'Backday balance state';
COMMENT ON COLUMN od.pdmod     IS 'Pd working mode';
COMMENT ON COLUMN od.prc       IS 'Processing status';
COMMENT ON COLUMN od.acsmode   IS 'Режим доступа (полный/ограниченный)';
