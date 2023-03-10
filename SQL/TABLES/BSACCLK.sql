CREATE TABLE bsacclk (
	bsaacid	 VARCHAR2(20),
	cre_date TIMESTAMP DEFAULT systimestamp,
	upd_date TIMESTAMP,
	CONSTRAINT bsacclk_pk PRIMARY KEY(bsaacid)
);

COMMENT ON TABLE bsacclk IS  'Таблица блокировки счетов при корректировке остатков';
COMMENT ON COLUMN bsacclk.bsaacid    IS '20-значный номер счета';
COMMENT ON COLUMN bsacclk.cre_date   IS 'Дата создания записи';
COMMENT ON COLUMN bsacclk.upd_date   IS 'Дата обновления записи';
