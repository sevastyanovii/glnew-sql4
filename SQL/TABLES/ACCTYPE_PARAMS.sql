
create table ACCTYPE_PARAMS (
    AC_TYPE	varchar2(30 char) unique
    , GL_ACTYPE 	varchar2(10 char)
);

comment on table ACCTYPE_PARAMS is 'Параметрическая таблица, настройки для Accounting Type';
comment on column ACCTYPE_PARAMS.AC_TYPE is 'Тип счета (AccountingType)';
comment on column ACCTYPE_PARAMS.GL_ACTYPE is 'Accounting Type. Ссылка на ACTNAME.ACCTYPE';

-- тестовые данные
insert into ACCTYPE_PARAMS values ('PL_FCY_SPOT_PRFT', '454010001');
insert into ACCTYPE_PARAMS values ('PL_FCY_SPOT_LOSS', '553020001');
insert into ACCTYPE_PARAMS values ('POS', '171010101');
insert into ACCTYPE_PARAMS values ('EQV', '171010201');
commit;
