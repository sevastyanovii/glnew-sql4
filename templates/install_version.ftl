UPDATE sysmod set VERSION = '${version.version}', PATCH = NULL, VDATE = SYSTIMESTAMP, PDATE = NULL
    WHERE NAME = '${version.module}';
