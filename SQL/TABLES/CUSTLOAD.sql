CREATE TABLE custload
(
    idpk        NUMBER(22,0) GENERATED ALWAYS AS IDENTITY (NOCACHE) PRIMARY KEY,
    request_id  VARCHAR2(48 CHAR),
    msg_body    CLOB  NOT NULL,
    status      VARCHAR2(10 CHAR)   NOT NULL,
    load_date   TIMESTAMP  DEFAULT SYSTIMESTAMP NOT NULL,
    status_date TIMESTAMP  DEFAULT SYSTIMESTAMP NOT NULL,
    custid      CHAR(8),
    custype     CHAR(2),
    brid        CHAR(3),
    c_name      VARCHAR2(250 CHAR),
    inn         VARCHAR2(9 CHAR),
    surname     VARCHAR2(80 CHAR),
    p_name      VARCHAR2(80 CHAR),
    scnd_name   VARCHAR2(80 CHAR),
    doctype     CHAR(2),
    docser      VARCHAR2(10 CHAR),
    docnum      VARCHAR2(20 CHAR),
    docdt       DATE,
    birthday    DATE,
    pinfl       VARCHAR2(14 CHAR),
    res         CHAR(1) check (res in ('Y', 'N')),
    fcstatus    VARCHAR2(2),
    bnk_br      CHAR(1) check (bnk_br in ('Y', 'N')),
    res_stat    VARCHAR2(10) check (res_stat in ('INSERT','UPDATE')),
    errcode     VARCHAR2(4),
    errdescr    VARCHAR2(1024 CHAR),
    constraint ch_custload_status check (status in ('LOAD','VALIDATED','MAPPED','PROCESSED','ERR_VAL','ERR_MAP'))
);

CREATE INDEX idx_custload_custid ON custload (custid);
CREATE INDEX idx_custload_loaddate ON custload (load_date);

COMMENT ON TABLE custload IS 'Регистрация процесса обработки информации о клиенте';
COMMENT ON COLUMN custload.idpk        IS 'ID сообщения';
COMMENT ON COLUMN custload.request_id  IS 'Request ID';
COMMENT ON COLUMN custload.msg_body    IS 'Сообщение в JSON';
COMMENT ON COLUMN custload.status      IS 'Статус сообщения. Возможные значения: LOAD-новое сообщение,VALIDATED-сообщение успешно прошло валидацию формата, MAPPED-выполнено преобразование атрибутов сообщения в значения атрибутов для таблицы CUSTOMER, PROCESSED-сообщение обработано, ERR_VAL-ошибка валидации, ERR_MAP-ошибка при выполнении маппирования на значения атрибутов CUSTOMER';
COMMENT ON COLUMN custload.load_date   IS 'Дата и время загрузки сообщения';
COMMENT ON COLUMN custload.status_date IS 'Дата и время получения статуса';
COMMENT ON COLUMN custload.custid      IS 'Код клиента';
COMMENT ON COLUMN custload.custype     IS 'Тип клиента по ЦБ';
COMMENT ON COLUMN custload.brid        IS 'Код бранча классификации FC';
COMMENT ON COLUMN custload.c_name      IS 'Названию ЮЛ или инд предпринимателя';
COMMENT ON COLUMN custload.inn         IS 'ИНН юрлица';
COMMENT ON COLUMN custload.surname     IS 'Фамилия ФЛ';
COMMENT ON COLUMN custload.p_name      IS 'Имя ФЛ';
COMMENT ON COLUMN custload.scnd_name   IS 'Отчество ФЛ';
COMMENT ON COLUMN custload.doctype     IS 'Вид документа';
COMMENT ON COLUMN custload.docser      IS 'Серия документа ФЛ';
COMMENT ON COLUMN custload.docnum      IS 'Номер документа ФЛ';
COMMENT ON COLUMN custload.docdt       IS 'Дата выдачи документа ФЛ';
COMMENT ON COLUMN custload.birthday    IS 'Дата рождения';
COMMENT ON COLUMN custload.pinfl       IS 'ПИНФЛ физического лица';
COMMENT ON COLUMN custload.res         IS 'Резидентность';
COMMENT ON COLUMN custload.fcstatus    IS 'Статус FlexCube';
COMMENT ON COLUMN custload.bnk_br      IS 'Филиал [Признак филиала)]';
COMMENT ON COLUMN custload.res_stat    IS 'Статус результата обработки (заполняется для STATUS=PROCESSED) INSERT-создана новая запись, UPDATE-изменена старая запись';
COMMENT ON COLUMN custload.errcode     IS 'Error code';
COMMENT ON COLUMN custload.errdescr    IS 'Error description';
