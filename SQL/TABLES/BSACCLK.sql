CREATE TABLE bsacclk (
	bsaacid	 VARCHAR2(20),
	cre_date TIMESTAMP DEFAULT systimestamp,
	upd_date TIMESTAMP,
	CONSTRAINT bsacclk_pk PRIMARY KEY(bsaacid)
);

COMMENT ON TABLE bsacclk IS  '������� ���������� ������ ��� ������������� ��������';
COMMENT ON COLUMN bsacclk.bsaacid    IS '20-������� ����� �����';
COMMENT ON COLUMN bsacclk.cre_date   IS '���� �������� ������';
COMMENT ON COLUMN bsacclk.upd_date   IS '���� ���������� ������';
