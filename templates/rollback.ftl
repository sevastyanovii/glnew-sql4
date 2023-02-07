-- DEFINE USER=&1
-- DEFINE PASSWD=&2
-- DEFINE DB=&5
--
-- conn &USER/&PASSWD@&DB

SET AUTOCOMMIT OFF

WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

SET ERRORLOGGING ON
SET ERRORLOGGING ON TRUNCATE

SET SERVEROUTPUT ON

SET ECHO ON

SET TIMING ON

SPOOL ROLLBACK.log REPLACE

EXEC DB_CONF.GL_SYS_CHECK_VERSION('BarsGL', '${version.version}');

INSERT INTO sysvlog (ID_LOG, VPNAME, MESSAGE)
    VALUES (seq_sysvlog.NEXTVAL, '${version.version}', 'Начинаем откат версии ${version.version}');

COMMIT;

<#include "stop_jobs.ftl">


<#list all_rollback_scripts as rollbackScript>

--========================== rollback item ${rollbackScript.itemName} ===============

${rollbackScript.rollbackBody}

</#list>

<#assign tables="''sysmod'',">
<#assign views="">
<#assign procedures="">
<#assign functions="">
<#assign packages="">
<#assign triggers="">

<#list all_backup_objects as bo>

<#assign boName="${bo.objectName}">

<#if bo.table>
    <#assign tables=tables + "''" + boName + "'',">
</#if>

<#if bo.view>
    <#assign views=views + "''" + boName + "'',">
</#if>

<#if bo.procedure>
    <#assign procedures=procedures + "''" + boName + "'',">
</#if>

<#if bo.function>
    <#assign functions=functions + "''" + boName + "'',">
</#if>

<#if bo.package>
    <#assign packages=packages + "''" + boName + "'',">
</#if>

<#if bo.trigger>
    <#assign triggers=triggers + "''" + boName + "'',">
</#if>

</#list>

<#assign tables=tables?remove_ending(",")>
<#assign views=views?remove_ending(",")>
<#assign procedures=procedures?remove_ending(",")>
<#assign functions=functions?remove_ending(",")>
<#assign packages=packages?remove_ending(",")>
<#assign triggers=triggers?remove_ending(",")>

EXEC DB_CONF.ROLLBACK_VERSION('${version.version}', 'GLPATCH', '${tables}', '${views}', '${procedures}', '${functions}', '${packages}', '${triggers}');

INSERT INTO sysvlog (ID_LOG, VPNAME, MESSAGE)
    VALUES (seq_sysvlog.NEXTVAL, '${version.version}', 'Откат версии ${version.version} выполнен успешно');


COMMIT;

<#include "check_errors.ftl">

<#include "start_jobs.ftl">

SPOOL OFF

DISCONNECT
