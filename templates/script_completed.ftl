
INSERT INTO sysvlog (ID_LOG, VPNAME, MESSAGE)
    VALUES (seq_sysvlog.NEXTVAL, '${version.version}', 'Version ''${version.version}'' is successfully installed');

COMMIT;

<#include "check_errors.ftl">

<#include "start_jobs.ftl">

EXEC DBMS_OUTPUT.PUT_LINE('Patch ${version.version} is successfully installed');

SPOOL OFF

DISCONNECT