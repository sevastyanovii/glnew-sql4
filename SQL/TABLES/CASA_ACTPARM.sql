CREATE TABLE casa_actparm
(
	ac_class VARCHAR(6),
	custype  CHAR(2)    NOT NULL,
	acc2     CHAR(5)    NOT NULL,
	dtb      DATE       NOT NULL,
	dte      DATE,
	UNIQUE (ac_class, custype)
);

COMMENT ON TABLE casa_actparm is 'Параметры ACC2 для CASA';
COMMENT ON COLUMN casa_actparm.ac_class IS 'Account Class';
COMMENT ON COLUMN casa_actparm.custype  IS 'Тип клиента';
COMMENT ON COLUMN casa_actparm.acc2     IS 'Балансовый счет 2 порядка';
COMMENT ON COLUMN casa_actparm.dtb      IS 'Начало действия';
COMMENT ON COLUMN casa_actparm.dte      IS 'Окончание действия';
