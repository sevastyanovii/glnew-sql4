create table position_acc (
      ccy	char(3 char) not null
    , bank_id	char(3 byte) not null
    , ac_pos	varchar2(20 char) not null
    , ac_pos_eqv	varchar2(20 char)	not null
    , constraint un_position_acc unique (ccy, bank_id)
);

comment on column position_acc.ccy is 'Буквенный код валюты счета по дебету, ссылка на таблицу CURRENCY.GLCCY';
comment on column position_acc.bank_id is 'Код филиала. Ссылка на таблицуBNKBR';
comment on column position_acc.ac_pos is 'Счет позиции, открытый для валюты CCY, в формате ЦБ';
comment on column position_acc.ac_pos_eqv is 'Счет эквивалента позиции для валюты CCY, открытый в локальной валюте, в формате ЦБ';

