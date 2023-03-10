CREATE TABLE cbbs
(
	acc2     CHAR(5) NOT NULL ENABLE,
	acc0     CHAR(1),
	lvl      CHAR(1),
	psav     CHAR(1),
	name     VARCHAR2(200 CHAR),
	dtb      DATE,
	dte      DATE
);

CREATE UNIQUE INDEX pk01_bss ON cbbs (acc2);

ALTER TABLE cbbs ADD CONSTRAINT pk01_bss PRIMARY KEY (acc2)
	USING INDEX pk01_bss  ENABLE;

COMMENT ON TABLE cbbs IS 'План счетов ЦБ';
COMMENT ON COLUMN cbbs.acc2    IS 'Балансовый счет';
COMMENT ON COLUMN cbbs.acc0    IS 'Категория счета (1-Актив,2-Обязательства,3-Капитал,4-Доходы,5-Расходы,9-Непр обстоятельства)';
COMMENT ON COLUMN cbbs.lvl     IS 'Уровень БС';
COMMENT ON COLUMN cbbs.psav    IS 'Признак актив-пассив (0-актив, 1-пассив)';
COMMENT ON COLUMN cbbs.name    IS 'Название БС';
COMMENT ON COLUMN cbbs.dtb     IS 'Начало действия записи';
COMMENT ON COLUMN cbbs.dte     IS 'Окончание действия записи';
