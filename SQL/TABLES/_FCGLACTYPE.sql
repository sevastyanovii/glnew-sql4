create table fcglactype (
    srcid	  VARCHAR2(64 CHAR) NOT NULL,
    fc_actype VARCHAR2(30 CHAR) NOT NULL,
    gl_actype VARCHAR2(10 CHAR) NOT NULL,
    UNIQUE (srcid, fc_actype, gl_actype)
);

COMMENT ON TABLE fcglactype IS 'Параметризация ACCTYPE для сервиса онлайн';
COMMENT ON column fcglactype.srcid     IS 'Код источника запроса на открытие счета. Ссылка на SRCPST.SRCID';
COMMENT ON column fcglactype.fc_actype IS 'Тип счета в сообщении сервиса на открытие счета';
COMMENT ON column fcglactype.gl_actype IS 'Accounting Type. Ссылка на ACTNAME.ACCTYPE';
