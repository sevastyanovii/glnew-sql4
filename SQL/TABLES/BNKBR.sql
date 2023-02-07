CREATE TABLE bnkbr
(
    bank_id  CHAR(5) PRIMARY KEY,
    bnkname  VARCHAR2(80 CHAR) NOT NULL,
    bnkhead  CHAR(1) NOT NULL CHECK (bnkhead IN ('Y','N'))
);

comment on table bnkbr is 'Филиалы';
comment on column bnkbr.bank_id  is 'BANK_ID. Официальный ИД по НИБДД';
comment on column bnkbr.bnkname  is 'Название филиала на гос. языке страны';
comment on column bnkbr.bnkhead  is 'Признак головного офиса';
