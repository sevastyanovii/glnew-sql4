CREATE TABLE trg_state (
    table_name    VARCHAR2(30) NOT NULL,
    trigger_name  VARCHAR2(30) NOT NULL,
    trigger_state VARCHAR2(16) NOT NULL,
    ts TIMESTAMP DEFAULT SYSTIMESTAMP,
    sq NUMBER(10) NOT NULL,
    CONSTRAINT ch_trg_state CHECK (trigger_state IN ('DISABLED','ENABLED')),
    CONSTRAINT un_trg_state UNIQUE (table_name, trigger_name, sq)
);

CREATE INDEX idx_trg_state_ts ON trg_state (ts);

COMMENT ON TABLE  trg_state IS 'Table for storing tables during patching';
COMMENT ON COLUMN trg_state.table_name    IS 'Table name';
COMMENT ON COLUMN trg_state.trigger_name  IS 'Trigger name';
COMMENT ON COLUMN trg_state.trigger_state IS 'Trigger state';
COMMENT ON COLUMN trg_state.ts            IS 'State on timestamp';
COMMENT ON COLUMN trg_state.sq            IS 'Unique sequence value on save of status';
