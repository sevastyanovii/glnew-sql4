drop table PARAMS;

create table PARAMS (
      CCY_LC	CHAR(3 CHAR)	NOT NULL UNIQUE
    , POS_TYPE3L_DR	VARCHAR2(300 CHAR)	NOT NULL
    , POS_TYPE3L_CR	VARCHAR2(300 CHAR)	NOT NULL
    , POS_TYPE3E_DR	VARCHAR2(300 CHAR)	NOT NULL
    , POS_TYPE3E_CR	VARCHAR2(300 CHAR)	NOT NULL
    , POS_TYPE4E	VARCHAR2(300 CHAR)	NOT NULL
    , POS_TYPE4L	VARCHAR2(300 CHAR)	NOT NULL
);

comment on column PARAMS.CCY_LC is 'Локальная валюта. Буквенный код валюты , ссылка на таблицу CURRENCY.GLCCY.';
comment on column PARAMS.POS_TYPE3L_DR is 'Назначение операции для проводки по отражению курсовой на языке локализации (расход)';
comment on column PARAMS.POS_TYPE3L_CR is 'Назначение операции для проводки по отражению курсовой на языке локализации (доход)';
comment on column PARAMS.POS_TYPE3E_DR is 'Назначение операции для проводки по отражению курсовой на латинице (расход)';
comment on column PARAMS.POS_TYPE3E_CR is 'Назначение операции для проводки по отражению курсовой на латинице (доход)';
comment on column PARAMS.POS_TYPE4E is 'Назначение операции для проводки между счетам эквивалентов валютных позиций на латинице';
comment on column PARAMS.POS_TYPE4L is 'Назначение операции для проводки между счетам эквивалентов валютных позиций на языке локализации';

insert into PARAMS (CCY_LC, POS_TYPE3L_DR, POS_TYPE3L_CR, POS_TYPE3E_DR, POS_TYPE3E_CR, POS_TYPE4E, POS_TYPE4L)
values ('UZS', 'Расход (...)', 'Доход (...)', 'Expense (...)', 'Income (...)'
, 'Purpose of the operation of posting equivalents of currency positions in Latin between accounts'
, 'Assigning an operation for posting currency position equivalents between accounts in the localization language');

commit;
