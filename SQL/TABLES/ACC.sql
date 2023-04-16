CREATE TABLE acc
(
	acc_id      NUMBER(22,0) GENERATED ALWAYS AS IDENTITY (NOCACHE) PRIMARY KEY,
	bsaacid     VARCHAR2(20 CHAR) NOT NULL,
	bank_id     CHAR(5),
	branch      CHAR(3) NOT NULL,
	ccy         CHAR(3) NOT NULL,
	custid      CHAR(8) NOT NULL,
	acctype     VARCHAR2(10 CHAR),
	ac_class	VARCHAR(6 CHAR),
	ctype       CHAR(2),
	term        CHAR(2),
	gl_seq      VARCHAR2(10 CHAR),
	acc2        CHAR(5) NOT NULL,
	psav        CHAR(1),
	dealsrc     VARCHAR2(8 CHAR),
	dealid      VARCHAR2(20 CHAR),
	subdealid   VARCHAR2(20 CHAR),
	description VARCHAR2(255 CHAR),
	dto         DATE NOT NULL,
	dtc         DATE,
	dtr         DATE  DEFAULT SYSTIMESTAMP NOT NULL,
	dtm         DATE DEFAULT SYSTIMESTAMP NOT NULL,
	opentype    VARCHAR2(8 CHAR),
	gloid       NUMBER(22,0),
	glo_dc      CHAR(1),
	rec_no      NUMBER DEFAULT 1 NOT NULL,
	inp_dt      TIMESTAMP DEFAULT SYSTIMESTAMP,
	CONSTRAINT ch_acc_psav CHECK (psav IN ('0', '1'))
);

CREATE UNIQUE INDEX idx_acc_bsaacid ON acc (bsaacid);

COMMENT ON TABLE acc IS 'Банковский счет';
COMMENT ON COLUMN acc.acc_id      IS 'ИД записи';
COMMENT ON COLUMN acc.bsaacid     IS '20-значный номер счета';
COMMENT ON COLUMN acc.bank_id     IS 'МФО Банка, в котором открыт счет';
COMMENT ON COLUMN acc.branch      IS 'Бранч  FC, в котором открыт счет';
COMMENT ON COLUMN acc.ccy         IS 'Валюта';
COMMENT ON COLUMN acc.custid      IS 'Код клиента';
COMMENT ON COLUMN acc.acctype     IS 'Accounting Type';
COMMENT ON COLUMN acc.ac_class    IS 'Account Class';
COMMENT ON COLUMN acc.ctype       IS 'Тип клиента';
COMMENT ON COLUMN acc.term        IS 'Код срока';
COMMENT ON COLUMN acc.gl_seq      IS 'Порядковый номер счета в AE';
COMMENT ON COLUMN acc.acc2        IS 'Балансовый счет';
COMMENT ON COLUMN acc.psav        IS 'Признак активности/пассивности';
COMMENT ON COLUMN acc.dealsrc     IS 'Источник сделки';
COMMENT ON COLUMN acc.dealid      IS 'Код сделки';
COMMENT ON COLUMN acc.subdealid   IS 'Код субсделки';
COMMENT ON COLUMN acc.description IS 'Название счета';
COMMENT ON COLUMN acc.dto         IS 'Дата открытия счета';
COMMENT ON COLUMN acc.dtc         IS 'Дата закрытия счета';
COMMENT ON COLUMN acc.dtr         IS 'Дата регистрации записи счета';
COMMENT ON COLUMN acc.dtm         IS 'Дата модификации счета';
COMMENT ON COLUMN acc.opentype    IS 'Тип операции для открытия счета';
COMMENT ON COLUMN acc.gloid       IS 'Ссылка на ИД операции, созданной из AE, при обработке которой счет был открыт автоматически на основании ключа счета';
COMMENT ON COLUMN acc.glo_dc      IS 'Признак того, по какой стороне операции (Дт или Кт) был указан ключ счета, для которого был открыт данный счет';
COMMENT ON COLUMN acc.rec_no      IS 'Порядковый номер записи';
COMMENT ON COLUMN acc.inp_dt      IS 'Дата и время создания текущей записи';
