CREATE TABLE fcbr (
    brid     CHAR(3) PRIMARY KEY,
    braltid  CHAR(5),
    bank_id  CHAR(5) NOT NULL,
    brcustno CHAR(8),
    brname   VARCHAR2(80 CHAR),
    br_head  CHAR(1),
    CONSTRAINT ch_fcbr_br_head CHECK (br_head IN ('Y', 'N'))
);

COMMENT ON TABLE fcbr IS 'Бранчи';
COMMENT ON COLUMN fcbr.brid     IS 'ИД бранча';
COMMENT ON COLUMN fcbr.braltid  IS 'Альтернативный ИД бранча';
COMMENT ON COLUMN fcbr.bank_id  IS 'ИД филиала (ссылка на BNK_BRANCH)';
COMMENT ON COLUMN fcbr.brcustno IS 'ИД клиента (ссылка на CUSTOMER)';
COMMENT ON COLUMN fcbr.brname   IS 'Название бранча';
COMMENT ON COLUMN fcbr.br_head  IS 'Признак того, что бранч соответствует филиалу';
