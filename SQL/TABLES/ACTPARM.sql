CREATE TABLE actparm
(
	acctype VARCHAR2(10 CHAR) NOT NULL,
	custype VARCHAR2(3  CHAR) NOT NULL,
	term    VARCHAR2(2  CHAR) NOT NULL,
	acc2    VARCHAR2(5  CHAR) NOT NULL,
	dtb     DATE NOT NULL,
	dte     DATE,
	UNIQUE (acctype, custype, term, acc2, dtb)
);

COMMENT ON TABLE actparm IS 'Параметризация ACC2 на основе ACCTYPE';
COMMENT ON column actparm.acctype IS 'Accounting type';
COMMENT ON column actparm.custype IS 'Тип клиента';
COMMENT ON column actparm.term    IS 'Код срока';
COMMENT ON column actparm.acc2    IS 'Балансовый счет 2 порядка';
COMMENT ON column actparm.dtb     IS 'Начало действия';
COMMENT ON column actparm.dte     IS 'Окончание действия';
