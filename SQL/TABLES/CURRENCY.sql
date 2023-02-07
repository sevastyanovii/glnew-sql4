CREATE TABLE currency
(
    glccy  CHAR(3) PRIMARY KEY,
    cbccy  CHAR(3) NOT NULL,
    cynm   VARCHAR2(35 CHAR) NOT NULL,
    lcd    DATE,
    nbdp   NUMBER(10,0)
);

COMMENT ON TABLE currency IS 'Справочник валют';
COMMENT ON COLUMN currency.glccy  IS 'Символьный код валюты';
COMMENT ON COLUMN currency.cbccy  IS 'Цифровой код валюты для номера счета';
COMMENT ON COLUMN currency.cynm   IS 'Сокращенное название валюты';
COMMENT ON COLUMN currency.lcd    IS 'Дата регистрации кода валюты';
COMMENT ON COLUMN currency.nbdp   IS 'Количество «копеек» в единице валюты';
