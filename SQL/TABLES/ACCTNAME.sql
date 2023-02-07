CREATE TABLE acctname (
    acctype VARCHAR2(10 CHAR) PRIMARY KEY,
    accname VARCHAR2(255 CHAR) NOT NULL UNIQUE
);

COMMENT ON table acctname IS 'Вутренний план счетов';
COMMENT ON column acctname.acctype IS 'Accounting type';
COMMENT ON column acctname.accname IS 'Accounting type name';
