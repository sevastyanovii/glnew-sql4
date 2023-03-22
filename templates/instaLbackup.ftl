
<#assign tables="''SYSMOD'',">

<#list all_backup_objects as bo>

<#assign boName="${bo.objectName}">

<#if bo.table>
    <#assign tables=tables + "''" + boName + "'',">
</#if>


</#list>

<#assign tables=tables?remove_ending(",")>

--EXEC DB_CONF.INSTALL_BACKUP('${version.version}', 'GLPATCH', '${tables}');

<#include "stop_jobs.ftl">


