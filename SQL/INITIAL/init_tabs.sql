CREATE TABLE sysmod
(
    name    VARCHAR2(255) NOT NULL PRIMARY KEY,
    version VARCHAR2(255) NOT NULL,
    patch   VARCHAR2(255),
    vdate   TIMESTAMP NOT NULL,
    pdate   TIMESTAMP
);

COMMENT ON TABLE sysmod IS 'Current version of GL-sql';

COMMENT ON COLUMN sysmod.name    IS 'Module name';
COMMENT ON COLUMN sysmod.version IS 'Current version of GL-sql';
COMMENT ON COLUMN sysmod.patch	IS 'Current patch of GL-sql';
COMMENT ON COLUMN sysmod.vdate	IS 'A date of version installation';
COMMENT ON COLUMN sysmod.pdate	IS 'A date of patch installation';

BEGIN
    INSERT INTO sysmod (name, version, vdate) VALUES ('GlNew', '0.0.0', SYSTIMESTAMP);
    COMMIT;
END;
/

---------------------------------------------------------------------------

CREATE TABLE sysvlog (
    id_log NUMBER(10),
    vpname VARCHAR2(255) NOT NULL,
    message VARCHAR2(4000) NOT NULL,
    ts TIMESTAMP DEFAULT SYSTIMESTAMP
);

COMMENT ON TABLE sysvlog IS 'GL install log';

COMMENT ON COLUMN sysvlog.id_log  IS 'Row identificator';
COMMENT ON COLUMN sysvlog.vpname  IS 'By path or version';
COMMENT ON COLUMN sysvlog.message IS 'Message';
COMMENT ON COLUMN sysvlog.ts      IS 'A row creation timestamp';

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE seq_sysvlog';
EXCEPTION
   WHEN OTHERS THEN
      NULL;
END;
/
CREATE SEQUENCE seq_sysvlog START WITH 10000 INCREMENT BY 1 CACHE 20 NOCYCLE;

CREATE OR REPLACE TRIGGER trg_sysvlog_ai BEFORE INSERT ON sysvlog FOR EACH ROW
DECLARE
BEGIN
    IF (:new.id_log IS null) THEN
        :new.id_log := seq_sysvlog.nextval;
    END IF;
END;
/

---------------------------------------------------------------------------

CREATE TABLE install_job (
    job_name VARCHAR2(30) NOT NULL UNIQUE,
    state    VARCHAR2(64) NOT NULL,
    chk      VARCHAR2(64) NOT NULL,
    ts       TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT ch_instjob01 CHECK (chk IN ('SAVED','RESTORED'))
);

COMMENT ON TABLE  install_job IS 'Table for storing tables during patching';

COMMENT ON COLUMN install_job.job_name IS 'Job name';
COMMENT ON COLUMN install_job.state    IS 'State of job before storing';
COMMENT ON COLUMN install_job.chk      IS 'Flag of use';
COMMENT ON COLUMN install_job.ts       IS 'A row creation timestamp';

---------------------------------------------------------------------------

