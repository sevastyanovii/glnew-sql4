CREATE TABLE aqpbr (
	id_rec   NUMBER(2) PRIMARY KEY,
	pbrvalue CHAR(7) NOT NULL UNIQUE
);

COMMENT ON TABLE aqpbr IS 'Список PST.PBR для прямого пересчета остатков';
COMMENT ON COLUMN aqpbr.id_rec   IS 'Ключ записи';
COMMENT ON COLUMN aqpbr.pbrvalue IS 'Код источника проводки для которого необходим прямой пересчет';
