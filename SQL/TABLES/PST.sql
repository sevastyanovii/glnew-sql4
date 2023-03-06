CREATE TABLE pst
(
	id         NUMBER(22,0) DEFAULT pst_seq.nextval,
	pod        DATE DEFAULT trunc(sysdate) NOT NULL,
	vald       DATE DEFAULT trunc(sysdate) NOT NULL,
	bsaacid    VARCHAR2(20 BYTE) NOT NULL,
	ccy        CHAR(3 BYTE) NOT NULL,
	amnt       NUMBER(22,0) DEFAULT 0 NOT NULL,
	amntlc     NUMBER(22,0) DEFAULT 0 NOT NULL,
	pbr        CHAR(7 BYTE) NOT NULL,
	invisible  CHAR(1 BYTE),
	pcid       NUMBER(22,0) DEFAULT 0 NOT NULL,
	nrtl       VARCHAR2(300 CHAR),
	glo_ref    NUMBER(22,0),
	evtp       VARCHAR2(20 BYTE),
	procdate   DATE,
	deal_id    VARCHAR2(20 BYTE),
	subdeal_id VARCHAR2(20 BYTE),
	evt_id     VARCHAR2(20 BYTE),
	pmt_ref    VARCHAR2(20 BYTE),
	nrte       VARCHAR2(300 BYTE)
)
PARTITION BY RANGE (pod) INTERVAL (numtoyminterval (1, 'MONTH'))
(PARTITION pstpart VALUES LESS THAN (to_date(' 2023-04-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')))
ENABLE ROW MOVEMENT;

CREATE UNIQUE INDEX pk_pst ON pst (id);
ALTER TABLE pst ADD CONSTRAINT pk_pst PRIMARY KEY (id)
  USING INDEX pk_pst ENABLE;


COMMENT ON TABLE pst     IS 'Таблица для регистрации полупроводок';
COMMENT ON COLUMN pst.id         IS 'ИД полупроводки';
COMMENT ON COLUMN pst.pod        IS 'Дата проводки (дата, которой проводка отражается в балансе Банка)';
COMMENT ON COLUMN pst.vald       IS 'Дата валютирования';
COMMENT ON COLUMN pst.bsaacid    IS 'Номер счета в формате ЦБ';
COMMENT ON COLUMN pst.ccy        IS 'Буквенный код валюты счета по дебету, ссылка на таблицу CURRENCY.GLCCY';
COMMENT ON COLUMN pst.amnt       IS 'Сумма проводки, в валюте счета BSAACID, в минорных единицах, отрицательная случае проводки по дебету, положительная - по кредиту';
COMMENT ON COLUMN pst.amntlc     IS 'Сумма проводки, в валюте локализации, в мажорных единицах, отрицательная случае проводки по дебету, положительная - по кредиту';
COMMENT ON COLUMN pst.pbr        IS 'Код источника проводки';
COMMENT ON COLUMN pst.invisible  IS 'Признак подавления проводки: 1-проводка подавлена,0 или null-проводка не подавлена';
COMMENT ON COLUMN pst.pcid       IS 'ИД проводки (набора полупроводок)';
COMMENT ON COLUMN pst.nrtl       IS 'Назначение операции на языке локализации';
COMMENT ON COLUMN pst.glo_ref    IS 'Ссылка на OPERATION.ID';
COMMENT ON COLUMN pst.evtp       IS 'Тип входящего события в системе-источнике. Н-р, Commitment, Revaluation, Payment, AccountTransfer, InterestAccrual, TechCorrAdj';
COMMENT ON COLUMN pst.procdate   IS 'Дата операционного дня Банка, в которую была создана эта запись';
COMMENT ON COLUMN pst.deal_id    IS 'Идентификатор сделки в продуктовой системе (в системе-источнике)';
COMMENT ON COLUMN pst.subdeal_id IS 'Дополнительный идентификатор сделки в продуктовой системе (в системе-источнике)';
COMMENT ON COLUMN pst.evt_id     IS 'Идентификатор исходящего из продуктовой системы события. Формируется продуктовой системой';
COMMENT ON COLUMN pst.pmt_ref    IS 'Идентификатор платежного события в системе-источнике';
COMMENT ON COLUMN pst.nrte       IS 'Назначение операции на латинице';
