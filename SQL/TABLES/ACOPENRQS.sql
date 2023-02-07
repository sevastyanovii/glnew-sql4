CREATE TABLE acopenrqs
(
    idpk        NUMBER(22,0) GENERATED ALWAYS AS IDENTITY (NOCACHE) PRIMARY KEY,
    request_id	VARCHAR2(48 CHAR),
    msg_body    CLOB NOT NULL,
    branch      CHAR(3),
    ccy         CHAR(3),
    custid      CHAR(8),
    fc_actype   VARCHAR2(30 CHAR),
    srcid       VARCHAR2(80 CHAR),
    ctype       CHAR(2),
    term        CHAR(2),
    deal_id     VARCHAR2(80 CHAR),
    subdeal_id	VARCHAR2(80 CHAR),
    opendt_in   DATE,
    accno_in    CHAR(20),
    action      VARCHAR2(10 CHAR),
    accno_out   CHAR(20),
    newacc      CHAR(1),
    opendt_out  DATE,
    acc2        CHAR(5),
    nnn         CHAR(3),
    status      VARCHAR2(16 CHAR) NOT NULL,
    sys_time    TIMESTAMP(6) NOT NULL,
    errcode     VARCHAR2(4 CHAR),
    errdescr    VARCHAR2(1024 CHAR),
    CONSTRAINT ch_acopenrqs_action CHECK (action IN ('OPEN', 'ACNO_RSRV', 'ACNO_OPEN', 'CLOSE')),
    CONSTRAINT ch_acopenrqs_status CHECK (status IN ('LOAD','VALIDATED','MAPPED','PROCESSED','ERR_VAL','ERR_MAP'))
);

CREATE INDEX idx_acopenrqs_request_id ON acopenrqs (request_id);
CREATE INDEX idx_acopenrqs_accno_out  ON acopenrqs (accno_out);

COMMENT ON TABLE acopenrqs IS 'Запрос на создание/закрытие счета';
COMMENT ON COLUMN acopenrqs.idpk        IS 'ИД записи';
COMMENT ON COLUMN acopenrqs.request_id  IS 'Request ID';
COMMENT ON COLUMN acopenrqs.msg_body    IS 'Сообщение в JSON';
COMMENT ON COLUMN acopenrqs.branch      IS 'Branch Флекса';
COMMENT ON COLUMN acopenrqs.ccy         IS 'Валюта';
COMMENT ON COLUMN acopenrqs.custid      IS 'Код клиента';
COMMENT ON COLUMN acopenrqs.fc_actype   IS 'Тип счета FC';
COMMENT ON COLUMN acopenrqs.srcid       IS 'Deal source';
COMMENT ON COLUMN acopenrqs.ctype       IS 'Customer type';
COMMENT ON COLUMN acopenrqs.term        IS 'Period code';
COMMENT ON COLUMN acopenrqs.deal_id     IS 'Deal ID';
COMMENT ON COLUMN acopenrqs.subdeal_id  IS 'SubDeal ID';
COMMENT ON COLUMN acopenrqs.opendt_in   IS 'Open date';
COMMENT ON COLUMN acopenrqs.accno_in    IS 'Номер счета для открытия счета с заданным номером, закрытия или отмены счета';
COMMENT ON COLUMN acopenrqs.action      IS 'Действие при обработке сообщения';
COMMENT ON COLUMN acopenrqs.accno_out   IS 'Номер счета по запросу';
COMMENT ON COLUMN acopenrqs.newacc      IS 'Признак того, был открыт новый счет или найден существующий';
COMMENT ON COLUMN acopenrqs.opendt_out  IS 'Дата открытия счета';
COMMENT ON COLUMN acopenrqs.acc2        IS 'Балансовый счет ';
COMMENT ON COLUMN acopenrqs.nnn         IS 'Последние 3 цифры в номере счета';
COMMENT ON COLUMN acopenrqs.status      IS 'Статус';
COMMENT ON COLUMN acopenrqs.sys_time    IS 'Event time';
COMMENT ON COLUMN acopenrqs.errcode     IS 'Error code';
COMMENT ON COLUMN acopenrqs.errdescr    IS 'Error description';
