CREATE TABLE customer
(
    idpk     NUMBER(22,0) GENERATED ALWAYS AS IDENTITY (NOCACHE) PRIMARY KEY,
    custid   CHAR(8) NOT NULL UNIQUE,
    custype  CHAR(2) NOT NULL,
    br_id    CHAR(3) NOT NULL,
    c_name   VARCHAR2(250 CHAR),
    inn      VARCHAR2(10 CHAR),
    surname  VARCHAR2(80 CHAR),
    p_name   VARCHAR2(80 CHAR),
    snd_name VARCHAR2(80 CHAR),
    doctype  CHAR(2),
    docser   VARCHAR2(4 CHAR),
    docnum   VARCHAR2(16 CHAR),
    docdt    DATE,
    birthdt  DATE,
    pinfl    VARCHAR2(14 CHAR),
    res      VARCHAR2(3 CHAR),
    fcstatus VARCHAR2(10 CHAR) NOT NULL,
    bnk_br   CHAR(1) NOT NULL,
    rec_no   NUMBER DEFAULT 1 NOT NULL,
    inp_dt   TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

COMMENT ON TABLE customer is 'Клиенты';
COMMENT ON COLUMN customer.idpk     is 'Первичный ключ';
COMMENT ON COLUMN customer.custid   is 'ID NIBBD';
COMMENT ON COLUMN customer.custype  is 'Код типа клиента (Ref to CBCTP.CTYPE)';
COMMENT ON COLUMN customer.br_id    is 'Бранч банка (Ref to FCBR.BRID)';
COMMENT ON COLUMN customer.c_name   is 'Наименование юр.лица/Ф.И.О. индивидуального предпринимателя';
COMMENT ON COLUMN customer.inn      is 'ИНН (Для ЮЛ)';
COMMENT ON COLUMN customer.surname  is 'Surname';
COMMENT ON COLUMN customer.p_name   is 'Name';
COMMENT ON COLUMN customer.snd_name is 'Second name';
COMMENT ON COLUMN customer.doctype  is 'Серия удостоверяющего документа';
COMMENT ON COLUMN customer.docser   is 'Серия удостоверяющего документа';
COMMENT ON COLUMN customer.docnum   is 'Номер удостоверяющего документа';
COMMENT ON COLUMN customer.docdt    is 'Дата выдачи удостоверяющего документа';
COMMENT ON COLUMN customer.birthdt  is 'Дата рождения';
COMMENT ON COLUMN customer.pinfl    is 'ПИНФЛ физического лица';
COMMENT ON COLUMN customer.res      is 'Резидентность';
COMMENT ON COLUMN customer.fcstatus is 'Статус FlexCube';
COMMENT ON COLUMN customer.bnk_br   is 'Филиал (Признак филиала)';
COMMENT ON COLUMN customer.rec_no   is 'Порядковый номер записи';
COMMENT ON COLUMN customer.inp_dt   is 'Дата и время создания текущей записи';
