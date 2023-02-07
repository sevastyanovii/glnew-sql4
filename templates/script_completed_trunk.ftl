
INSERT INTO sysvlog (ID_LOG, VPNAME, MESSAGE)
    VALUES (seq_sysvlog.NEXTVAL, '${version.version}', 'Trunk ''${version.version}'' is successfully installed');

COMMIT;

<#include "check_errors.ftl">

<#include "start_jobs.ftl">

--SPOOL OFF

--DISCONNECT