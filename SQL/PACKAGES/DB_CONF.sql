create or replace PACKAGE DB_CONF IS

    INDEX_PARALLEL INTEGER := 1;

    TYPE TABLE_NAMES_TAB_TYPE IS TABLE OF VARCHAR2(30) INDEX BY PLS_INTEGER;

    PROCEDURE CREATE_TABLE_IF_ABSENT(A_SCHEMA VARCHAR2, A_TBLNAME VARCHAR2, A_COLUMNS_EXPR VARCHAR2, A_PRIMARY_COLS VARCHAR2);

    PROCEDURE GL_SYS_CHECK_VERSION (A_NAME VARCHAR2, A_VERSIONS VARCHAR2);

    PROCEDURE DROP_TABLE_IF_EXISTS (A_SCHEME_NAME VARCHAR2, A_TBL_NAME VARCHAR2, A_CASCADE BOOLEAN);

    PROCEDURE DROP_TABLE_IF_EXISTS (A_SCHEME_NAME VARCHAR2, A_TBL_NAME VARCHAR2);

    PROCEDURE ADD_COLUMN_IF_ABSENT (A_SCHEMA_NAME VARCHAR2, A_TABLE_NAME  VARCHAR2, A_COLUMN_NAME VARCHAR2, A_COLUMN_TYPE VARCHAR2);

    PROCEDURE ADD_CONSTRAINT_IF_ABSENT(A_SCHEMA_NAME VARCHAR2, A_TABLE_NAME VARCHAR2, A_CONSTRAINT_NAME VARCHAR2, A_SQL_EXPRESSION VARCHAR2);

    PROCEDURE ADD_SEQUENCE_IF_ABSENT(A_SCHEME_NAME VARCHAR2, A_SEQ_NAME VARCHAR2, A_START NUMBER);

    PROCEDURE ADD_SEQUENCE_IF_ABSENT(A_SCHEME_NAME VARCHAR2, A_SEQ_NAME VARCHAR2, A_START NUMBER, A_CACHE_SIZE NUMBER);

    PROCEDURE ADD_SEQUENCE_IF_ABSENT(A_SCHEME_NAME VARCHAR2, A_SEQ_NAME VARCHAR2);

    PROCEDURE GL_SYS_CU_REF (A_SCHEMA_NAME VARCHAR2, A_TABLE_NAME VARCHAR2, A_WHERE_CLASS VARCHAR2, A_INSERT_SQL VARCHAR2, A_UPDATE_SQL VARCHAR2);

    PROCEDURE CREATE_INDEX_IF_ABSENT (A_SCHEMA_NAME VARCHAR2, A_INDEX_NAME VARCHAR2, A_SQL_EXPR VARCHAR2, A_IS_UNIQUE CHAR, A_TABSPACE VARCHAR2);

    PROCEDURE CREATE_INDEX_IF_ABSENT (A_SCHEMA_NAME VARCHAR2, A_INDEX_NAME VARCHAR2, A_SQL_EXPR VARCHAR2, A_IS_UNIQUE CHAR);

    PROCEDURE DROP_INDEX_IF_EXISTS (A_SCHEMA_NAME VARCHAR2, A_INDEX_NAME VARCHAR2);

    PROCEDURE DROP_CONSTR_IF_EXISTS (A_SCHEMA_NAME VARCHAR2, A_TABLE_NAME VARCHAR2, A_CONSTR_NAME VARCHAR2);

    PROCEDURE INSTALL_BACKUP  (A_VERSION VARCHAR2, A_DIRECTORY VARCHAR2, A_TABLES VARCHAR2);

    PROCEDURE ROLLBACK_VERSION(A_VERSION VARCHAR2
                              , A_DIRECTORY VARCHAR2, A_TABLES VARCHAR2,  A_VIEWS VARCHAR2
                              , A_PROCEDURES VARCHAR2, A_FUNCTIONS VARCHAR2, A_PACKAGES VARCHAR, A_TRIGGERS VARCHAR2);

    PROCEDURE INIT_CONNECTION_NLS;

    PROCEDURE drop_job_if_exists(a_jobname VARCHAR2);
    PROCEDURE drop_program_if_exists(a_progname VARCHAR2);
    PROCEDURE drop_queue_if_exists(a_queuename VARCHAR2);
    PROCEDURE drop_type_if_exists(a_typename VARCHAR2);

    function job_info(h1 NUMBER) return char;

