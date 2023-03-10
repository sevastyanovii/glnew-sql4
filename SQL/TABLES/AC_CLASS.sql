CREATE TABLE ac_class (
    class      VARCHAR2(6)   NOT NULL,
    class_name VARCHAR2(255) NOT NULL,
	dtb        DATE,
	dte        DATE,
    UNIQUE (class, class_name)
);

COMMENT ON TABLE ac_class IS 'Справочник Account Class';
COMMENT ON column ac_class.class      IS 'Account Class';
COMMENT ON column ac_class.class_name IS 'Тип клиента';
COMMENT ON COLUMN ac_class.dtb        IS 'Начало действия записи';
COMMENT ON COLUMN ac_class.dte        IS 'Окончание действия записи';
