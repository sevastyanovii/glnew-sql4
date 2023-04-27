exec DB_CONF.DROP_TABLE_IF_EXISTS(user, 'AC_GROUP_TYPE_PARAM');

create table AC_GROUP_TYPE_PARAM (
    AC_GROUP_TYPE	CHAR(3) primary key
    , GROUP_DESCR	VARCHAR2(100) not null
);

comment on column AC_GROUP_TYPE_PARAM.AC_GROUP_TYPE is 'Код типа группы счетов. Используетсдля регистрации в поле ACC.AC_GROUP';
comment on column AC_GROUP_TYPE_PARAM.GROUP_DESCR is 'Название типа группы счетов';
