CREATE TABLE cbctp (
    ctype CHAR(2) PRIMARY KEY,
    name  VARCHAR2(70 CHAR) NOT NULL,
    prcd  CHAR(1),
    CONSTRAINT ch_cbctp_prcd CHECK (prcd IN ('B','C','P','G'))
) ;

COMMENT ON TABLE cbctp is 'Тип клиентов';
COMMENT ON COLUMN cbctp.ctype IS 'Код типа клиента ЦБ';
COMMENT ON COLUMN cbctp.name  IS 'Описание типа клиента ЦБ';
COMMENT ON COLUMN cbctp.prcd  IS 'Групповой тип клиента: B-Bank,C-Corporate,P-Private,G-Goverment';
