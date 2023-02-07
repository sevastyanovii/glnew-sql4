CREATE TABLE currates
(
	dat   DATE DEFAULT trunc(SYSDATE) NOT NULL,
	ccy   CHAR(3) NOT NULL,
	rate  NUMBER(15,9) DEFAULT 0,
	amnt  NUMBER(10,2) DEFAULT 0,
	rate0 NUMBER(15,9)
) ;

CREATE INDEX crccy ON currates (ccy, dat);
ALTER TABLE currates ADD CONSTRAINT pk01_currates PRIMARY KEY (dat, ccy);

COMMENT ON TABLE currates IS 'Курсы валют';
COMMENT ON COLUMN currates.dat   IS 'Дата';
COMMENT ON COLUMN currates.ccy   IS 'Код валюты currency.glccy';
COMMENT ON COLUMN currates.rate  IS 'Курс';
COMMENT ON COLUMN currates.amnt  IS 'Количество единиц ин. валюты для курса';
COMMENT ON COLUMN currates.rate0 IS 'Курс предыдущего дня';
