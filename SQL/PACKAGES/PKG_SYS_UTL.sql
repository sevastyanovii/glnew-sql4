CREATE OR REPLACE PACKAGE pkg_sys_utl IS
    PROCEDURE log_audit_error(a_log_code VARCHAR2, a_message VARCHAR2,  a_errormsg VARCHAR2 DEFAULT NULL, a_stack VARCHAR2 DEFAULT NULL);
    PROCEDURE log_audit_warn(a_log_code VARCHAR2, a_message VARCHAR2, a_errormsg VARCHAR2 DEFAULT NULL, a_stack VARCHAR2 DEFAULT NULL);
    PROCEDURE log_audit_info(a_log_code VARCHAR2, a_message VARCHAR2, a_errormsg VARCHAR2 DEFAULT NULL, a_stack VARCHAR2 DEFAULT NULL);
    PROCEDURE log_audit(a_log_code VARCHAR2, a_log_level VARCHAR2, a_message VARCHAR2, a_errormsg VARCHAR2, a_stack VARCHAR2);
END pkg_sys_utl;
/

CREATE OR REPLACE PACKAGE BODY pkg_sys_utl IS

    PROCEDURE log_audit_error(a_log_code VARCHAR2, a_message VARCHAR2, a_errormsg VARCHAR2 DEFAULT NULL, a_stack VARCHAR2 DEFAULT NULL) IS
        l_errm varchar2(4000);
        l_stack varchar2(4000);
    BEGIN
        l_stack := nvl(a_stack, substr(dbms_utility.format_error_backtrace || chr(10)
            || dbms_utility.format_call_stack, 1, 4000));
        l_errm := nvl(a_errormsg, SQLERRM);

        log_audit(a_log_code, 'SysError', a_message, l_errm, l_stack);
    END log_audit_error;

    PROCEDURE log_audit_warn(a_log_code VARCHAR2, a_message VARCHAR2, a_errormsg VARCHAR2, a_stack VARCHAR2) IS
    BEGIN
        log_audit(a_log_code, 'Warning', a_message, a_errormsg, a_stack);
    END log_audit_warn;

    PROCEDURE log_audit_info(a_log_code VARCHAR2, a_message VARCHAR2, a_errormsg VARCHAR2 DEFAULT NULL, a_stack VARCHAR2 DEFAULT NULL) IS
    BEGIN
        log_audit(a_log_code, 'Info', a_message, a_errormsg, a_stack);
    END log_audit_info;

    PROCEDURE log_audit_debug(a_log_code VARCHAR2, a_message VARCHAR2, a_errormsg VARCHAR2 DEFAULT NULL, a_stack VARCHAR2 DEFAULT NULL) IS
    BEGIN
        log_audit(a_log_code, 'Debug', a_message, a_errormsg, a_stack);
    END log_audit_debug;

    PROCEDURE log_audit(a_log_code VARCHAR2, a_log_level VARCHAR2, a_message VARCHAR2, a_errormsg VARCHAR2, a_stack VARCHAR2) IS

        PRAGMA AUTONOMOUS_TRANSACTION;

        l_userinfo VARCHAR2(255);
        l_message VARCHAR2(512);

        FUNCTION get_userinfo RETURN VARCHAR2 IS
        BEGIN
            return 'ip:'|| sys_context('USERENV', 'IP_ADDRESS')||' host:' ||sys_context('USERENV', 'HOST')||' user:'
                        || sys_context('USERENV', 'CURRENT_USER') ||' proxy:'
                        || nvl(sys_context('USERENV', 'PROXY_USER'),'<empty>')||' SID:'||sys_context('USERENV', 'SID');
        END;

        FUNCTION get_message(a_msg sysaudit.message%type) RETURN VARCHAR2 IS
        BEGIN
            IF (length(a_msg) > 512) THEN
              RETURN substr(a_msg,1,509)||'...';
            ELSE
              RETURN a_msg;
            END IF;
        END get_message;

    BEGIN
        l_userinfo := get_userinfo();
        l_message := get_message(a_message);

        INSERT INTO sysaudit (id_record, sys_time, user_name, user_host, log_code, log_level, message, errormsg,
                           stck_trace, entity_id, entitytype, transactid, src, errorsrc, attachment, proctimems)
        VALUES (sysaudit_seq.nextval, systimestamp, null, null, a_log_code, a_log_level, l_message, a_errormsg,
                a_stack, null, null, null, substr(dbms_utility.format_call_stack, 1, 512), null, l_userinfo, null);
        COMMIT WRITE NOWAIT;
    END log_audit;

END pkg_sys_utl;
/
