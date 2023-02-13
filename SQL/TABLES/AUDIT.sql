CREATE TABLE sysaudit (
    id_record     NUMBER(22),
    sys_time      TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    user_name     VARCHAR2(64),
    user_host     VARCHAR2(64),
    log_code      VARCHAR2(64) NOT NULL,
    log_level     VARCHAR2(8) NOT NULL,
    message       VARCHAR2(512) NOT NULL,
    errormsg      VARCHAR2(4000),
    stck_trace    CLOB,
    entity_id     VARCHAR2(128),
    entitytype    VARCHAR2(256),
    transactid    VARCHAR2(512),
    src           VARCHAR2(512),
    errorsrc      VARCHAR2(4000),
    attachment    CLOB,
    proctimems    NUMBER
)
PARTITION BY RANGE (sys_time) INTERVAL (numtoyminterval(2, 'MONTH'))
(PARTITION p0 VALUES LESS THAN (TO_DATE('01-03-2023', 'DD-MM-YYYY')));

CREATE INDEX idx_sysaudit_sys_time ON sysaudit(sys_time);

COMMENT ON TABLE sysaudit IS 'BARS GL System log';
COMMENT ON COLUMN sysaudit.id_record  IS 'Primary key';
COMMENT ON COLUMN sysaudit.sys_time   IS 'Registration time';
COMMENT ON COLUMN sysaudit.user_name  IS 'User';
COMMENT ON COLUMN sysaudit.user_host  IS 'IP address or computer name';
COMMENT ON COLUMN sysaudit.log_code   IS 'Operation code';
COMMENT ON COLUMN sysaudit.log_level  IS 'Log error level';
COMMENT ON COLUMN sysaudit.message    IS 'Message';
COMMENT ON COLUMN sysaudit.errormsg   IS 'Error Message';
COMMENT ON COLUMN sysaudit.stck_trace IS 'Stack trace';
COMMENT ON COLUMN sysaudit.entity_id  IS 'Record ID in table';
COMMENT ON COLUMN sysaudit.entitytype IS 'Entity class name for table';
COMMENT ON COLUMN sysaudit.transactid IS 'Transaction ID';
COMMENT ON COLUMN sysaudit.src        IS 'Source code call position';
COMMENT ON COLUMN sysaudit.errorsrc   IS 'Source code exception position';
COMMENT ON COLUMN sysaudit.attachment IS 'Extended information';
COMMENT ON COLUMN sysaudit.proctimems IS 'Process duration';

