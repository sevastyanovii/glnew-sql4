CREATE OR REPLACE PACKAGE aq_pkg IS

    PROCEDURE pd_after_insert(a_new_bsaacid CHAR, a_new_pod DATE, a_new_amntlc NUMBER, a_new_amnt NUMBER, a_new_pbr CHAR);

    PROCEDURE pd_after_update(a_new_bsaacid CHAR, a_new_invisible CHAR, a_new_pod DATE, a_new_amnt NUMBER, a_new_amntlc NUMBER,
              a_new_pbr CHAR, a_old_bsaacid CHAR, a_old_invisible CHAR, a_old_pod DATE, a_old_amnt NUMBER, a_old_amntlc NUMBER);

    PROCEDURE pd_after_delete(a_old_bsaacid CHAR, a_old_pod DATE, a_old_amnt NUMBER, a_old_amntlc NUMBER);

    FUNCTION is_syncbalcalc(a_pd_pbr CHAR) RETURN BOOLEAN RESULT_CACHE;

    PROCEDURE enqueue(a_aq_type AQ_TYPE);
    PROCEDURE start_deq(a_queue_name VARCHAR2, a_wait_nomsg BINARY_INTEGER, a_period_minute BINARY_INTEGER);
    PROCEDURE process_msg(a_aq_type AQ_TYPE);

    --process one message with nowait option
    PROCEDURE dequeue_process_one(a_queue_name VARCHAR2);

    FUNCTION check_queue_newacc(a_bsaacid VARCHAR2) RETURN CHAR;
    FUNCTION check_queue_oldacc(a_bsaacid VARCHAR2) RETURN CHAR;

END aq_pkg;
/

