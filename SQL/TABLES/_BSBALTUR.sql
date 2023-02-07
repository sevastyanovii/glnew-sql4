CREATE TABLE "BSBALTUR"
(
	"DAT" DATE DEFAULT trunc(SYSDATE),
	"DATTO" DATE DEFAULT trunc(SYSDATE),
	"BSSACC" CHAR(5),
	"BRCA" CHAR(4),
	"OBAC" NUMBER(19,0) DEFAULT 0,
	"OBBCRUR" NUMBER(19,0) DEFAULT 0,
	"OBBCVAL" NUMBER(19,0) DEFAULT 0,
	"OBUC" NUMBER(19,0) DEFAULT 0,
	"DTAC" NUMBER(19,0) DEFAULT 0,
	"DTBCRUR" NUMBER(19,0) DEFAULT 0,
	"DTBCVAL" NUMBER(19,0) DEFAULT 0,
	"DTUC" NUMBER(19,0) DEFAULT 0,
	"CTAC" NUMBER(19,0) DEFAULT 0,
	"CTBCRUR" NUMBER(19,0) DEFAULT 0,
	"CTBCVAL" NUMBER(19,0) DEFAULT 0,
	"CTUC" NUMBER(19,0) DEFAULT 0,
	"SOBAC" NUMBER(14,0) DEFAULT 0,
	"SOBBCRUR" NUMBER(19,0) DEFAULT 0,
	"SOBBCVAL" NUMBER(14,0) DEFAULT 0,
	"SOBUC" NUMBER(14,0) DEFAULT 0,
	"SDTAC" NUMBER(14,0) DEFAULT 0,
	"SDTBCRUR" NUMBER(19,0) DEFAULT 0,
	"SDTBCVAL" NUMBER(14,0) DEFAULT 0,
	"SDTUC" NUMBER(14,0) DEFAULT 0,
	"SCTAC" NUMBER(14,0) DEFAULT 0,
	"SCTBCRUR" NUMBER(19,0) DEFAULT 0,
	"SCTBCVAL" NUMBER(14,0) DEFAULT 0,
	"SCTUC" NUMBER(14,0) DEFAULT 0,

	CONSTRAINT "NN01_BSBALTUR_DAT" CHECK ("DAT" is not null) ENABLE,
	CONSTRAINT "NN01_BSBALTUR_DATTO" CHECK ("DATTO" is not null) ENABLE,
	CONSTRAINT "NN01_BSBALTUR_BSSACC" CHECK ("BSSACC" is not null) ENABLE,
	CONSTRAINT "NN01_BSBALTUR_BRCA" CHECK ("BRCA" is not null) ENABLE,
	CONSTRAINT "NN01_BSBALTUR_OBAC" CHECK ("OBAC" is not null) ENABLE,
	CONSTRAINT "NN01_BSBALTUR_OBBCRUR" CHECK ("OBBCRUR" is not null) ENABLE,
	CONSTRAINT "NN01_BSBALTUR_OBBCVAL" CHECK ("OBBCVAL" is not null) ENABLE,
	CONSTRAINT "NN01_BSBALTUR_OBUC" CHECK ("OBUC" is not null) ENABLE,
	CONSTRAINT "NN01_BSBALTUR_DTAC" CHECK ("DTAC" is not null) ENABLE,
	CONSTRAINT "NN01_BSBALTUR_DTBCRUR" CHECK ("DTBCRUR" is not null) ENABLE,
	CONSTRAINT "NN01_BSBALTUR_DTBCVAL" CHECK ("DTBCVAL" is not null) ENABLE,
	CONSTRAINT "NN01_BSBALTUR_DTUC" CHECK ("DTUC" is not null) ENABLE,
	CONSTRAINT "NN01_BSBALTUR_CTAC" CHECK ("CTAC" is not null) ENABLE,
	CONSTRAINT "NN01_BSBALTUR_CTBCRUR" CHECK ("CTBCRUR" is not null) ENABLE,
	CONSTRAINT "NN01_BSBALTUR_CTBCVAL" CHECK ("CTBCVAL" is not null) ENABLE,
	CONSTRAINT "NN01_BSBALTUR_CTUC" CHECK ("CTUC" is not null) ENABLE,
	CONSTRAINT "NN01_BSBALTUR_SOBAC" CHECK ("SOBAC" is not null) ENABLE,
	CONSTRAINT "NN01_BSBALTUR_SOBBCRUR" CHECK ("SOBBCRUR" is not null) ENABLE,
	CONSTRAINT "NN01_BSBALTUR_SOBBCVAL" CHECK ("SOBBCVAL" is not null) ENABLE,
	CONSTRAINT "NN01_BSBALTUR_SOBUC" CHECK ("SOBUC" is not null) ENABLE,
	CONSTRAINT "NN01_BSBALTUR_SDTAC" CHECK ("SDTAC" is not null) ENABLE,
	CONSTRAINT "NN01_BSBALTUR_SDTBCRUR" CHECK ("SDTBCRUR" is not null) ENABLE,
	CONSTRAINT "NN01_BSBALTUR_SDTBCVAL" CHECK ("SDTBCVAL" is not null) ENABLE,
	CONSTRAINT "NN01_BSBALTUR_SDTUC" CHECK ("SDTUC" is not null) ENABLE,
	CONSTRAINT "NN01_BSBALTUR_SCTAC" CHECK ("SCTAC" is not null) ENABLE,
	CONSTRAINT "NN01_BSBALTUR_SCTBCRUR" CHECK ("SCTBCRUR" is not null) ENABLE,
	CONSTRAINT "NN01_BSBALTUR_SCTBCVAL" CHECK ("SCTBCVAL" is not null) ENABLE,
	CONSTRAINT "NN01_BSBALTUR_SCTUC" CHECK ("SCTUC" is not null) ENABLE
);