END DB_CONF;
/

create or replace PACKAGE BODY DB_CONF IS

    PROCEDURE CREATE_TABLE_IF_ABSENT(A_SCHEMA VARCHAR2, A_TBLNAME VARCHAR2, A_COLUMNS_EXPR VARCHAR2, A_PRIMARY_COLS VARCHAR2) IS
        L_CNT NUMBER;
        L_EXEC VARCHAR2(4000);
    BEGIN
        SELECT COUNT(1) INTO L_CNT FROM ALL_TABLES T WHERE T.OWNER = A_SCHEMA AND T.TABLE_NAME = A_TBLNAME;
        IF (L_CNT = 0) THEN
            L_EXEC := 'CREATE TABLE ' || A_SCHEMA || '.' || A_TBLNAME || ' (' || A_COLUMNS_EXPR;

            IF (TRIM(A_PRIMARY_COLS) IS NOT NULL) THEN
                L_EXEC := L_EXEC
                    || ', CONSTRAINT '||A_SCHEMA||'.PK_'||SUBSTR(A_TBLNAME,1,26)||'0 PRIMARY KEY ('||A_PRIMARY_COLS||')';
            END IF;
            L_EXEC := L_EXEC ||')';
          EXECUTE IMMEDIATE L_EXEC;
        END IF;
        NULL;
    END CREATE_TABLE_IF_ABSENT;

    PROCEDURE GL_SYS_CHECK_VERSION (A_NAME VARCHAR2, A_VERSIONS VARCHAR2) is
        L_CNT NUMBER;
        L_CURRENT_VERSION VARCHAR2(255);
    BEGIN
        FOR NN IN (SELECT REGEXP_SUBSTR(A_VERSIONS, '[^,]+', 1, LEVEL) CURRENT_VERSION
                     FROM DUAL
                  CONNECT BY REGEXP_SUBSTR(A_VERSIONS, '[^,]+', 1, LEVEL) IS NOT NULL) LOOP

            SELECT COUNT(1) INTO L_CNT FROM SYSMOD WHERE NAME = A_NAME AND VERSION = NN.CURRENT_VERSION;
            IF (L_CNT = 1) THEN
                RETURN;
            END IF;
        END LOOP;
        SELECT VERSION INTO L_CURRENT_VERSION FROM SYSMOD M WHERE M.NAME = A_NAME;
        RAISE_APPLICATION_ERROR(-20000, 'Incompatable versions: ' || A_VERSIONS || ' CURRENT: ' || L_CURRENT_VERSION);
    END GL_SYS_CHECK_VERSION;

    PROCEDURE DROP_TABLE_IF_EXISTS (A_SCHEME_NAME VARCHAR2, A_TBL_NAME VARCHAR2, A_CASCADE BOOLEAN) is
        L_EXEC VARCHAR2 ( 200 ) ;
        L_CNT number(2);
    begin
        L_EXEC := 'DROP TABLE ' || A_SCHEME_NAME || '.' || A_TBL_NAME || CASE WHEN A_CASCADE THEN ' CASCADE CONSTRAINTS' else ' ' END;
        SELECT COUNT(1) INTO L_CNT FROM ALL_TABLES WHERE TABLE_NAME = UPPER(TRIM(A_TBL_NAME)) AND OWNER = UPPER(TRIM(A_SCHEME_NAME));
        IF ( L_CNT = 1 ) THEN
            EXECUTE IMMEDIATE L_EXEC ;
        END IF ;
    END  DROP_TABLE_IF_EXISTS;

    PROCEDURE DROP_TABLE_IF_EXISTS (A_SCHEME_NAME VARCHAR2, A_TBL_NAME VARCHAR2) IS
    BEGIN
       DROP_TABLE_IF_EXISTS(A_SCHEME_NAME, A_TBL_NAME, FALSE);
    END  DROP_TABLE_IF_EXISTS;

    PROCEDURE ADD_COLUMN_IF_ABSENT (A_SCHEMA_NAME VARCHAR2, A_TABLE_NAME  VARCHAR2, A_COLUMN_NAME VARCHAR2, A_COLUMN_TYPE VARCHAR2) IS
        L_EXEC VARCHAR2 (32767) ;
        L_CNT number(2);
    BEGIN
        SELECT COUNT(1) INTO L_CNT
          FROM ALL_TAB_COLS  WHERE OWNER = A_SCHEMA_NAME
           AND TABLE_NAME = UPPER(A_TABLE_NAME) AND COLUMN_NAME = REPLACE(UPPER(A_COLUMN_NAME),'"','');

        IF (L_CNT = 0) THEN
            L_EXEC := 'ALTER TABLE ' || A_SCHEMA_NAME || '.' || A_TABLE_NAME || ' ADD ' ||A_COLUMN_NAME|| ' ' ||A_COLUMN_TYPE;
            EXECUTE IMMEDIATE L_EXEC ;
        END IF ;
    END  ;

    PROCEDURE ADD_CONSTRAINT_IF_ABSENT(A_SCHEMA_NAME VARCHAR2
                                        , A_TABLE_NAME VARCHAR2
                                        , A_CONSTRAINT_NAME VARCHAR2
                                        , A_SQL_EXPRESSION VARCHAR2) IS
      L_EXEC VARCHAR2 (32767);
      L_CNT NUMBER(1);
      L_EXC_PK_ALREADY EXCEPTION;
      PRAGMA EXCEPTION_INIT(L_EXC_PK_ALREADY, -2260);

      L_EXC_UNIQUE_ALREADY EXCEPTION;
      PRAGMA EXCEPTION_INIT(L_EXC_UNIQUE_ALREADY, -2261);
    BEGIN
        SELECT COUNT(1) INTO L_CNT FROM ALL_CONSTRAINTS C
         WHERE C.OWNER = UPPER(A_SCHEMA_NAME)
           AND C.TABLE_NAME = UPPER(A_TABLE_NAME)
           AND C.CONSTRAINT_NAME = UPPER(A_CONSTRAINT_NAME);
        IF ( L_CNT = 0 ) THEN
            L_EXEC := 'ALTER TABLE ' || A_SCHEMA_NAME || '.' || A_TABLE_NAME || ' ADD CONSTRAINT ' || A_CONSTRAINT_NAME ||' ' || A_SQL_EXPRESSION;
            EXECUTE IMMEDIATE L_EXEC ;
        END IF ;
    EXCEPTION
        WHEN L_EXC_PK_ALREADY THEN NULL;
        WHEN L_EXC_UNIQUE_ALREADY THEN NULL;
    END ADD_CONSTRAINT_IF_ABSENT;

    PROCEDURE ADD_SEQUENCE_IF_ABSENT(A_SCHEME_NAME VARCHAR2, A_SEQ_NAME VARCHAR2, A_START NUMBER) is
    BEGIN
        ADD_SEQUENCE_IF_ABSENT(A_SCHEME_NAME, A_SEQ_NAME, A_START, 20);
    END ADD_SEQUENCE_IF_ABSENT;

    PROCEDURE ADD_SEQUENCE_IF_ABSENT(A_SCHEME_NAME VARCHAR2, A_SEQ_NAME VARCHAR2, A_START NUMBER, A_CACHE_SIZE NUMBER) is
      L_CNT NUMBER(1);
    BEGIN
        SELECT COUNT(1) INTO L_CNT FROM ALL_SEQUENCES WHERE SEQUENCE_OWNER = A_SCHEME_NAME AND SEQUENCE_NAME = A_SEQ_NAME;
        IF (L_CNT = 0) THEN
            EXECUTE IMMEDIATE 'CREATE SEQUENCE ' || A_SEQ_NAME || ' START WITH ' ||TO_CHAR(A_START) ||
            CASE when A_CACHE_SIZE > 1 THEN ' CACHE '|| TO_CHAR(A_CACHE_SIZE) ELSE ' NOCACHE' END;
        END IF;
    END;

    PROCEDURE ADD_SEQUENCE_IF_ABSENT(A_SCHEME_NAME VARCHAR2, A_SEQ_NAME VARCHAR2) is
    BEGIN
        ADD_SEQUENCE_IF_ABSENT(A_SCHEME_NAME, A_SEQ_NAME, 1, 20);
    END ADD_SEQUENCE_IF_ABSENT;

        /**
            -- example
            DB_CONF.GL_SYS_CU_REF('test_tab2'
                , 'where id1 = 1', 'insert into test_tab2 (id1, name1) values (1, ''name11'')'
                , 'update test_tab2 set name1 = ''name11'' where id1 = 1');
        */
        PROCEDURE GL_SYS_CU_REF (A_SCHEMA_NAME VARCHAR2, A_TABLE_NAME VARCHAR2, A_WHERE_CLASS VARCHAR2, A_INSERT_SQL VARCHAR2, A_UPDATE_SQL VARCHAR2) IS
            L_CNT_FOUND number(2);
            L_CHECK_COUNT_SQL VARCHAR2(4000);
        BEGIN

            L_CHECK_COUNT_SQL := 'SELECT COUNT(1) FROM ' || A_SCHEMA_NAME || '.' ||A_TABLE_NAME || ' ' ||A_WHERE_CLASS;

            EXECUTE IMMEDIATE L_CHECK_COUNT_SQL INTO  L_CNT_FOUND;

            IF (L_CNT_FOUND > 0) THEN
                IF (LENGTH(A_UPDATE_SQL) > 0) THEN
                    EXECUTE IMMEDIATE A_UPDATE_SQL;
                END IF;
            ELSE
                EXECUTE IMMEDIATE A_INSERT_SQL;
            END IF;

        END  GL_SYS_CU_REF;

    PROCEDURE CREATE_INDEX_IF_ABSENT (A_SCHEMA_NAME VARCHAR2, A_INDEX_NAME VARCHAR2, A_SQL_EXPR VARCHAR2, A_IS_UNIQUE CHAR, A_TABSPACE VARCHAR2) IS
      L_CNT NUMBER(2) ;
        L_EXEC VARCHAR2( 200 ) ;

        L_COL_ALREADY_INDEXED EXCEPTION;
        PRAGMA EXCEPTION_INIT(L_COL_ALREADY_INDEXED, -1408);

        L_OBJECT_EXISTS EXCEPTION;
        PRAGMA EXCEPTION_INIT(L_OBJECT_EXISTS, -955);
        L_INDEX_NAME VARCHAR2(30);
    BEGIN
        IF (LENGTH(A_INDEX_NAME) > 30) THEN
            L_INDEX_NAME := SUBSTR(SUBSTR(A_INDEX_NAME,1,24)||TRIM(TO_CHAR(SYSTIMESTAMP, 'FF')),1,30);
        ELSE
            L_INDEX_NAME := A_INDEX_NAME;
        END IF;
        L_EXEC := 'CREATE ${UNIQUE} INDEX ' || A_SCHEMA_NAME || '.' || L_INDEX_NAME || ' ON ' || A_SQL_EXPR ||
            CASE
                WHEN TRIM(A_TABSPACE) IS NULL THEN ''
                ELSE ' TABLESPACE ' ||A_TABSPACE
            END || ' COMPUTE STATISTICS ONLINE ' || ' PARALLEL ' || TO_CHAR(INDEX_PARALLEL);
        IF (A_IS_UNIQUE = '1') THEN
            L_EXEC := REPLACE(L_EXEC, '${UNIQUE}', 'UNIQUE');
        ELSE
            L_EXEC := REPLACE(L_EXEC, '${UNIQUE}', '');
        END IF;

        SELECT COUNT(1) INTO L_CNT FROM ALL_INDEXES WHERE OWNER = UPPER(A_SCHEMA_NAME) AND INDEX_NAME = UPPER(L_INDEX_NAME);

        DECLARE
            L_INSUFFICIENT_PRIVILEGES EXCEPTION;
            PRAGMA EXCEPTION_INIT(L_INSUFFICIENT_PRIVILEGES, -01031);
        BEGIN
            EXECUTE IMMEDIATE 'ALTER SESSION DISABLE RESUMABLE';
        EXCEPTION
            WHEN L_INSUFFICIENT_PRIVILEGES THEN NULL;
        END;

        IF (L_CNT = 0) THEN
            EXECUTE IMMEDIATE L_EXEC ;
        END IF ;
    EXCEPTION
        WHEN L_COL_ALREADY_INDEXED THEN NULL;
        WHEN L_OBJECT_EXISTS THEN NULL;
    END  CREATE_INDEX_IF_ABSENT;

    PROCEDURE CREATE_INDEX_IF_ABSENT (A_SCHEMA_NAME VARCHAR2, A_INDEX_NAME VARCHAR2, A_SQL_EXPR VARCHAR2, A_IS_UNIQUE CHAR) IS
    BEGIN
        CREATE_INDEX_IF_ABSENT (A_SCHEMA_NAME, A_INDEX_NAME, A_SQL_EXPR, A_IS_UNIQUE, NULL);
    END CREATE_INDEX_IF_ABSENT;

    PROCEDURE DROP_INDEX_IF_EXISTS (A_SCHEMA_NAME VARCHAR2, A_INDEX_NAME VARCHAR2) is
        L_EXEC VARCHAR2 ( 200 ) ;
        L_CNT number(2);
    begin
        L_EXEC := 'DROP INDEX ' || A_SCHEMA_NAME || '.' || A_INDEX_NAME;
        SELECT COUNT(1) INTO L_CNT FROM ALL_INDEXES WHERE OWNER = TRIM(UPPER(A_SCHEMA_NAME)) AND INDEX_NAME = TRIM(UPPER(A_INDEX_NAME));
        IF ( l_cnt = 1 ) THEN
            EXECUTE IMMEDIATE L_EXEC ;
        END IF ;
    END  DROP_INDEX_IF_EXISTS;

    PROCEDURE DROP_CONSTR_IF_EXISTS (A_SCHEMA_NAME VARCHAR2, A_TABLE_NAME VARCHAR2, A_CONSTR_NAME VARCHAR2) is
        L_EXEC VARCHAR2 ( 200 ) ;
        L_CNT number(2);
    begin
        L_EXEC := 'ALTER TABLE '|| A_SCHEMA_NAME || '.' || A_TABLE_NAME ||' DROP CONSTRAINT ' || A_CONSTR_NAME;
        SELECT COUNT(1) INTO L_CNT FROM ALL_CONSTRAINTS WHERE OWNER = TRIM(UPPER(A_SCHEMA_NAME)) AND CONSTRAINT_NAME = TRIM(UPPER(A_CONSTR_NAME)) AND TABLE_NAME = TRIM(UPPER(A_TABLE_NAME));
        IF ( L_CNT = 1 ) THEN
            EXECUTE IMMEDIATE L_EXEC ;
        END IF ;
    END  DROP_CONSTR_IF_EXISTS;

    function job_info(h1 NUMBER) return char is
        ind NUMBER;              -- Loop index
        percent_done    NUMBER;         -- Percentage of job complete
        job_state       VARCHAR2(30);   -- To keep track of job state
        le              ku$_LogEntry;   -- For WIP and error messages
        js              ku$_JobStatus;  -- The job status from get_status
        jd              ku$_JobDesc;    -- The job description from get_status
        sts             ku$_Status;     -- The status object returned by get_status

        l_res char(1) := '0';
    begin
      percent_done := 0;
      job_state := 'UNDEFINED';

      while (job_state != 'COMPLETED') and (job_state != 'STOPPED') loop
        dbms_datapump.get_status(h1,
               dbms_datapump.ku$_status_job_error +
               dbms_datapump.ku$_status_job_status +
               dbms_datapump.ku$_status_wip,-1,job_state,sts);
        js := sts.job_status;

    -- If the percentage done changed, display the new value.

        if js.percent_done != percent_done
        then
          dbms_output.put_line('*** Job percent done = ' ||
                               to_char(js.percent_done));
          percent_done := js.percent_done;
        end if;

    -- If any work-in-progress (WIP) or error messages were received for the job,
    -- display them.

       if (bitand(sts.mask,dbms_datapump.ku$_status_wip) != 0)
        then
          le := sts.wip;
        else
          if (bitand(sts.mask,dbms_datapump.ku$_status_job_error) != 0)
          then
            le := sts.error;
          else
            le := null;
          end if;
        end if;

        if le is not null
        then
          ind := le.FIRST;
          while ind is not null loop

            if (instr(le(ind).LogText, 'ORA-') > 0) then
              l_res := '1';
            end if;

            dbms_output.put_line(le(ind).LogText);
            ind := le.NEXT(ind);
          end loop;
        end if;
      end loop;

    -- Indicate that the job finished and detach from it.

      dbms_output.put_line('Job has completed');
      dbms_output.put_line('Final job state = ' || job_state);

      return l_res;
    end;

    function str2arr (a_commadelim varchar2) return table_names_tab_type is
      l_table_names_tab table_names_tab_type;
    begin
      SELECT REGEXP_SUBSTR(a_commadelim, '[^,]+', 1, LEVEL) CURRENT_VERSION bulk collect into l_table_names_tab
                     FROM DUAL
                  CONNECT BY REGEXP_SUBSTR(a_commadelim, '[^,]+', 1, LEVEL) IS NOT NULL;
      return l_table_names_tab;
    end;

    procedure drop_programms(a_programs varchar2, a_object_path varchar2) is
      l_table_names_tab table_names_tab_type;
      l_name varchar2(128);
      e_table_not_exists exception;
      e_object_not_exists exception;
      e_trigger_not_exists exception;

      PRAGMA EXCEPTION_INIT(e_table_not_exists, -942);
      PRAGMA EXCEPTION_INIT(e_object_not_exists, -4043);
      PRAGMA EXCEPTION_INIT(e_trigger_not_exists, -4080);

      procedure exec_drop(a_exec varchar2) is
      begin
        execute immediate a_exec;
      exception
        when e_table_not_exists or e_object_not_exists or e_trigger_not_exists then null;
      end;
    begin
      l_table_names_tab := str2arr(a_programs);
      if (l_table_names_tab.count > 0) then
        for nn in l_table_names_tab.first .. l_table_names_tab.last loop
          l_name := replace(l_table_names_tab(nn),'''', '');

          DBMS_OUTPUT.PUT_LINE('Object Name '||nvl(l_name, '<EMPTY>')||', path ' || a_object_path);

          if (l_name is not null) then
            if (a_object_path = 'VIEW') then
              exec_drop('drop view ' || l_name);
            elsif (a_object_path = 'PROCEDURE') then
              exec_drop('drop procedure ' || l_name);
            elsif (a_object_path = 'FUNCTION') then
              exec_drop('drop function ' || l_name);
            elsif (a_object_path = 'PACKAGE') then
              exec_drop('drop package ' || l_name);
              exec_drop('drop package body ' || l_name);
            elsif (a_object_path = 'TRIGGER') then
              exec_drop('drop trigger ' || l_name);
            else
              raise_application_error(-20000, 'Invalid programm type: ' || a_object_path);
            end if;
          end if;
        end loop;
      end if;
    end;

    /**
        -- Example: db_conf.INSTALL_BACKUP('1.6.2', 'tab1 tab2 tab3');
    */
    PROCEDURE INSTALL_BACKUP  (A_VERSION VARCHAR2, A_DIRECTORY VARCHAR2, A_TABLES VARCHAR2) is

        ind NUMBER;              -- Loop index
        h1              NUMBER;         -- Data Pump job handle
        percent_done    NUMBER;         -- Percentage of job complete
        job_state       VARCHAR2(30);   -- To keep track of job state
        le              ku$_LogEntry;   -- For WIP and error messages
        js              ku$_JobStatus;  -- The job status from get_status
        jd              ku$_JobDesc;    -- The job description from get_status
        sts             ku$_Status;     -- The status object returned by get_status
        l_jobres  char(1);
        l_logname varchar2(256);
    BEGIN
        H1 := DBMS_DATAPUMP.OPEN('EXPORT','SCHEMA',NULL,NULL,'LATEST');

        if (trim (A_TABLES) is null) then
          DBMS_DATAPUMP.METADATA_FILTER(handle => h1, name => 'NAME_EXPR', value => 'LIKE ''NOT_EXIST1ENCE_TAB%''', object_path => 'TABLE');
          DBMS_DATAPUMP.DATA_FILTER(handle => h1, name => 'INCLUDE_ROWS', value => 0);
        else
          DBMS_DATAPUMP.METADATA_FILTER(handle => h1, name => 'NAME_LIST', value => A_TABLES, object_path => 'TABLE');
        end if;

        l_logname := 'EXP_' || A_VERSION ||'.LOG';
        DBMS_DATAPUMP.ADD_FILE(handle => H1, filename => l_logname, directory => A_DIRECTORY
            , filesize => NULL, filetype => DBMS_DATAPUMP.KU$_FILE_TYPE_LOG_FILE, reusefile => 1);
        DBMS_DATAPUMP.ADD_FILE(H1, 'EXP_' || A_VERSION ||'.DMP', A_DIRECTORY);

        DBMS_DATAPUMP.START_JOB(h1);

        l_jobres := job_info(h1);

        dbms_output.put_line('result of JOB: ' || l_jobres);
        dbms_datapump.detach(h1);

        if (l_jobres <> '0') then
          raise_application_error(-20000, 'Error on backup. See '||l_logname||' in directory '||A_DIRECTORY);
        end if;

    END INSTALL_BACKUP;

    PROCEDURE ROLLBACK_VERSION(A_VERSION VARCHAR2
                              , A_DIRECTORY VARCHAR2, A_TABLES VARCHAR2,  A_VIEWS VARCHAR2
                              , A_PROCEDURES VARCHAR2, A_FUNCTIONS VARCHAR2, A_PACKAGES VARCHAR, A_TRIGGERS VARCHAR2) IS
        ind NUMBER;              -- Loop index
        h1              NUMBER;         -- Data Pump job handle
        percent_done    NUMBER;         -- Percentage of job complete
        job_state       VARCHAR2(30);   -- To keep track of job state
        le              ku$_LogEntry;   -- For WIP and error messages
        js              ku$_JobStatus;  -- The job status from get_status
        jd              ku$_JobDesc;    -- The job description from get_status
        sts             ku$_Status;     -- The status object returned by get_status
        l_jobres  char(1);
        l_logname varchar2(256);
    begin
      drop_programms(a_views, 'VIEW');
      drop_programms(a_procedures, 'PROCEDURE');
      drop_programms(a_functions, 'FUNCTION');
      drop_programms(a_packages, 'PACKAGE');
      drop_programms(a_triggers, 'TRIGGER');

      H1 := DBMS_DATAPUMP.OPEN('IMPORT','SCHEMA',NULL,NULL,'LATEST');
      l_logname := 'IMP_' || A_VERSION ||'.LOG';

      if (trim(A_TABLES) is not null) then
        DBMS_DATAPUMP.METADATA_FILTER(handle => h1, name => 'NAME_LIST', value => A_TABLES, object_path => 'TABLE');
        DBMS_DATAPUMP.SET_PARAMETER(handle => h1, name => 'TABLE_EXISTS_ACTION', value => 'REPLACE');
      else
        DBMS_DATAPUMP.METADATA_FILTER(handle => h1, name => 'NAME_EXPR', value => 'LIKE ''NOT_EXIST1ENCE_TAB%''', object_path => 'TABLE');
      end if;
      if (trim(a_views) is not null) then
        DBMS_DATAPUMP.METADATA_FILTER(handle => h1, name => 'NAME_LIST', value => a_views, object_path => 'VIEW');
      else
        DBMS_DATAPUMP.METADATA_FILTER(handle => h1, name => 'NAME_EXPR', value => 'LIKE ''NOT_EXIST1ENCE_VIEW%''', object_path => 'VIEW');
      end if;
      if (trim(a_procedures) is not null) then
        DBMS_DATAPUMP.METADATA_FILTER(handle => h1, name => 'NAME_LIST', value => a_procedures, object_path => 'PROCEDURE');
      else
        DBMS_DATAPUMP.METADATA_FILTER(handle => h1, name => 'NAME_EXPR', value => 'LIKE ''NOT_EXIST1ENCE_PROC%''', object_path => 'PROCEDURE');
      end if;
      if (trim(a_functions) is not null) then
        DBMS_DATAPUMP.METADATA_FILTER(handle => h1, name => 'NAME_LIST', value => a_functions, object_path => 'FUNCTION');
      else
        DBMS_DATAPUMP.METADATA_FILTER(handle => h1, name => 'NAME_EXPR', value => 'LIKE ''NOT_EXIST1ENCE_FUNC%''', object_path => 'FUNCTION');
      end if;
      if (trim(a_packages) is not null) then
        DBMS_DATAPUMP.METADATA_FILTER(handle => h1, name => 'NAME_LIST', value => a_packages, object_path => 'PACKAGE');
        DBMS_DATAPUMP.METADATA_FILTER(handle => h1, name => 'NAME_LIST', value => a_packages, object_path => 'PACKAGE_BODY');
      else
        DBMS_DATAPUMP.METADATA_FILTER(handle => h1, name => 'NAME_EXPR', value => 'LIKE ''NOT_EXIST1ENCE_PKG%''', object_path => 'PACKAGE');
        DBMS_DATAPUMP.METADATA_FILTER(handle => h1, name => 'NAME_EXPR', value => 'LIKE ''NOT_EXIST1ENCE_PKGB%''', object_path => 'PACKAGE_BODY');
      end if;
      if (trim(a_triggers) is not null) then
        DBMS_DATAPUMP.METADATA_FILTER(handle => h1, name => 'NAME_LIST', value => a_triggers, object_path => 'TRIGGER');
      else
        DBMS_DATAPUMP.METADATA_FILTER(handle => h1, name => 'NAME_EXPR', value => 'LIKE ''NOT_EXIST1ENCE_TRG%''', object_path => 'TRIGGER');
      end if;

      DBMS_DATAPUMP.METADATA_FILTER(handle => h1, name => 'INCLUDE_PATH_EXPR', value => ' IN (''PROCEDURE'',''FUNCTION'',''TABLE'',''VIEW'',''PACKAGE'',''PACKAGE_BODY'',''TRIGGER'')');

      DBMS_DATAPUMP.ADD_FILE(handle => H1, filename => l_logname, directory => A_DIRECTORY
        , filesize => NULL, filetype => DBMS_DATAPUMP.KU$_FILE_TYPE_LOG_FILE, reusefile => 1);
      DBMS_DATAPUMP.ADD_FILE(H1, 'EXP_' || A_VERSION ||'.DMP', A_DIRECTORY);
      DBMS_DATAPUMP.START_JOB(h1);

      L_JOBRES := JOB_INFO(H1);
      DBMS_DATAPUMP.DETACH(H1);

      DBMS_OUTPUT.PUT_LINE('result of JOB: ' || l_jobres);

      IF (L_JOBRES <> '0') THEN
        RAISE_APPLICATION_ERROR(-20000, 'Error on ROLLBACK. See '||l_logname||' in directory '||A_DIRECTORY ||', state: ' || job_state);
      END IF;
    END;

    PROCEDURE INIT_CONNECTION_NLS IS
        L_INSIF_PRIVS EXCEPTION;
        PRAGMA EXCEPTION_INIT(L_INSIF_PRIVS, -01031);
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_TIMESTAMP_FORMAT=''YYYY-MM-DD HH24:MI:SS.ff9''';
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''YYYY-MM-DD HH24:MI:SS''';
        EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL DML QUERY';
        BEGIN
            EXECUTE IMMEDIATE 'ALTER SESSION DISABLE RESUMABLE';
        EXCEPTION
            WHEN L_INSIF_PRIVS THEN NULL;
        END;
       -- It's not need, apply the settings of DB -- EXECUTE IMMEDIATE 'ALTER SESSION SET SESSION_CACHED_CURSORS = 100';
    END;

    PROCEDURE drop_job_if_exists(a_jobname VARCHAR2) IS
        l_cnt INTEGER;
    BEGIN
        SELECT count(1) INTO l_cnt FROM user_scheduler_jobs WHERE job_name = a_jobname;
        IF (l_cnt > 0) THEN
            dbms_scheduler.drop_job(job_name => a_jobname);
        END IF;
    END drop_job_if_exists;

    PROCEDURE drop_program_if_exists(a_progname VARCHAR2) IS
        l_cnt INTEGER;
    BEGIN
        SELECT count(1) INTO l_cnt FROM user_scheduler_programs WHERE program_name = a_progname;
        IF (l_cnt > 0) THEN
            dbms_scheduler.drop_program(program_name => a_progname);
        END IF;
    END drop_program_if_exists;

    PROCEDURE drop_queue_if_exists(a_queuename VARCHAR2) IS
        l_cnt INTEGER;
        l_queue_tab_name VARCHAR2(64);
    BEGIN
        SELECT count(1) INTO l_cnt FROM user_queues WHERE name = a_queuename;
        IF (l_cnt > 0) THEN
            SELECT queue_table INTO l_queue_tab_name FROM user_queues WHERE name = a_queuename;
            dbms_aqadm.stop_queue(queue_name => a_queuename);
            dbms_aqadm.drop_queue(queue_name => a_queuename);

            SELECT count(1) INTO l_cnt FROM user_queue_tables WHERE queue_table = l_queue_tab_name;
            IF (l_cnt > 0) THEN
                dbms_aqadm.drop_queue_table(queue_table => l_queue_tab_name);
            END IF;
        END IF;
    END drop_queue_if_exists;

    PROCEDURE drop_type_if_exists(a_typename VARCHAR2) IS
        l_cnt INTEGER;
    BEGIN
        SELECT count(1) INTO l_cnt FROM user_types WHERE type_name = a_typename;
        IF (l_cnt > 0) THEN
            EXECUTE IMMEDIATE 'DROP TYPE '||a_typename;
        END IF;
    END drop_type_if_exists;

END DB_CONF;
/
