CREATE TABLE customer_h
(
    idpk     NUMBER(22,0) NOT NULL,
    custid   CHAR(8) NOT NULL,
    custype  CHAR(2) NOT NULL,
    br_id    CHAR(3) NOT NULL,
    c_name   VARCHAR2(250 CHAR),
    inn      VARCHAR2(10 CHAR),
    surname  VARCHAR2(80 CHAR),
    p_name   VARCHAR2(80 CHAR),
    snd_name VARCHAR2(80 CHAR),
    docser   VARCHAR2(10 CHAR),
    docnum   VARCHAR2(20 CHAR),
    docdt    DATE,
    birthdt  DATE,
    pinfl    VARCHAR2(14 CHAR),
    res      VARCHAR2(3 CHAR),
    fcstatus VARCHAR2(10 CHAR) NOT NULL,
    bnk_br   CHAR(1) NOT NULL,
    rec_no   NUMBER NOT NULL,
    inp_dt   TIMESTAMP NOT NULL,
    --
    ts          TIMESTAMP NOT NULL,
    chg_vector  CHAR(1) NOT NULL
);

CREATE INDEX idx_customer_pk ON customer_h (idpk);
CREATE INDEX idx_customer_id ON customer_h (custid);

COMMENT ON TABLE customer_h IS 'Архив справочника клиентов';
COMMENT ON COLUMN customer_h.idpk       IS 'Первичный ключ';
COMMENT ON COLUMN customer_h.custid     IS 'ID NIBBD';
COMMENT ON COLUMN customer_h.custype    IS 'Код типа клиента (Ref to CBCTP.CTYPE)';
COMMENT ON COLUMN customer_h.br_id      IS 'Бранч банка (Ref to FCBR.BRID)';
COMMENT ON COLUMN customer_h.c_name     IS 'Наименование юр.лица/Ф.И.О. индивидуального предпринимателя';
COMMENT ON COLUMN customer_h.inn        IS 'ИНН (Для ЮЛ)';
COMMENT ON COLUMN customer_h.surname    IS 'Surname';
COMMENT ON COLUMN customer_h.p_name     IS 'Name';
COMMENT ON COLUMN customer_h.snd_name   IS 'Second name';
COMMENT ON COLUMN customer_h.docser     IS 'Серия удостоверяющего документа';
COMMENT ON COLUMN customer_h.docnum     IS 'Номер удостоверяющего документа';
COMMENT ON COLUMN customer_h.docdt      IS 'Дата выдачи удостоверяющего документа';
COMMENT ON COLUMN customer_h.birthdt    IS 'Дата рождения';
COMMENT ON COLUMN customer_h.pinfl      IS 'ПИНФЛ физического лица';
COMMENT ON COLUMN customer_h.res        IS 'Резидентность';
COMMENT ON COLUMN customer_h.fcstatus   IS 'Статус FlexCube';
COMMENT ON COLUMN customer_h.bnk_br     IS 'Филиал (Признак филиала)';
COMMENT ON COLUMN customer_h.rec_no     IS 'Порядковый номер записи';
COMMENT ON COLUMN customer_h.inp_dt     IS 'Дата и время создания текущей записи';
COMMENT ON COLUMN customer_h.ts         IS 'Момент изменения/добавления родительской записи в таблице acc';
COMMENT ON COLUMN customer_h.chg_vector IS 'Тип изменения родительской записи в таблице acc (I/U)';
