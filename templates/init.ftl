-- DEFINE USER=&1
-- DEFINE PASSWD=&2
-- DEFINE SYS_USER=&3
-- DEFINE SYS_PASSWD=&4
-- DEFINE DB=&5
--
-- conn &USER/&PASSWD@&DB

SET AUTOCOMMIT OFF

SET TIMING ON

SET SERVEROUTPUT ON

SET ECHO ON

SPOOL INSTALL.log REPLACE

WHENEVER SQLERROR EXIT 1 ROLLBACK

SET ERRORLOGGING ON
SET ERRORLOGGING ON TRUNCATE

SET VERIFY ON

SET SQLBLANKLINES ON

--===================== Script version ${version.version}, applyed to ${version.applyedTo} ==========================

<#--
SET SCHEMA ${version.schema};
-->

<#if version.path?has_content>
SET PATH ${version.path};
</#if>

ALTER SESSION SET nls_timestamp_format = 'YYYY-MM-DD HH24:MI:SS.FF6';

ALTER SESSION SET nls_date_format = 'YYYY-MM-DD HH24:MI:SS';

-- таймаут на выполнение DDL по заблокированному объекту 1 час
ALTER SESSION SET DDL_LOCK_TIMEOUT = 3600;

-- ожидание при нехватке свободного места
ALTER SESSION SET RESUMABLE_TIMEOUT = 3600;

INSERT INTO sysvlog (ID_LOG,VPNAME, MESSAGE)
    VALUES (seq_sysvlog.NEXTVAL, '${version.version}', 'Starting installing ''${version.version}''');

COMMIT;



