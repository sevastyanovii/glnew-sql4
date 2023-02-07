CREATE TABLE dicterm (
    term CHAR(2) PRIMARY KEY,
    termname VARCHAR2(128 CHAR)  NOT NULL
);

COMMENT ON TABLE dicterm is 'Коды сроков сделок';
COMMENT ON COLUMN dicterm.term      IS 'Код срока';
COMMENT ON COLUMN dicterm.termname  IS 'Описание кода срока';
