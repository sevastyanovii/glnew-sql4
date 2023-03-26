exec db_conf.DROP_TABLE_IF_EXISTS(user, 'CURRENCY');

CREATE TABLE currency
(
    glccy  CHAR(3) PRIMARY KEY,
    cbccy  CHAR(3) NOT NULL,
    cynm   VARCHAR2(35 CHAR) NOT NULL,
    nbdp   NUMBER(10,0) DEFAULT 0 NOT NULL,
    cbrate_set CHAR(1),
    dto    DATE,
    dtc    DATE,
    act    CHAR(1)
);

COMMENT ON TABLE currency IS 'Справочник валют';
COMMENT ON COLUMN currency.glccy  IS 'Символьный код валюты';
COMMENT ON COLUMN currency.cbccy  IS 'Цифровой код валюты для номера счета';
COMMENT ON COLUMN currency.cynm   IS 'Сокращенное название валюты';
COMMENT ON COLUMN currency.nbdp   IS 'Количество «копеек» в единице валюты (десятичный логарифм числа минорных единиц в номинальной)';
COMMENT ON COLUMN currency.cbrate_set   IS 'Установлен курс ЦБ. 1 – Да, 0 - Нет';
COMMENT ON COLUMN currency.dto   IS 'Дата активации кода валюты';
COMMENT ON COLUMN currency.dtc   IS 'Дата деактивации кода валюты';
COMMENT ON COLUMN currency.act   IS 'Признак активности валюты A – активная, Z - неактивная';
