CREATE TABLE srcpst
(
    srcid   VARCHAR2(16 CHAR) PRIMARY KEY,
    srcname VARCHAR2(256 CHAR) NOT NULL UNIQUE
);

COMMENT ON TABLE srcpst is 'Коды источников счетов и сделок';
COMMENT ON COLUMN srcpst.srcid    IS 'ИД источника';
COMMENT ON COLUMN srcpst.srcname  IS 'Название';
