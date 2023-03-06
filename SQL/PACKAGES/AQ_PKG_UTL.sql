CREATE OR REPLACE PACKAGE aq_pkg_utl IS

    C_LOG_CODE_ASYNC CONSTANT VARCHAR2(12) := 'AsyncBalance';
    C_LOG_CODE_BALANCE_MODE CONSTANT VARCHAR2(12) := 'BalanceMode';

    /**
        гибридный режим пересчета остатков (часть асинхронно, часть синхронно на основе PST.PBR см AQPBR)
    */
    PROCEDURE start_gibrid_mode;

    /**
        режим прямого пересчета остатков (LEGACY)
    */
    PROCEDURE start_online_mode;

    /**
        режим пересчета остатков по требованию (все триггера отключены, таблица PST не журналируется для репликации)
    */
    PROCEDURE start_ondemand_mode;

    FUNCTION comma_to_array(A_NAMES_STRING VARCHAR2, A_DELIM VARCHAR2) RETURN DBMS_UTILITY.LNAME_ARRAY;

    /**
        вычисление текущего режима пересчета остатков. В случае некорректной установки режима генерирует ошибку.
    */
    FUNCTION get_current_bal_state RETURN VARCHAR2;

    /**
        проверка состояния очереди. при наличии ошибок останавливает обработку и закрывает очередь на прием сообщений
    */
    PROCEDURE check_error_queue;

    /**
        восстановление последнего состояния триггеров на PST перед включением режима ONDEMAND
    */
    PROCEDURE restore_pst_triggers;

    PROCEDURE check_balance_mode(a_target VARCHAR2);

    PROCEDURE save_triggers_status;

    PROCEDURE stop_queue;

END aq_pkg_utl;
/