CREATE OR REPLACE PACKAGE BODY aq_pkg IS

    PROCEDURE pd_after_insert(a_new_bsaacid CHAR, a_new_pod DATE, a_new_amntlc NUMBER, a_new_amnt NUMBER, a_new_pbr CHAR) IS

        curdtac NUMBER(19, 0);
        curdtbc NUMBER(19, 0);
        curctac NUMBER(19, 0);
        curctbc NUMBER(19, 0);

        btdatl      DATE;
        btdat       DATE;
        btdatto     DATE;
        btbsaacid   CHAR(20);
        btobac      NUMBER(19, 0);
        btobbc      NUMBER(19, 0);
    BEGIN

        IF a_new_amntlc >= 0 THEN
            curdtac := 0; curdtbc := 0;
            curctac := a_new_amnt; curctbc := a_new_amntlc;
        ELSIF a_new_amntlc < 0 THEN
            curdtac := a_new_amnt; curdtbc := a_new_amntlc;
            curctac := 0; curctbc := 0;
        END IF;

        -- ищем последний интервал баланса по счету
        BEGIN
            SELECT baltur.dat, baltur.datto, baltur.datl, baltur.bsaacid,
                (CASE WHEN baltur.dat = a_new_pod THEN baltur.obac ELSE baltur.obac + (baltur.ctac + baltur.dtac) END),
                (CASE WHEN baltur.dat = a_new_pod THEN baltur.obbc ELSE baltur.obbc + (baltur.ctbc + baltur.dtbc) END)
                INTO btdat, btdatto, btdatl, btbsaacid, btobac, btobbc
            FROM BALTUR WHERE BALTUR.DATTO = to_date('01.01.2100', 'DD.MM.YYYY')
              AND baltur.acc_id is null AND baltur.bsaacid = a_new_bsaacid FOR UPDATE NOWAIT;
        EXCEPTION
            WHEN no_data_found THEN
                btdat := null; btdatto := null; btdatl := null; btbsaacid := null; btobac := null; btobbc := null;
        END;

        IF btbsaacid IS NULL THEN
            -- нет данных по остаткам - добавляем интервал
            INSERT INTO baltur (dat, datto, datl, acc_id, bsaacid, dtac, dtbc, ctac, ctbc)
            VALUES (a_new_pod, to_date('01.01.2100', 'DD.MM.YYYY'), btdatl, null, a_new_bsaacid, curdtac, curdtbc, curctac, curctbc);

        ELSIF btdat = a_new_pod THEN
            -- выбрана запись с бансом 2100г равным дате проводки
            UPDATE baltur
            SET
                datl = (CASE WHEN (baltur.datl IS null) OR baltur.datl < btdatl THEN btdatl ELSE baltur.datl END),
                dtac = baltur.dtac + curdtac,
                dtbc = baltur.dtbc + curdtbc,
                ctac = baltur.ctac + curctac,
                ctbc = baltur.ctbc + curctbc
            WHERE baltur.dat = a_new_pod AND baltur.datto = btdatto AND baltur.acc_id is null AND baltur.bsaacid = a_new_bsaacid;

        ELSIF btdat < a_new_pod THEN
            -- дата баланса 2100г меньше даты проводки
            UPDATE baltur
                SET datto = a_new_pod - 1
            WHERE baltur.dat = btdat AND baltur.acc_id is null AND baltur.bsaacid = a_new_bsaacid AND baltur.datto = btdatto;

            INSERT INTO baltur (dat, datto, datl, acc_id, bsaacid, obac, obbc, dtac, dtbc, ctac, ctbc)
            VALUES (a_new_pod, btdatto, btdatl, null, a_new_bsaacid, btobac, btobbc, curdtac, curdtbc, curctac, curctbc);

        ELSIF btdat > a_new_pod THEN
            -- дата баланса 2100г больше даты проводки, ищем актуальный интервал для a_new_pod
            BEGIN
              SELECT baltur.dat, baltur.datto, baltur.datl, baltur.bsaacid,
                    (CASE WHEN baltur.dat = a_new_pod THEN baltur.obac ELSE baltur.obac + (baltur.ctac + baltur.dtac) END),
                    (CASE WHEN baltur.dat = a_new_pod THEN baltur.obbc ELSE baltur.obbc + (baltur.ctbc + baltur.dtbc) END)
                    INTO btdat, btdatto, btdatl, btbsaacid, btobac, btobbc
                FROM baltur WHERE (baltur.dat <= a_new_pod AND a_new_pod <= baltur.datto)
                 AND baltur.acc_id is null AND baltur.bsaacid = a_new_bsaacid FOR UPDATE NOWAIT;
            EXCEPTION
                WHEN no_data_found THEN
                    btdat := null; btdatto := null; btdatl := null; btbsaacid := null; btobac := null; btobbc := null;
            END;

            IF btbsaacid IS NULL THEN

                SELECT min(baltur.dat) INTO btdat FROM baltur WHERE baltur.acc_id is null AND baltur.bsaacid = a_new_bsaacid;

                IF btdat IS NULL THEN
                    btdatto := to_date('01.01.2100', 'DD.MM.YYYY');
                ELSE
                    btdatto := btdat - 1;
                END IF;

                INSERT INTO baltur(dat, datto, datl, acc_id, bsaacid, obac, obbc, dtac, dtbc, ctac, ctbc)
                VALUES (a_new_pod, btdatto, btdatl, null, a_new_bsaacid, 0, 0, curdtac, curdtbc, curctac, curctbc);

                UPDATE baltur
                SET
                    datl = (CASE WHEN (baltur.datl IS null) OR baltur.datl < btdatl THEN btdatl ELSE baltur.datl END),
                    obac = baltur.obac + (curctac + curdtac),
                    obbc = baltur.obbc + (curctbc + curdtbc)
                WHERE btdatto < baltur.datto AND baltur.acc_id is null AND baltur.bsaacid = a_new_bsaacid;

            ELSIF btdat < a_new_pod THEN

                UPDATE baltur SET datto = a_new_pod - 1
                 WHERE baltur.dat = btdat AND baltur.acc_id is null AND baltur.bsaacid = a_new_bsaacid AND baltur.datto = btdatto;

                INSERT INTO baltur (dat, datto, datl, acc_id, bsaacid, obac, obbc, dtac, dtbc, ctac, ctbc)
                VALUES (a_new_pod, btdatto, btdatl, null, a_new_bsaacid, btobac, btobbc, curdtac, curdtbc, curctac, curctbc);

                UPDATE baltur
                SET
                    datl = (CASE WHEN (baltur.datl IS null) OR baltur.datl < btdatl THEN btdatl ELSE baltur.datl END),
                    obac = baltur.obac + (curctac + curdtac),
                    obbc = baltur.obbc + (curctbc + curdtbc)
                WHERE btdatto < baltur.datto AND baltur.acc_id is null AND baltur.bsaacid = a_new_bsaacid;

            ELSIF btdat = a_new_pod THEN

                UPDATE baltur
                SET
                    datl = (CASE WHEN (baltur.datl IS null) OR baltur.datl < btdatl THEN btdatl ELSE baltur.datl END),
                    obac = (CASE WHEN baltur.dat = a_new_pod THEN baltur.obac ELSE baltur.obac + (curctac + curdtac) END),
                    obbc = (CASE WHEN baltur.dat = a_new_pod THEN baltur.obbc ELSE baltur.obbc + (curctbc + curdtbc) END),
                    dtac = (CASE WHEN baltur.dat = a_new_pod THEN baltur.dtac + curdtac ELSE baltur.dtac END),
                    dtbc = (CASE WHEN baltur.dat = a_new_pod THEN baltur.dtbc + curdtbc ELSE baltur.dtbc END),
                    ctac = (CASE WHEN baltur.dat = a_new_pod THEN baltur.ctac + curctac ELSE baltur.ctac END),
                    ctbc = (CASE WHEN baltur.dat = a_new_pod THEN baltur.ctbc + curctbc ELSE baltur.ctbc END)
                WHERE btdatto <= baltur.datto AND baltur.acc_id is null AND baltur.bsaacid = a_new_bsaacid;
            END IF;
        END IF;
    END pd_after_insert;

    PROCEDURE pd_after_update(
            a_new_bsaacid CHAR, a_new_invisible CHAR, a_new_pod DATE, a_new_amnt NUMBER, a_new_amntlc NUMBER, a_new_pbr CHAR,
            a_old_bsaacid CHAR, a_old_invisible CHAR, a_old_pod DATE, a_old_amnt NUMBER, a_old_amntlc NUMBER) IS
        curdtac NUMBER(19, 0); curdtbc NUMBER(19, 0);
        curctac NUMBER(19, 0); curctbc NUMBER(19, 0);

        ncurdtac NUMBER(19, 0); ncurdtbc NUMBER(19, 0);
        ncurctac NUMBER(19, 0); ncurctbc NUMBER(19, 0);

        btdatl  DATE;
        btdat   DATE;
        btdatto DATE;
        btbsaacid CHAR(20);
        btobac NUMBER(19, 0);
        btobbc NUMBER(19, 0);
    BEGIN

        IF (nvl(a_new_invisible,'0') <> '1' AND a_new_pod = a_old_pod AND
            a_new_bsaacid = a_old_bsaacid AND nvl(a_new_invisible,'0') = nvl(a_old_invisible,'0'))
        THEN
            IF a_old_amntlc >= 0 THEN
                curdtac := 0; curdtbc := 0;
                curctac := a_old_amnt; curctbc := a_old_amntlc;
            ELSIF a_old_amntlc < 0 THEN
                curdtac := a_old_amnt;
                curdtbc := a_old_amntlc;
                curctac := 0;
                curctbc := 0;
            END IF;

            IF a_new_amntlc >= 0 THEN
                ncurdtac := 0;
                ncurdtbc := 0;
                ncurctac := a_new_amnt;
                ncurctbc := a_new_amntlc;
            ELSIF a_new_amntlc < 0 THEN
                ncurdtac := a_new_amnt;
                ncurdtbc := a_new_amntlc;
                ncurctac := 0;
                ncurctbc := 0;
            END IF;

            UPDATE baltur
            SET obac = (CASE WHEN baltur.dat = a_new_pod THEN baltur.obac ELSE BALTUR.OBAC + (ncurctac + ncurdtac - curctac - curdtac) END),
                obbc = (CASE WHEN baltur.dat = a_new_pod THEN baltur.obbc ELSE BALTUR.OBBC + (ncurctbc + ncurdtbc - curctbc - curdtbc) END),
                dtac = (CASE WHEN baltur.dat = a_new_pod THEN baltur.dtac + ncurdtac - curdtac ELSE baltur.dtac END),
                dtbc = (CASE WHEN baltur.dat = a_new_pod THEN baltur.dtbc + ncurdtbc - curdtbc ELSE baltur.dtbc END),
                ctac = (CASE WHEN baltur.dat = a_new_pod THEN baltur.ctac + ncurctac - curctac ELSE baltur.ctac END),
                ctbc = (CASE WHEN baltur.dat = a_new_pod THEN baltur.ctbc + ncurctbc - curctbc ELSE baltur.ctbc END)
            WHERE baltur.datto >= a_new_pod AND baltur.acc_id is null AND baltur.bsaacid = a_new_bsaacid;
        ELSE
            IF a_old_amntlc >= 0 THEN
                curdtac := 0;
                curdtbc := 0;
                curctac := a_old_amnt;
                curctbc := a_old_amntlc;
            ELSIF a_old_amntlc < 0 THEN
                Curdtac := a_old_amnt;
                curdtbc := a_old_amntlc;
                curctac := 0;
                curctbc := 0;
            END IF;

            IF nvl(a_old_invisible,'0') <> '1' THEN
                UPDATE baltur
                SET obac = (CASE WHEN baltur.dat = a_old_pod THEN baltur.obac ELSE baltur.obac - (curctac + curdtac) END),
                    obbc = (CASE WHEN baltur.dat = a_old_pod THEN baltur.obbc ELSE baltur.obbc - (curctbc + curdtbc) END),
                    dtac = (CASE WHEN baltur.dat = a_old_pod THEN baltur.dtac - curdtac ELSE baltur.dtac END),
                    dtbc = (CASE WHEN baltur.dat = a_old_pod THEN baltur.dtbc - curdtbc ELSE baltur.dtbc END),
                    ctac = (CASE WHEN baltur.dat = a_old_pod THEN baltur.ctac - curctac ELSE baltur.ctac END),
                    ctbc = (CASE WHEN baltur.dat = a_old_pod THEN baltur.ctbc - curctbc ELSE baltur.ctbc END)
                WHERE baltur.dat >= a_old_pod AND baltur.acc_id is null AND baltur.bsaacid = a_old_bsaacid;
            END IF;

            IF nvl(a_new_invisible, '0') <> '1' THEN
                IF (a_new_amntlc >= 0) THEN
                    curdtac := 0; curdtbc := 0;
                    curctac := a_new_amnt; curctbc := a_new_amntlc;
                ELSIF (a_new_amntlc < 0) THEN
                    curdtac := a_new_amnt; curdtbc := a_new_amntlc;
                    curctac := 0; curctbc := 0;
                END IF;

                BEGIN
                    SELECT baltur.dat, baltur.datto, baltur.datl, baltur.bsaacid,
                        (CASE WHEN baltur.dat = a_new_pod THEN baltur.obac ELSE baltur.obac + (baltur.ctac + baltur.dtac) END),
                        (CASE WHEN baltur.dat = a_new_pod THEN baltur.obbc ELSE baltur.obbc + (baltur.ctbc + baltur.dtbc) END)
                      INTO btdat, btdatto, btdatl, btbsaacid, btobac, btobbc
                      FROM baltur WHERE baltur.datto = to_date('01.01.2100', 'DD.MM.YYYY') AND baltur.acc_id is null AND baltur.bsaacid = a_new_bsaacid FOR UPDATE NOWAIT;
                EXCEPTION
                    WHEN no_data_found THEN
                        btdat := null; btdatto := null; btdatl := null; btbsaacid := null; btobac := null; btobbc := null;
                END;

                IF (btbsaacid IS null) THEN
                    INSERT INTO baltur (dat, datto, datl, acc_id, bsaacid, dtac, dtbc, ctac, ctbc)
                    VALUES (a_new_pod, to_date('01.01.2100', 'DD.MM.YYYY'), btdatl, null, a_new_bsaacid, curdtac, curdtbc, curctac, curctbc);
                ELSIF (btdat = a_new_pod) THEN
                    UPDATE baltur
                    SET datl = (CASE WHEN (baltur.datl IS null) OR baltur.datl < btdatl THEN btdatl ELSE baltur.datl END),
                        dtac = baltur.dtac + curdtac,
                        dtbc = baltur.dtbc + curdtbc,
                        ctac = baltur.ctac + curctac,
                        ctbc = baltur.ctbc + curctbc
                    WHERE baltur.dat = a_new_pod AND baltur.acc_id is null AND baltur.bsaacid = a_new_bsaacid;
                ELSIF btdat < a_new_pod THEN
                    UPDATE baltur
                       SET datto = a_new_pod - 1
                     WHERE baltur.dat = btdat AND baltur.acc_id is null AND baltur.bsaacid = a_new_bsaacid;

                    INSERT INTO BALTUR (dat, datto, datl, acc_id, bsaacid, obac, obbc, dtac, dtbc, ctac, ctbc)
                    VALUES (a_new_pod, btdatto, btdatl, null, a_new_bsaacid, btobac, btobbc, curdtac, curdtbc, curctac, curctbc);
                ELSIF (btdat > a_new_pod) THEN
                    BEGIN
                        SELECT baltur.dat, baltur.datto, baltur.datl, baltur.bsaacid,
                            (CASE WHEN baltur.dat = a_new_pod THEN baltur.obac ELSE baltur.obac + (baltur.ctac + baltur.dtac) END),
                            (CASE WHEN baltur.dat = a_new_pod THEN baltur.obbc ELSE baltur.obbc + (baltur.ctbc + baltur.dtbc) END)
                          INTO btdat, btdatto, btdatl, btbsaacid, btobac, btobbc
                          FROM baltur
                         WHERE (a_new_pod BETWEEN baltur.dat AND baltur.datto) AND baltur.acc_id is null AND baltur.bsaacid = a_new_bsaacid FOR UPDATE NOWAIT;
                    EXCEPTION
                        WHEN no_data_found THEN
                            btdat := null; btdatto  := null; btdatl  := null; btbsaacid  := null; btobac  := null; btobbc  := null;
                    END;

                    IF (btbsaacid IS null) THEN

                        SELECT min(baltur.dat) INTO btdat FROM baltur WHERE baltur.acc_id is null AND baltur.bsaacid = a_new_bsaacid;

                        IF btdat IS null THEN
                            btdatto := to_date('01.01.2029', 'DD.MM.YYYY');
                        ELSE
                            btdatto := btdat - 1;
                        END IF;

                        INSERT INTO baltur (dat, datto, datl, acc_id, bsaacid, obac, obbc, dtac, dtbc, ctac, ctbc)
                        VALUES (a_new_pod, btdatto, btdatl, null, a_new_bsaacid, 0, 0, curdtac, curdtbc, curctac, curctbc);

                        UPDATE baltur
                        SET datl = (CASE WHEN (baltur.datl IS null) OR baltur.datl < btdatl THEN btdatl ELSE baltur.datl END),
                            obac = baltur.obac + (curctac + curdtac),
                            obbc = baltur.obbc + (curctbc + curdtbc)
                        WHERE baltur.dat > a_new_pod AND baltur.acc_id is null AND baltur.bsaacid = a_new_bsaacid;

                    ELSIF btdat < a_new_pod THEN
                        UPDATE baltur SET datto = a_new_pod - 1 WHERE baltur.dat = btdat AND baltur.acc_id is null AND baltur.bsaacid = a_new_bsaacid;

                        INSERT INTO baltur (dat, datto, datl, acc_id, bsaacid, obac, obbc, dtac, dtbc, ctac, ctbc)
                        VALUES (a_new_pod, btdatto, btdatl, null, a_new_bsaacid, btobac, btobbc, curdtac, curdtbc, curctac, curctbc);

                        UPDATE baltur
                        SET datl = (CASE WHEN (baltur.datl IS null) OR baltur.datl < btdatl THEN btdatl ELSE baltur.datl END),
                            obac = baltur.obac + (curctac + curdtac),
                            obbc = baltur.obbc + (curctbc + curdtbc)
                        WHERE baltur.dat > a_new_pod AND baltur.acc_id is null AND baltur.bsaacid = a_new_bsaacid;
                    ELSIF btdat = a_new_pod THEN
                        UPDATE baltur
                        SET datl = (CASE WHEN (baltur.datl IS null) OR baltur.datl < btdatl THEN btdatl ELSE baltur.datl END),
                            obac = (CASE WHEN baltur.dat = a_new_pod THEN baltur.obac ELSE baltur.obac + (curctac + curdtac) END),
                            obbc = (CASE WHEN baltur.dat = a_new_pod THEN baltur.obbc ELSE baltur.obbc + (curctbc + curdtbc) END),
                            dtac = (CASE WHEN baltur.dat = a_new_pod THEN baltur.dtac + curdtac ELSE baltur.dtac END),
                            dtbc = (CASE WHEN baltur.dat = a_new_pod THEN baltur.dtbc + curdtbc ELSE baltur.dtbc END),
                            ctac = (CASE WHEN baltur.dat = a_new_pod THEN baltur.ctac + curctac ELSE baltur.ctac END),
                            ctbc = (CASE WHEN baltur.dat = a_new_pod THEN baltur.ctbc + curctbc ELSE baltur.ctbc END)
                        WHERE baltur.dat >= btdat AND baltur.acc_id is null AND baltur.bsaacid = a_new_bsaacid;
                    END IF;
                END IF;
            END IF;
        END IF;
    END pd_after_update;

    PROCEDURE pd_after_delete(a_old_bsaacid CHAR, a_old_pod DATE, a_old_amnt NUMBER, a_old_amntlc NUMBER) IS
        curdtac NUMBER(19, 0);
        curdtbc NUMBER(19, 0);
        curctac NUMBER(19, 0);
        curctbc NUMBER(19, 0);
    BEGIN
        IF (a_old_amntlc >= 0) THEN
            curdtac := 0; curdtbc := 0;
            curctac := a_old_amnt; curctbc := a_old_amntlc;
        ELSIF (a_old_amntlc < 0) THEN
            curdtac := a_old_amnt; curdtbc := a_old_amntlc;
            curctac := 0; curctbc := 0;
        END IF;

        UPDATE baltur
        SET
            obac = (CASE WHEN baltur.dat = a_old_pod THEN baltur.obac ELSE baltur.obac - (curctac + curdtac) END),
            obbc = (CASE WHEN baltur.dat = a_old_pod THEN baltur.obbc ELSE baltur.obbc - (curctbc + curdtbc) END),
            dtac = (CASE WHEN baltur.dat = a_old_pod THEN baltur.dtac - curdtac ELSE baltur.dtac END),
            dtbc = (CASE WHEN baltur.dat = a_old_pod THEN baltur.dtbc - curdtbc ELSE baltur.dtbc END),
            ctac = (CASE WHEN baltur.dat = a_old_pod THEN baltur.ctac - curctac ELSE baltur.ctac END),
            ctbc = (CASE WHEN baltur.dat = a_old_pod THEN baltur.ctbc - curctbc ELSE baltur.ctbc END)
        WHERE baltur.dat >= a_old_pod AND baltur.acc_id is null AND baltur.bsaacid = a_old_bsaacid;
    END;

    /**
        признак нужно ли проводить пересчет остатков синхронно или через очередь
        returning true - yes, else false
    */
    FUNCTION is_syncbalcalc(a_pd_pbr CHAR) RETURN BOOLEAN RESULT_CACHE IS
        l_res INTEGER;
    BEGIN
        SELECT COUNT(1) INTO l_res FROM aqpbr WHERE pbrvalue = rpad(a_pd_pbr, 7);
        RETURN CASE l_res WHEN 1 THEN true ELSE false END;
    END is_syncbalcalc;

    PROCEDURE enqueue(a_aq_type AQ_TYPE) IS
        l_message_prop DBMS_AQ.MESSAGE_PROPERTIES_T;
        l_enqueue_opt  DBMS_AQ.ENQUEUE_OPTIONS_T;
        l_message_handle RAW(16);
    BEGIN
        l_message_prop.correlation := to_char(a_aq_type.id);
        dbms_aq.enqueue(queue_name => 'BAL_QUEUE',
            enqueue_options => l_enqueue_opt,
            message_properties => l_message_prop,
            payload => a_aq_type,
            msgid => l_message_handle);
    END enqueue;

    FUNCTION dequeue(a_queue_name VARCHAR2, a_wait BINARY_INTEGER, a_navig BINARY_INTEGER) RETURN AQ_TYPE IS
        l_dequeue_opt       DBMS_AQ.DEQUEUE_OPTIONS_T;
        l_message_prop      DBMS_AQ.MESSAGE_PROPERTIES_T;
        l_message_handle    RAW(16);
        l_pd AQ_TYPE;
    BEGIN
        l_dequeue_opt.wait := a_wait;
        l_dequeue_opt.navigation := a_navig;

        Dbms_aq.dequeue(
            queue_name => a_queue_name,
            dequeue_options => l_dequeue_opt,
            message_properties => l_message_prop,
            payload => l_pd,
            msgid => l_message_handle);

        RETURN l_pd;
    END dequeue;

    FUNCTION minutes_between(a_from TIMESTAMP, a_to TIMESTAMP) RETURN NUMBER IS
        l_res NUMBER(10);
    BEGIN
        SELECT extract(minute from (a_to - a_from))
                + extract(hour from (a_to - a_from)) * 60
                + extract(day  from (a_to - a_from)) * 60 * 24
          INTO l_res FROM dual;

        RETURN l_res;
    END minutes_between;

    PROCEDURE start_deq (a_queue_name VARCHAR2, a_wait_nomsg BINARY_INTEGER, a_period_minute BINARY_INTEGER) IS
        l_nomsg_exc EXCEPTION;
        PRAGMA  EXCEPTION_INIT(l_nomsg_exc, -25228);

        l_wait  BINARY_INTEGER := DBMS_AQ.NO_WAIT;
        l_navig BINARY_INTEGER;

        l_current NUMBER;
        l_aq_type AQ_TYPE;
        l_isnomsg BOOLEAN := false;
        l_start_time TIMESTAMP := systimestamp;
    BEGIN
        LOOP
            BEGIN
                IF (l_isnomsg) THEN
                    l_navig := dbms_aq.first_message;
                ELSIF (mod(l_current, 1000) = 0) THEN
                    l_navig := dbms_aq.first_message;
                ELSE
                    l_navig := dbms_aq.next_message;
                END IF;

                l_aq_type := dequeue(a_queue_name, l_wait, l_navig);

                process_msg(l_aq_type);
                COMMIT;

                l_wait := dbms_aq.no_wait;
                l_current := l_current + 1;
                l_isnomsg := false;
            EXCEPTION
                WHEN l_nomsg_exc THEN
                    l_wait := a_wait_nomsg;
                    l_isnomsg := true;
                WHEN others THEN
                    -- rollback for redelivering
                    ROLLBACK;
            END;

            IF (minutes_between(l_start_time, systimestamp) >= a_period_minute) THEN
                RETURN;
            END IF;

        END LOOP;
    END start_deq;

    PROCEDURE dequeue_process_one(a_queue_name VARCHAR2) IS
        l_nomsg_exc EXCEPTION;
        PRAGMA  EXCEPTION_INIT(L_NOMSG_EXC, -25228);
        l_aq_type AQ_TYPE;
    BEGIN
        l_aq_type := dequeue(a_queue_name, dbms_aq.no_wait, dbms_aq.first_message);
        process_msg(l_aq_type);
    EXCEPTION
        WHEN L_NOMSG_EXC THEN NULL;
    END dequeue_process_one;

    PROCEDURE create_update_account_lock(a_bsaacid VARCHAR2) IS
    BEGIN
        IF (trim(a_bsaacid) IS NOT NULL) THEN
            UPDATE bsacclk SET upd_date = systimestamp WHERE bsaacid = a_bsaacid;
            IF (SQL%rowcount = 0) THEN
                BEGIN
                    INSERT INTO bsacclk (bsaacid, upd_date) VALUES (a_bsaacid, systimestamp);
                EXCEPTION
                    WHEN DUP_VAL_ON_INDEX THEN
                       create_update_account_lock(a_bsaacid);
                END;
            END IF;
        END IF;
    END create_update_account_lock;

    PROCEDURE process_msg(a_aq_type AQ_TYPE) IS

        PROCEDURE lock_sorted(a_acc1 VARCHAR2, a_acc2 VARCHAR2) IS
        BEGIN
            IF (a_acc1 >= a_acc2) THEN
                create_update_account_lock(a_acc1);
                create_update_account_lock(a_acc2);
            ELSE
                create_update_account_lock(a_acc2);
                create_update_account_lock(a_acc1);
            END IF;
        END lock_sorted;

    BEGIN
        lock_sorted(a_aq_type.new_bsaacid, a_aq_type.old_bsaacid);

        IF (a_aq_type.new_bsaacid IS NOT NULL AND a_aq_type.old_bsaacid IS NULL) THEN
            aq_pkg.pd_after_insert(
                a_new_bsaacid => a_aq_type.new_bsaacid,
                a_new_pod => a_aq_type.new_pod,
                a_new_amntlc => a_aq_type.new_amntlc,
                a_new_amnt => a_aq_type.new_amnt,
                a_new_pbr => a_aq_type.new_pbr);
        ELSIF (a_aq_type.new_bsaacid IS NOT NULL AND a_aq_type.old_bsaacid IS NOT NULL) THEN
            aq_pkg.pd_after_update(
                a_new_bsaacid => a_aq_type.new_bsaacid,
                a_new_invisible => a_aq_type.new_invisible,
                a_new_pod => a_aq_type.new_pod,
                a_new_amnt => a_aq_type.new_amnt,
                a_new_amntlc => a_aq_type.new_amntlc,
                a_new_pbr => a_aq_type.new_pbr,
                a_old_bsaacid => a_aq_type.old_bsaacid,
                a_old_invisible => a_aq_type.old_invisible,
                a_old_pod => a_aq_type.old_pod,
                a_old_amnt => a_aq_type.old_amnt,
                a_old_amntlc => a_aq_type.old_amntlc);
        ELSIF (a_aq_type.NEW_BSAACID IS NULL AND a_aq_type.OLD_BSAACID IS NOT NULL) THEN
            aq_pkg.pd_after_delete(
                a_old_bsaacid => a_aq_type.old_bsaacid,
                a_old_pod => a_aq_type.old_pod,
                a_old_amnt => a_aq_type.old_amnt,
                a_old_amntlc => a_aq_type.old_amntlc);
        ELSE
            RAISE_APPLICATION_ERROR(-10101, 'Invalid case of message content ' || to_char(a_aq_type.id));
        END IF;

    EXCEPTION
        WHEN others THEN
            pkg_sys_utl.log_audit_error(aq_pkg_const.C_LOG_CODE, 'Error on processing balance message: ',
                sqlerrm, dbms_utility.format_error_backtrace);
            RAISE;
    END process_msg;

    ----- проверка наличия данных по счету в очереди -----
    FUNCTION check_queue(a_bsaacid VARCHAR2, a_field_name VARCHAR2, a_hint VARCHAR2) RETURN BOOLEAN IS
        l_result NUMBER;
        l_curdate DATE;
    BEGIN
        SELECT curdate INTO l_curdate FROM od;

        EXECUTE IMMEDIATE 'SELECT '||a_hint||' 1 FROM '||aq_pkg_const.C_NORMAL_QUEUE_TAB_NAME
                        ||' q WHERE q.user_data.'||a_field_name
                        ||' = :1 AND (q.user_data.new_pod < :2 or q.user_data.old_pod < :3) AND rownum <= 1' INTO l_result
                        USING a_bsaacid, l_curdate, l_curdate;
        RETURN TRUE;
    EXCEPTION WHEN NO_DATA_FOUND THEN RETURN FALSE;
    END check_queue;

    ----- проверка наличия данных по счету в очереди -----
    FUNCTION check_queue_newacc(a_bsaacid VARCHAR2) RETURN CHAR IS
    BEGIN
        RETURN CASE WHEN check_queue(a_bsaacid, 'NEW_BSAACID', '/*+ INDEX (Q IDX_BALQUEUE_NEWBSA) */') THEN '1' ELSE '0' END;
    END check_queue_newacc;

    ----- проверка наличия данных по счету в очереди -----
    FUNCTION check_queue_oldacc(a_bsaacid VARCHAR2) RETURN CHAR IS
    BEGIN
        RETURN CASE WHEN check_queue(a_bsaacid, 'OLD_BSAACID', '/*+ INDEX (Q IDX_BALQUEUE_OLDBSA) */') THEN '1' ELSE '0' END;
    END check_queue_oldacc;

END aq_pkg;
/