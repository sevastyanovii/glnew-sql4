CREATE TABLE acc_h
(
	acc_id      NUMBER(22,0) NOT NULL,
	bsaacid     VARCHAR2(20 CHAR) NOT NULL,
	bank_id     CHAR(5),
	branch      CHAR(3) NOT NULL,
	ccy         CHAR(3) NOT NULL,
	custid      CHAR(8) NOT NULL,
	acctype     VARCHAR2(10 CHAR) NOT NULL,
	ctype       CHAR(2),
	term        CHAR(2),
	gl_seq      VARCHAR2(10 CHAR),
	acc2        CHAR(5) NOT NULL,
	psav        CHAR(1) NOT NULL,
	dealsrc     VARCHAR2(8 CHAR),
	dealid      VARCHAR2(20 CHAR),
	subdealid   VARCHAR2(20 CHAR),
	description VARCHAR2(255 CHAR),
	dto         DATE NOT NULL,
	dtc         DATE,
	dtr         DATE NOT NULL,
	dtm         DATE NOT NULL,
	opentype    VARCHAR2(8 CHAR),
	gloid       NUMBER(22,0),
	glo_dc      CHAR(1),
	rec_no      NUMBER NOT NULL,
	inp_dt      TIMESTAMP NOT NULL,
	--
	ts          TIMESTAMP NOT NULL,
	chg_vector  CHAR(1) NOT NULL
);

CREATE INDEX idx_acc_h_acc_id  ON acc_h (acc_id);
CREATE INDEX idx_acc_h_bsaacid ON acc_h (bsaacid);

COMMENT ON TABLE acc_h IS 'Банковский счет';
COMMENT ON COLUMN acc_h.acc_id      IS 'ИД записи';
COMMENT ON COLUMN acc_h.bsaacid     IS '20-значный номер счета';
COMMENT ON COLUMN acc_h.bank_id     IS 'МФО Банка, в котором открыт счет';
COMMENT ON COLUMN acc_h.branch      IS 'Бранч  FC, в котором открыт счет';
COMMENT ON COLUMN acc_h.ccy         IS 'Валюта';
COMMENT ON COLUMN acc_h.custid      IS 'Код клиента';
COMMENT ON COLUMN acc_h.acctype     IS 'Accounting Type';
COMMENT ON COLUMN acc_h.ctype       IS 'Тип клиента';
COMMENT ON COLUMN acc_h.term        IS 'Код срока';
COMMENT ON COLUMN acc_h.gl_seq      IS 'Порядковый номер счета в AE';
COMMENT ON COLUMN acc_h.acc2        IS 'Балансовый счет';
COMMENT ON COLUMN acc_h.psav        IS 'Признак активности/пассивности';
COMMENT ON COLUMN acc_h.dealsrc     IS 'Источник сделки';
COMMENT ON COLUMN acc_h.dealid      IS 'Код сделки';
COMMENT ON COLUMN acc_h.subdealid   IS 'Код субсделки';
COMMENT ON COLUMN acc_h.description IS 'Название счета';
COMMENT ON COLUMN acc_h.dto         IS 'Дата открытия счета';
COMMENT ON COLUMN acc_h.dtc         IS 'Дата закрытия счета';
COMMENT ON COLUMN acc_h.dtr         IS 'Дата регистрации записи счета';
COMMENT ON COLUMN acc_h.dtm         IS 'Дата модификации счета';
COMMENT ON COLUMN acc_h.opentype    IS 'Тип операции для открытия счета';
COMMENT ON COLUMN acc_h.gloid       IS 'Ссылка на ИД операции, созданной из AE, при обработке которой счет был открыт автоматически на основании ключа счета';
COMMENT ON COLUMN acc_h.glo_dc      IS 'Принзак того, по какой стороне операции (Дт или Кт) был указан ключ счета, для которого был открыт данный счет';
COMMENT ON COLUMN acc_h.rec_no      IS 'Порядковый номер записи';
COMMENT ON COLUMN acc_h.inp_dt      IS 'Дата и время создания текущей записи';
COMMENT ON COLUMN acc_h.ts          IS 'Момент изменения/добавления родительской записи в таблице acc';
COMMENT ON COLUMN acc_h.chg_vector  IS 'Тип изменения родительской записи в таблице acc (I/U)';
