CREATE TABLE operation
(
	gloid      NUMBER(22,0) DEFAULT operation_seq.nextval,
	id_pst     VARCHAR2(20 BYTE),
	ae_pst_ref NUMBER(22,0),
	src_pst    VARCHAR2(7 BYTE),
	inp_method VARCHAR2(7 BYTE),
	evt_id     VARCHAR2(20 BYTE),
	deal_id    VARCHAR2(20 BYTE),
	pmt_ref    VARCHAR2(20 BYTE),
	vdate      DATE NOT NULL,
	ots        TIMESTAMP(6) NOT NULL,
	postdate   DATE,
	procdate   DATE NOT NULL,
	nrte       VARCHAR2(300 BYTE),
	nrtl       VARCHAR2(300 BYTE),
	ac_dr      VARCHAR2(20 BYTE),
	ccy_dr     CHAR(3 BYTE) NOT NULL,
	amt_dr     NUMBER(19,3) NOT NULL,
	amtlc_dr   NUMBER(19,3),
	rate_dr    NUMBER(15,9),
	eqv_dr     NUMBER(19,3),
	ac_cr      VARCHAR2(20 BYTE),
	ccy_cr     CHAR(3 BYTE) NOT NULL,
	amt_cr     NUMBER(19,3) NOT NULL,
	amtlc_cr   NUMBER(19,3),
	rate_cr    NUMBER(15,9),
	eqv_cr     NUMBER(19,3),
	pst_scheme CHAR(16 BYTE),
	strn       CHAR(1 BYTE) NOT NULL,
	strn_ref   VARCHAR2(128 BYTE),
	cr_dt      TIMESTAMP(6) DEFAULT systimestamp NOT NULL,
	state      VARCHAR2(32 BYTE),
	emsg       VARCHAR2(4000 BYTE),
	acckey_dr  VARCHAR2(512 BYTE),
	acckey_cr  VARCHAR2(512 BYTE),
	oper_class VARCHAR2(10 BYTE),
	evtp       VARCHAR2(20 BYTE),
	subdeal_id VARCHAR2(20 BYTE),
	CONSTRAINT oper_state  CHECK (state in ('LOAD','ERCHK','POST','ERPST')),
	CONSTRAINT oper_strn   CHECK (strn in ('Y','N')),
	CONSTRAINT oper_ccy_cr CHECK (trim(ccy_cr) <> ''),
	CONSTRAINT oper_ccy_dr CHECK (trim(ccy_dr) <> '')

)
PARTITION BY RANGE (procdate) INTERVAL (numtodsinterval(10, 'DAY'))
(PARTITION part_oper_1 VALUES LESS THAN (TO_DATE(' 2023-04-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')))
ENABLE ROW MOVEMENT;

CREATE UNIQUE INDEX pk_operation ON operation (gloid);
ALTER TABLE operation ADD CONSTRAINT pk_operation PRIMARY KEY (gloid)
  USING INDEX pk_operation ENABLE;

/* state
LOAD   Операция загружена. Все проверки прошли успешно. Выполнено обогащение данных.
       Доп. обработка не проводилась, проводки не формировались
ERCHK  Операция загружена, при проверке данных обнаружена ошибка.
POST   Все проводки по операции сформированы.
ERPST  Возникла ошибка при формировании проводок.
*/

