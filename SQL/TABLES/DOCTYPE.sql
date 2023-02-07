CREATE TABLE doctype
(
	doctp     CHAR(2) NOT NULL,
	doctpname VARCHAR2(128)
);

COMMENT ON TABLE doctype IS 'Типы документов';
COMMENT ON COLUMN doctype.doctp      IS 'Код типа документа';
COMMENT ON COLUMN doctype.doctpname  IS 'Описание типа документа';
