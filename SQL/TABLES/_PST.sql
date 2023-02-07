CREATE TABLE "PST"
(
   	"ID" NUMBER(22,0) DEFAULT 0,
	"POD" DATE DEFAULT trunc(sysdate) CONSTRAINT "NN_PST_POD" NOT NULL ENABLE,
	"VALD" DATE DEFAULT trunc(sysdate) CONSTRAINT "NN_PST_VALD" NOT NULL ENABLE,
	"ACID" VARCHAR2(20) CONSTRAINT "NN_PST_ACID" NOT NULL ENABLE NOVALIDATE,
	"BSAACID" VARCHAR2(20) CONSTRAINT "NN_PST_BSAACID" NOT NULL ENABLE,
	"CCY" CHAR(3) CONSTRAINT "NN_PST_CCY" NOT NULL ENABLE,
	"AMNT" NUMBER(22,0) DEFAULT 0 CONSTRAINT "NN_PST_AMNT" NOT NULL ENABLE,
	"AMNTBC" NUMBER(22,0) DEFAULT 0 CONSTRAINT "NN_PST_AMNTBC" NOT NULL ENABLE,
	"PBR" CHAR(7) CONSTRAINT "NN_PST_PBR" NOT NULL ENABLE,
	"PDRF" NUMBER(22,0) DEFAULT 0 CONSTRAINT "NN_PST_PDRF" NOT NULL ENABLE,
	"CPDRF" NUMBER(22,0) DEFAULT 0 CONSTRAINT "NN_PST_CPDRF" NOT NULL ENABLE,
	"INVISIBLE" CHAR(1),
	"FINALETRS" CHAR(1),
	"PNAR" VARCHAR2(30),
	"CTYPE" VARCHAR2(3),
	"PCID" NUMBER(22,0) DEFAULT 0 CONSTRAINT "NN_PST_PCID" NOT NULL ENABLE,
	"PREF" CHAR(20),
	"DPMT" CHAR(3),
	"FLEX_EVENT_CODE" CHAR(4),
	"RNARLNG" VARCHAR2(300),
	"RNARSHT" VARCHAR2(100),
	"OREF" CHAR(2) DEFAULT '09',
	"DOCN" CHAR(10),
	"OREF_SRC" CHAR(1),
	"OPERATOR" VARCHAR2(35),
	"OPER_DEPT" CHAR(3),
	"AUTHORIZER" VARCHAR2(35),
	"AUTH_DEPT" CHAR(3),
	"GLO_REF" NUMBER(22,0),
	"EVTP" VARCHAR2(20),
	"PROCDATE" DATE,
	"DEAL_ID" VARCHAR2(20),
	"SUBDEALID" VARCHAR2(20),
	"EVT_ID" VARCHAR2(20),
	"PMT_REF" VARCHAR2(20),
	"FCHNG" CHAR(1),
	"PRFCNTR" CHAR(4),
	"NRT" VARCHAR2(300),
	SUPPLEMENTAL LOG DATA (ALL) COLUMNS
)

PARTITION BY RANGE ("POD") INTERVAL (NUMTOYMINTERVAL (1, 'MONTH'))
  (PARTITION "PSTPART"  VALUES LESS THAN (TO_DATE(' 2018-01-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')) )  ENABLE ROW MOVEMENT ;
  CREATE UNIQUE INDEX "IDX_PST_ID_PK" ON "PST" ("ID");

ALTER TABLE "PST" ADD CONSTRAINT "PK_PST_ID" PRIMARY KEY ("ID")
  USING INDEX "IDX_PST_ID_PK"  ENABLE;