COMMENT ON TABLE operation     IS 'Таблица для регистрации операции GL - первичной информации для последующего формирования проводок GL';
COMMENT ON COLUMN operation.gloid      IS 'Идентификатор записи (входящей в RBGL проводки)';
COMMENT ON COLUMN operation.id_pst     IS 'Идентификатор проводки из SmartAE (ae_in_pst.id)';
COMMENT ON COLUMN operation.ae_pst_ref IS 'Ссылка на AE_IM_PST (ID таблицы AE_IM_PST)';
COMMENT ON COLUMN operation.src_pst    IS 'Вид бухгалтерского учета (подсистема), для которой предназначена проводка. Финансовый, налоговый, управленческий и тд';
COMMENT ON COLUMN operation.inp_method IS 'Способ, которым была создана запись в этой таблице: AE-Загрузка сообщения AE,M-Manual (Ручной ввод),B-Batch (Пакетная загрузка проводок)';
COMMENT ON COLUMN operation.evt_id     IS 'Идентификатор исходящего из продуктовой системы события, формируется в продуктовой системе';
COMMENT ON COLUMN operation.deal_id    IS 'Идентификатор сделки в продуктовой системе (в системе-источнике)';
COMMENT ON COLUMN operation.pmt_ref    IS 'Идентификатор платежного события в системе-источнике';
COMMENT ON COLUMN operation.vdate      IS 'Дата валютирования проводки';
COMMENT ON COLUMN operation.ots        IS 'Отметка времени операции в продуктовой системе, породившей проводку';
COMMENT ON COLUMN operation.postdate   IS 'Дата проводки (дата, которой проводка отражается в балансе Банка)';
COMMENT ON COLUMN operation.procdate   IS 'Дата операционного дня Банка, в которую была создана эта запись';
COMMENT ON COLUMN operation.nrte       IS 'Назначение операции на латинице';
COMMENT ON COLUMN operation.nrtl       IS 'Назначение операции на языке локализации';
COMMENT ON COLUMN operation.ac_dr      IS 'Дебетуемый счет в проводке. В формате ЦБ. Обязательно должно быть задано одно из полей: AC_DR или ACCKEY_DR';
COMMENT ON COLUMN operation.ccy_dr     IS 'Буквенный код валюты счета по дебету, ссылка на таблицу CURRENCY.GLCCY';
COMMENT ON COLUMN operation.amt_dr     IS 'Сумма проводки по дебетуемому счету, в валюте счета по дебету, в мажорных единицах, неотрицательная';
COMMENT ON COLUMN operation.amtlc_dr   IS 'Сумма проводки по дебетуемому счету, в валюте локализации, в мажорных единицах, неотрицательная';
COMMENT ON COLUMN operation.rate_dr    IS 'Официальный курс валюты по дебету на дату POSTDATE. Выражает стоимость одной мажорной единицы иностранной валюты, выраженную в количестве мажорных единицах валюты локализации';
COMMENT ON COLUMN operation.eqv_dr     IS 'Эквивалент суммы AMT_DR, выраженный в мажорных единицах валюты локализации';
COMMENT ON COLUMN operation.ac_cr      IS 'Кредитуемый счет в проводке. В формате ЦБ. Обязательно должно быть задано одно из полей: AC_DR или ACCKEY_DR';
COMMENT ON COLUMN operation.ccy_cr     IS 'Буквенный код валюты счета по кредиту, ссылка на таблицу CURRENCY.GLCCY';
COMMENT ON COLUMN operation.amt_cr     IS 'Сумма проводки по кредитовому счету, в валюте счета по кредиту, в мажорных единицах, неотрицательная';
COMMENT ON COLUMN operation.amtlc_cr   IS 'Сумма проводки по кредиту в валюте локализации, в мажорных единицах, неотрицательная';
COMMENT ON COLUMN operation.rate_cr    IS 'Официальный курс валюты по кредиту на дату POSTDATE. Выражает стоимость одной мажорной единицы иностранной валюты, выраженную в количестве мажорных единицах валюты локализации';
COMMENT ON COLUMN operation.eqv_cr     IS 'Эквивалент суммы AMT_CR в валюте локализации, в мажорных единицах';
COMMENT ON COLUMN operation.pst_scheme IS 'Схема (шаблон) проводок, формируемых для операции GL. S-Standard-Стандартная проводка в одном филиале,E-Exch-межвалютная проводка';
COMMENT ON COLUMN operation.strn       IS 'Признак сторнирующей проводки (Y-да, N-нет)';
COMMENT ON COLUMN operation.strn_ref   IS 'Идентификатор (EVT_ID) сторнируемого события, заполняется только для сторнирующей проводки';
COMMENT ON COLUMN operation.cr_dt      IS 'Время создания операции';
COMMENT ON COLUMN operation.state      IS 'Статус обработки операции. Заполняется в зависимости от стадии обработки операции и результата обработки';
COMMENT ON COLUMN operation.emsg       IS 'Текст сообщения об ошибке обработки';
COMMENT ON COLUMN operation.acckey_dr  IS 'Ключ счета для проводки по дебету';
COMMENT ON COLUMN operation.acckey_cr  IS 'Ключ счета для проводки по кредиту';
COMMENT ON COLUMN operation.oper_class IS 'Вид операции (ручная/автоматическая)';
COMMENT ON COLUMN operation.evtp       IS 'Тип входящего события в системе-источнике. Н-р., Commitment, Revaluation, Payment, AccountTransfer, InterestAccrual, TechCorrAdj';
COMMENT ON COLUMN operation.subdeal_id IS 'Дополнительный идентификатор сделки в продуктовой системе (в системе-источнике)';
