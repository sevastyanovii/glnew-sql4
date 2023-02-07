CREATE TABLE cal
(
	dat DATE DEFAULT trunc(SYSDATE) NOT NULL,
	hol CHAR(1) NOT NULL,
	ccy CHAR(3) NOT NULL
) ;
CREATE UNIQUE INDEX calccy ON cal (ccy, dat);

ALTER TABLE cal ADD CONSTRAINT pk01_cal PRIMARY KEY (dat, ccy)
  USING INDEX CALCCY  ENABLE;

COMMENT ON TABLE cal IS 'Календарь';
COMMENT ON COLUMN cal.dat   IS 'Дата';
COMMENT ON COLUMN cal.hol   IS 'Признак выходного дня';
COMMENT ON COLUMN cal.ccy   IS 'Валюта';
