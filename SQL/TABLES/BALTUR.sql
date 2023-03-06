CREATE TABLE baltur
(
	dat     DATE         DEFAULT trunc(SYSDATE) NOT NULL,
	datto   DATE         DEFAULT trunc(SYSDATE) NOT NULL,
	acc_id  NUMBER(22,0),
	bsaacid CHAR(20 BYTE) NOT NULL,
	datl    DATE,
	obac    NUMBER(19,0) DEFAULT 0 NOT NULL,
	obbc    NUMBER(19,0) DEFAULT 0 NOT NULL,
	dtac    NUMBER(19,0) DEFAULT 0 NOT NULL,
	dtbc    NUMBER(19,0) DEFAULT 0 NOT NULL,
	ctac    NUMBER(19,0) DEFAULT 0 NOT NULL,
	ctbc    NUMBER(19,0) DEFAULT 0 NOT NULL
)
PARTITION BY RANGE (dat) INTERVAL (numtoyminterval(1, 'MONTH'))
(PARTITION part_bal2_1 VALUES LESS THAN (to_date(' 2023-04-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')))
ENABLE ROW MOVEMENT;

CREATE INDEX bthacc2 ON baltur (bsaacid, acc_id, dat, datto);
CREATE UNIQUE INDEX btuniqdatac2 ON baltur (dat, bsaacid, acc_id);
CREATE UNIQUE INDEX btuniqdatto2 ON baltur (datto, bsaacid, acc_id);

COMMENT ON TABLE baltur     IS 'Таблица остатков и оборотов по лицевым счетам';
COMMENT ON COLUMN baltur.dat     IS 'Дата начала действия записи (дата оборота по кредиту и/или дебету счета)';
COMMENT ON COLUMN baltur.datto   IS 'Дата окончания действия записи';
COMMENT ON COLUMN baltur.acc_id  IS 'ID в таблице ACC';
COMMENT ON COLUMN baltur.bsaacid IS 'Номер лицевого счета, к которому относятся обороты и остатки в записи. В формате ЦБ';
COMMENT ON COLUMN baltur.datl    IS 'Дата последней проводки по счету BSAACID';
COMMENT ON COLUMN baltur.obac    IS 'Остаток на начало дня DAT в валюте счета';
COMMENT ON COLUMN baltur.obbc    IS 'Входящий остаток в валюте локализации';
COMMENT ON COLUMN baltur.dtac    IS 'Дебетовый оборот в валюте счета BSAACID';
COMMENT ON COLUMN baltur.dtbc    IS 'Дебетовый оборот в валюте локализации';
COMMENT ON COLUMN baltur.ctac    IS 'Кредитовый оборот в валюте счета BSAACID';
COMMENT ON COLUMN baltur.ctbc    IS 'Кредитовый оборот в валюте локализации';