CREATE OR REPLACE PACKAGE BODY aq_pkg_utl IS

    PROCEDURE switch_trigger(a_trigger_name VARCHAR2, a_off BOOLEAN) IS
        l_cmd VARCHAR2(4000);
    BEGIN
        l_cmd := 'ALTER TRIGGER '||a_trigger_name||' '||CASE a_off WHEN true THEN 'DISABLE ' ELSE 'ENABLE' END;
        EXECUTE IMMEDIATE l_cmd;
    EXCEPTION
        WHEN others THEN
            RAISE_APPLICATION_ERROR(-20000, 'Error on '''||CASE a_off WHEN true THEN 'DISABLE ' ELSE 'ENABLE' END||''' trigger '''
                ||a_trigger_name||''', errcode: '||sqlcode||', msg: '||sqlerrm||' '||l_cmd);
    END;

    PROCEDURE switch_triggers(a_triggers VARCHAR2, a_off BOOLEAN) IS
        l_names DBMS_UTILITY.LNAME_ARRAY;
    BEGIN
        l_names := comma_to_array(a_triggers, ',');
        FOR i IN 1 .. l_names.last LOOP
            switch_trigger(l_names(i), a_off);
        END LOOP;
    END switch_triggers;

    PROCEDURE switch_trigger_on(a_trigger_name VARCHAR2) IS
    BEGIN
        switch_trigger(a_trigger_name, false);
    END switch_trigger_on;

    PROCEDURE switch_trigger_off(a_trigger_name VARCHAR2) IS
    BEGIN
        switch_trigger(a_trigger_name, true);
    END switch_trigger_off;

    PROCEDURE check_triggers IS
        l_onl NUMBER;
        c_onl CONSTANT NUMBER := 3;
        l_gib NUMBER;
        c_gib CONSTANT NUMBER := 1;
        l_jrn NUMBER;
        c_jrn CONSTANT NUMBER := 0;

        PROCEDURE raise_ex(a_type VARCHAR2, a_found NUMBER, a_expected NUMBER) IS
        BEGIN
            RAISE_APPLICATION_ERROR(-20000, 'Количество триггеров типа '||a_type||' '||to_char(a_found)
                ||' не соответствует ожидаемому '||a_expected);
        END raise_ex;
    BEGIN
        SELECT sum(CASE WHEN form = aq_pkg_const.get_const_trigger_form_online THEN 1 ELSE 0 END) onl,
               sum(CASE WHEN form = aq_pkg_const.get_const_trigger_form_gibrid THEN 1 ELSE 0 END) gib,
               sum(CASE WHEN form = aq_pkg_const.get_const_trigger_form_jrn THEN 1 ELSE 0 END) jrn
               INTO l_onl, l_gib, l_jrn
          FROM v_balmode_trg;
        IF (l_onl <> c_onl) THEN
            raise_ex(aq_pkg_const.get_const_trigger_form_online, l_onl, c_onl);
        END IF;
        IF (l_gib <> c_gib) THEN
            raise_ex(aq_pkg_const.get_const_trigger_form_gibrid, l_gib, c_gib);
        END IF;
        IF (l_jrn <> c_jrn) THEN
            raise_ex(aq_pkg_const.get_const_trigger_form_jrn, l_jrn, c_jrn);
        END IF;
    END check_triggers;

    PROCEDURE start_gibrid_mode IS
        PRAGMA AUTONOMOUS_TRANSACTION;

        PROCEDURE start_queue IS
        BEGIN
            dbms_aqadm.start_queue(
                queue_name => aq_pkg_const.c_normal_queue_name,
                enqueue    => true,
                dequeue    => true);
            pkg_sys_utl.log_audit_warn(C_LOG_CODE_ASYNC, 'Очередь '||aq_pkg_const.c_normal_queue_name
                ||' открыта на прием сообщений');
        END;

    BEGIN
        check_triggers;
        save_triggers_status;
        FOR nn IN (SELECT * FROM v_balmode_trg) LOOP
            IF (nn.form = aq_pkg_const.c_trigger_form_gibrid
                    OR nn.form = aq_pkg_const.c_trigger_form_jrn
                    OR nn.form <> aq_pkg_const.c_trigger_form_online) THEN
                switch_trigger_on(nn.trigger_name);
            ELSIF (nn.form = aq_pkg_const.c_trigger_form_online) THEN
                switch_trigger_off(nn.trigger_name);
            END IF;
        END LOOP;
        start_queue();
        COMMIT;
        pkg_sys_utl.log_audit_info(c_log_code_balance_mode, 'Включен режим пересчета остатков: GIBRID');
    END start_gibrid_mode;

    PROCEDURE start_online_mode IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        stop_queue();
        check_triggers;
        save_triggers_status;
        FOR nn IN (SELECT * FROM v_balmode_trg) LOOP
            IF (nn.form = aq_pkg_const.c_trigger_form_online
                    OR nn.form = aq_pkg_const.c_trigger_form_jrn
                    OR nn.form <> aq_pkg_const.c_trigger_form_gibrid)
            THEN
                switch_trigger_on(nn.trigger_name);
            ELSIF (nn.form = aq_pkg_const.c_trigger_form_gibrid) THEN
                switch_trigger_off(nn.trigger_name);
            END IF;
        END LOOP;
        COMMIT;
        pkg_sys_utl.log_audit_info(c_log_code_balance_mode, 'Включен режим пересчета остатков: ONLINE');
    END start_online_mode;

    PROCEDURE start_ondemand_mode IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        check_triggers;
        save_triggers_status;
        FOR nn IN (SELECT * FROM v_balmode_trg) LOOP
            IF (nn.form = aq_pkg_const.c_trigger_form_jrn) THEN
                switch_trigger_on(nn.trigger_name);
            ELSE
                switch_trigger_off(nn.trigger_name);
            END IF;
        END LOOP;
        COMMIT;
        pkg_sys_utl.log_audit_info(c_log_code_balance_mode, 'Включен режим пересчета остатков: ONDEMAND');
    END start_ondemand_mode;

    PROCEDURE restore_pst_triggers IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        FOR nn IN (SELECT * FROM (
                       SELECT s.*, row_number() OVER (PARTITION BY trigger_name ORDER BY sq DESC) rn FROM trg_state s
                   ) WHERE rn = 1) LOOP
            IF (nn.trigger_state = aq_pkg_const.c_trigger_state_enabled) THEN
                switch_trigger_on(nn.trigger_name);
                pkg_sys_utl.log_audit_info('SwitchTrigger', 'Включен триггер "'||nn.trigger_name
                    ||'" при восстановленим состояния на момет последнего включения "'
                    ||to_char(nn.ts, 'YYYY-MM-DD HH24:MI:SS.FF6')||'" режима ONDEMAND');
            END IF;
        END LOOP;

        check_triggers;
        COMMIT;
    END restore_pst_triggers;

    FUNCTION comma_to_array(a_names_string VARCHAR2, a_delim VARCHAR2) RETURN dbms_utility.lname_array IS
        l_names DBMS_UTILITY.LNAME_ARRAY;
    BEGIN
        SELECT regexp_substr(a_names_string, '[^'||a_delim||']+', 1, level) current_version BULK COLLECT INTO l_names
          FROM DUAL
       CONNECT BY regexp_substr(a_names_string, '[^'||a_delim||']+', 1, level) IS NOT null;
       RETURN l_names;
    END comma_to_array;

    FUNCTION get_current_bal_state RETURN VARCHAR2 IS
        l_res v_balmode_status%ROWTYPE;
    BEGIN
        SELECT * INTO l_res
          FROM v_balmode_status WHERE rownum <= 1;
        IF (l_res.current_mode IN (aq_pkg_const.get_const_trigger_form_online, aq_pkg_const.get_const_trigger_form_gibrid)
                AND l_res.mode_status = 'OK' AND l_res.mode_status_cnt = 'OK') THEN
            RETURN l_res.current_mode;
        ELSE
            RAISE_APPLICATION_ERROR(-20111, 'Неудалось определить текущий режим пересчета остатков: mode='
                ||l_res.current_mode||' mode_status='||l_res.mode_status||' mode_status_cnt='||l_res.mode_status_cnt);
        END IF;
    EXCEPTION
        WHEN no_data_found THEN
            RETURN 'ONDEMAND';
    END get_current_bal_state;

    PROCEDURE check_balance_mode (a_target VARCHAR2) IS
    BEGIN
        IF (get_current_bal_state <> a_target) THEN
            RAISE_APPLICATION_ERROR(-20111, 'Текущий режим "'||get_current_bal_state
                ||'" не соответствует целевому "'||a_target||'"');
        END IF;
    END check_balance_mode;

    PROCEDURE save_triggers_status IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_sq NUMBER;
    BEGIN
        SELECT seq_trg_state.nextval INTO l_sq FROM DUAL;
        INSERT INTO trg_state (table_name, trigger_name, trigger_state, ts, sq)
        SELECT table_name, trigger_name, status, systimestamp, l_sq
          FROM user_triggers WHERE table_name = 'PST';
        COMMIT;
    END save_triggers_status;

    PROCEDURE stop_queue IS
    BEGIN
        dbms_aqadm.stop_queue (
           queue_name  => aq_pkg_const.c_normal_queue_name,
           enqueue     => true,
           dequeue     => false,
           wait        => true);
        pkg_sys_utl.log_audit_warn(c_log_code_async, 'Очередь '||aq_pkg_const.c_normal_queue_name
            ||' закрыта на прием сообщений');
    END stop_queue;

    PROCEDURE check_error_queue IS

        PRAGMA AUTONOMOUS_TRANSACTION;

        l_cnt_errors NUMBER;

        PROCEDURE stop_deq IS
            e_already_stopped EXCEPTION;
            PRAGMA EXCEPTION_INIT(e_already_stopped, -27366);
        BEGIN
            FOR nn IN (SELECT * FROM user_scheduler_jobs WHERE job_name LIKE aq_pkg_const.get_balance_queue_listnr_prfx||'%')
            LOOP
                BEGIN
                    dbms_scheduler.stop_job(nn.job_name, true);
                EXCEPTION
                    WHEN e_already_stopped THEN null;
                END;
                dbms_scheduler.disable(nn.job_name, true);
                PKG_SYS_UTL.LOG_AUDIT_WARN(c_log_code_async, 'Задача обработки очереди '||nn.job_name||' остановлена');
            END LOOP;
        END stop_deq;
    BEGIN
        EXECUTE IMMEDIATE 'SELECT count(1) FROM '
            ||aq_pkg_const.C_NORMAL_QUEUE_TAB_NAME
            ||' where q_name = '''||aq_pkg_const.GET_BALANCE_EXC_QUEUE_NAME||'''' into l_cnt_errors;
        IF (l_cnt_errors > 0) THEN
            pkg_sys_utl.log_audit_error(c_log_code_async, 'Есть ошибки обработки оборотов'
                , 'Очередь ошибок содержит сообщений: '||to_char(l_cnt_errors)
                    ||chr(10)||'. Обработка очереди будет остановлена. Сообщения в очереди ошибок необходимо'
                    ||chr(10)||' обработать ПОСЛЕ устранения причины ошибок обработки. Подробности ошибок обработки см. таблицу AUDIT.'
                    ||chr(10)||' Дальнейшая обработка поступающих оборотов желательна после обработки сообщений из очереди ошибок'
                , null);
            stop_queue();
            stop_deq();
        END IF;

    END check_error_queue;

END aq_pkg_utl;
/