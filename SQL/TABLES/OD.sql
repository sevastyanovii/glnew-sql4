CREATE TABLE od (
    curdate DATE PRIMARY KEY,
    phase   VARCHAR2(16) NOT NULL UNIQUE,
    lwdate  DATE NOT NULL UNIQUE,
    lwdate_status VARCHAR2(16) NOT NULL UNIQUE,
    pdmod   VARCHAR2(32)	DEFAULT	'DIRECT' NOT NULL,
	prc     VARCHAR2(32)	DEFAULT	'ALLOWED',
	acsmode	VARCHAR2(10)	DEFAULT	'FULL',
    CONSTRAINT ch_od_phase      CHECK (phase         in ('ONLINE','PRE_COB','COB')),
    CONSTRAINT ch_od_lwd_status CHECK (lwdate_status in ('OPEN', 'CLOSED')),
    CONSTRAINT ch_od_pdmod      CHECK (pdmod         in ('DIRECT', 'BUFFER')),
    CONSTRAINT ch_od_prc        CHECK (prc           in ('REQUIRED', 'STOPPED', 'ALLOWED', 'STARTED')),
    CONSTRAINT ch_od_acsmd      CHECK (acsmode       in ('FULL', 'LIMIT'))
);

COMMENT ON TABLE od IS 'Операционный день';
COMMENT ON COLUMN od.curdate   IS 'Current operday';
COMMENT ON COLUMN od.phase     IS 'Фаза опердня';
COMMENT ON COLUMN od.lwdate    IS 'Предыдущий ОД';
COMMENT ON COLUMN od.lwdate_status IS 'Баланс предыдущего дня';
COMMENT ON COLUMN od.pdmod     IS 'Режим записи проводок';
COMMENT ON COLUMN od.prc       IS 'Статус обработки проводок';
COMMENT ON COLUMN od.acsmode   IS 'Режим доступа (полный/ограниченный)';
/*
CURDATE       - текущий операционный день
PHASE         - фаза опердня
    ONLINE    - онлайн
    PRE_COB   - выполняется COB BarsGL
    COB       - закончился COB BarsGL, но новый ОД еще не открылся
LWDATE        - предыдущий ОД (рабочий день, предшествующий ОД)
LWD_STATUS    - баланс предыдущего дня (обычно весь день открыт)
    OPEN      - открыт, backvalue за вчера ложатся во вчера
    CLOSE     - закрыт, backvalue за вчера ложатся в сегодня
PDMOD         - режим записи проводок (на проде BUFFER, на тесте удобней работать в DIRECT)
    BUFFER    - проводки ложатся в GL_PD, попадают в PD после синхронизации или после СОВ
    DIRECT    - проводки ложатся напрямую в PD
PRC           - режим обработки проводок задачей EtlStructureMonitor
    REQUIRED  - запрос остановки
    STOPPED   - обработка остановлена
    ALLOWED   - обработка разрешена
    STARTED   - обработка запущена
ASCMODE       - режим доступа, на тесте всегда FULL
*/