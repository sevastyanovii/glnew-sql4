CREATE TABLE ae_in_pst
(
    id         NUMBER(22,0) DEFAULT ae_pst_seq.nextval,
	src_pst	   VARCHAR2(128 BYTE) NOT NULL,
	evt_id	   VARCHAR2(128 BYTE) NOT NULL,
	deal_id	   VARCHAR2(128 BYTE),
	subdeal_id VARCHAR2(128 BYTE),
	pmt_ref	   VARCHAR2(128 BYTE),
	vdate	   DATE	NOT NULL,
	ots	       TIMESTAMP(6) NOT NULL,
	nrte	   VARCHAR2(300 BYTE) NOT NULL,
	nrtl	   VARCHAR2(300 CHAR) NOT NULL,
	strn	   CHAR(1 BYTE) NOT NULL,
	strnrf	   VARCHAR2(128 BYTE),
	ac_dr	   CHAR(20 BYTE),
	ccy_dr	   CHAR(3 BYTE) NOT NULL,
	amt_dr	   NUMBER(19,3) NOT NULL,
	ac_cr	   CHAR(20 BYTE),
	ccy_cr	   CHAR(3 BYTE) NOT NULL,
	amt_cr	   NUMBER(19,3) NOT NULL,
	ecode	   NUMBER(22,0),
	emsg	   VARCHAR2(4000 BYTE),
	acckey_dr  VARCHAR2(512 BYTE),
	acckey_cr  VARCHAR2(512 BYTE),
	evtp	   VARCHAR2(20 BYTE),
	ae_log_id        NUMBER (19) NOT NULL,
	ae_source_system VARCHAR2 (6 CHAR) NOT NULL,
	ae_rule_name     VARCHAR2 (255 CHAR) NOT NULL,
	ae_processed_at  TIMESTAMP NOT NULL
)
PARTITION BY RANGE (id) INTERVAL (1000000)
(PARTITION pk_ae_in_pst_part1  VALUES LESS THAN (1000000)) ENABLE ROW MOVEMENT;

CREATE INDEX idx_ae_in_pst1 ON ae_in_pst (vdate);
CREATE UNIQUE INDEX pk_ae_in_pst ON ae_in_pst (id);
ALTER TABLE ae_in_pst ADD CONSTRAINT pk_ae_in_pst PRIMARY KEY (id)
    USING INDEX pk_ae_in_pst  ENABLE;

GRANT SELECT,INSERT,UPDATE,DELETE ON ae_in_pst TO gl2tds;

COMMENT ON TABLE ae_in_pst     IS 'Таблица для регистрации сообщений AE в формате операций GL';
COMMENT ON COLUMN ae_in_pst.id         IS 'Идентификатор записи в AE_IN_PST';
COMMENT ON COLUMN ae_in_pst.src_pst    IS 'Вид бухгалтерского учета (подсистема), для которой предназначена проводка. Финансовый, налоговый, управленческий и т.д';
COMMENT ON COLUMN ae_in_pst.evt_id     IS 'Идентификатор исходящего из продуктовой системы события. Формируется продуктовой системой';
COMMENT ON COLUMN ae_in_pst.deal_id    IS 'Идентификатор сделки в системе-источнике';
COMMENT ON COLUMN ae_in_pst.subdeal_id IS 'Дополнительный идентификатор сделки в системе-источнике';
COMMENT ON COLUMN ae_in_pst.pmt_ref    IS 'Идентификатор платежного события в системе-источнике';
COMMENT ON COLUMN ae_in_pst.vdate      IS 'Дата валютирования проводки';
COMMENT ON COLUMN ae_in_pst.ots        IS 'Отметка времени операции в продуктовой системе, породившей проводку';
COMMENT ON COLUMN ae_in_pst.nrte       IS 'Назначение операции на латинице';
COMMENT ON COLUMN ae_in_pst.nrtl       IS 'Назначение операции на языке локализации';
COMMENT ON COLUMN ae_in_pst.strn       IS 'Признак сторнирующей проводки (Y-да, N-нет)';
COMMENT ON COLUMN ae_in_pst.strnrf     IS 'Идентификатор (EVT_ID) сторнируемого события, заполняется только для сторнирующей проводки';
COMMENT ON COLUMN ae_in_pst.ac_dr      IS 'Дебетуемый счет в проводке. В формате ЦБ. Обязательно должно быть задано одно из полей: AC_DR или ACCKEY_DR';
COMMENT ON COLUMN ae_in_pst.ccy_dr     IS 'Буквенный код валюты счета по дебету, ссылка на CURRENCY.GLCCY';
COMMENT ON COLUMN ae_in_pst.amt_dr     IS 'Сумма проводки по дебетуемому счету, в валюте счета по дебету, в мажорных единицах, неотрицательная';
COMMENT ON COLUMN ae_in_pst.ac_cr      IS 'Кредитуемый счет в проводке. В формате ЦБ. Обязательно должно быть задано одно из полей: AC_DR или ACCKEY_DR';
COMMENT ON COLUMN ae_in_pst.ccy_cr     IS 'Буквенный код валюты счета по кредиту, ссылка на таблицу CURRENCY.GLCCY';
COMMENT ON COLUMN ae_in_pst.amt_cr     IS 'Сумма проводки по кредитовому счету, в валюте счета по кредиту, в мажорных единицах, неотрицательная';
COMMENT ON COLUMN ae_in_pst.ecode      IS 'Код результата обработки входящего сообщения. 0 - обработано без ошибки. Больше 0 - код ошибки обработки входящего сообщения по классификации GL';
COMMENT ON COLUMN ae_in_pst.emsg       IS 'Сообщение о результате обработки входящей проводки. Если проводка успешно обработано, то "SUCCESS"';
COMMENT ON COLUMN ae_in_pst.acckey_dr  IS 'Ключ счета для проводки по дебету';
COMMENT ON COLUMN ae_in_pst.acckey_cr  IS 'Ключ счета для проводки по кредиту';
COMMENT ON COLUMN ae_in_pst.evtp       IS 'Тип входящего события в системе-источнике. Напр., Commitment, Revaluation, Payment, AccountTransfer, InterestAccrual, TechCorrAdj';
COMMENT ON COLUMN ae_in_pst.ae_log_id        IS 'Идентификатор входящего события в журнале ядра SmartAE';
COMMENT ON COLUMN ae_in_pst.ae_source_system IS 'Система-источник входящего события в терминах SmartAE';
COMMENT ON COLUMN ae_in_pst.ae_rule_name     IS 'Наименование бизнес-правила, создавшего исходящее событие';
COMMENT ON COLUMN ae_in_pst.ae_processed_at  IS 'Момент обработки события адаптером исходящих событий';
