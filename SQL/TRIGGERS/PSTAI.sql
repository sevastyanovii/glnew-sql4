create or replace TRIGGER pstai AFTER INSERT ON pst
    REFERENCES new AS nrow FOR EACH ROW
	WHEN (nrow.invisible <> '1')
DECLARE
    curdtac NUMBER(19, 0); -- Дебетовый оборот в валюте счета BSAACID
    curdtbc NUMBER(19, 0); -- Дебетовый оборот в валюте локализации
    curctac NUMBER(19, 0); -- Кредитовый оборот в валюте счета BSAACID
    curctlc NUMBER(19, 0); -- Кредитовый оборот в валюте локализации

    btdatl      DATE; -- Дата последней проводки по счету
    btdat       DATE;
    btdatto     DATE;
    btbsaacid   CHAR(20);
    btobac      NUMBER(19, 0); -- Остаток на начало дня DAT в валюте счета
    btobbc      NUMBER(19, 0); -- Входящий остаток в валюте локализации

    cur_acc_id  NUMBER(22, 0) := :nrow.acc_id;
BEGIN

    IF :nrow.amnt >= 0 THEN
        curdtac := 0; curdtbc := 0;
        curctac := :nrow.amnt; curctlc := :nrow.amnt;
    ELSIF :nrow.amnt < 0 THEN
        curdtac := :nrow.amnt; curdtbc := :nrow.amnt;
        curctac := 0; curctlc := 0;
    END IF;

    -- ищем последний интервал баланса по счету
    BEGIN
        SELECT baltur.dat, baltur.datto, baltur.datl, baltur.bsaacid,
            (CASE WHEN baltur.dat = :nrow.pod THEN baltur.obac ELSE baltur.obac + (baltur.ctac + baltur.dtac) END),
            (CASE WHEN baltur.dat = :nrow.pod THEN baltur.obbc ELSE baltur.obbc + (baltur.ctbc + baltur.dtbc) END)
            INTO btdat, btdatto, btdatl, btbsaacid, btobac, btobbc
        FROM baltur WHERE baltur.datto = DB_CONF.C_MAX_BALANCE_DATE
         AND baltur.bsaacid = :nrow.bsaacid FOR UPDATE NOWAIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            btdat := null; btdatto := null; btdatl := null; btbsaacid := null; btobac := null; btobbc := null;
    END;

    btdatl := :nrow.pod;

    IF btbsaacid IS null THEN
        -- нет данных по остаткам - добавляем интервал
        INSERT INTO baltur (dat, datto, datl, acc_id, bsaacid, dtac, dtbc, ctac, ctbc)
             VALUES (:nrow.pod, DB_CONF.C_MAX_BALANCE_DATE, btdatl, cur_acc_id,
                     :nrow.bsaacid, curdtac, curdtbc, curctac, curctlc);
    ELSIF btdat = :nrow.pod THEN
        -- последний интервал баланса совпадает с днем обрабатываемой проводки - просто корректируем обороты
        UPDATE baltur
           SET
               datl = (CASE WHEN (baltur.datl IS null) OR baltur.datl < btdatl THEN btdatl ELSE baltur.datl END),
               dtac = baltur.dtac + curdtac,
               dtbc = baltur.dtbc + curdtbc,
               ctac = baltur.ctac + curctac,
               ctbc = baltur.ctbc + curctlc
         WHERE baltur.dat = :nrow.pod AND baltur.datto = btdatto AND baltur.bsaacid = :nrow.bsaacid;

    ELSIF btdat < :nrow.pod THEN
        -- последний интервал начинается раньше даты проводки - меняем у него конечную дату и добавляем новый конечный интревал
        UPDATE baltur
           SET datto = :nrow.pod - 1
         WHERE baltur.dat = btdat AND baltur.bsaacid = :nrow.bsaacid AND baltur.datto = btdatto;

        INSERT INTO baltur (dat, datto, datl, acc_id, bsaacid, obac, obbc, dtac, dtbc, ctac, ctbc)
             VALUES (:nrow.pod, btdatto, btdatl, cur_acc_id, :nrow.bsaacid,
                    btobac, btobbc, curdtac, curdtbc, curctac, curctlc);

    ELSIF btdat > :nrow.pod THEN
        -- последний интервал начинается позже даты проводки, ищем актуальный интервал для этой даты
        BEGIN
          SELECT baltur.dat, baltur.datto, baltur.datl, baltur.bsaacid,
                (CASE WHEN baltur.dat = :nrow.pod THEN baltur.obac ELSE baltur.obac + (baltur.ctac + baltur.dtac) END),
                (CASE WHEN baltur.dat = :nrow.pod THEN baltur.obbc ELSE baltur.obbc + (baltur.ctbc + baltur.dtbc) END)
                INTO btdat, btdatto, btdatl, btbsaacid, btobac, btobbc
            FROM baltur WHERE (baltur.dat <= :nrow.pod AND :nrow.pod <= baltur.datto)
                 AND baltur.bsaacid = :nrow.bsaacid FOR UPDATE NOWAIT;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                btdat := null; btdatto := null; btdatl := null; btbsaacid := null; btobac := null; btobbc := null;
        END;

        IF btbsaacid IS null THEN
            -- не нашли подходящий интервал, значит дата проводки раньше начала ведения баланса по счету
            -- создаем новый первый интервал баланса и корректируем остатки у всех последующих интервалов
            SELECT min(baltur.dat) INTO btdat FROM baltur WHERE baltur.bsaacid = :nrow.bsaacid;

            IF btdat IS null THEN
                btdatto := DB_CONF.C_MAX_BALANCE_DATE;
            ELSE
                btdatto := btdat - 1;
            END IF;

            INSERT INTO baltur (dat, datto, datl, acc_id, bsaacid, obac, obbc, dtac, dtbc, ctac, ctbc)
                 VALUES (:nrow.pod, btdatto, nvl(btdatl, :nrow.pod), cur_acc_id, :nrow.bsaacid, 0, 0, curdtac, curdtbc, curctac, curctlc);

            UPDATE baltur
               SET
                   datl = (CASE WHEN (baltur.datl IS null) OR baltur.datl < btdatl THEN btdatl ELSE baltur.datl END),
                   obac = baltur.obac + (curctac + curdtac),
                   obbc = baltur.obbc + (curctlc + curdtbc)
             WHERE btdatto < baltur.datto AND baltur.bsaacid = :nrow.bsaacid;

        ELSIF btdat < :nrow.pod THEN
            -- дата проводки попадает в найденный интервал - делим его на два, и корректируем остатки у всех последующих интервалов
            UPDATE baltur SET datto = :nrow.pod - 1
             WHERE baltur.dat = btdat AND
                   baltur.bsaacid = :nrow.bsaacid AND baltur.datto = btdatto;

            INSERT INTO baltur (dat, datto, datl, acc_id, bsaacid, obac, obbc, dtac, dtbc, ctac, ctbc)
                 VALUES (:nrow.pod, btdatto, btdatl, cur_acc_id, :nrow.bsaacid, btobac, btobbc, curdtac, curdtbc, curctac, curctlc);

            UPDATE baltur
               SET
                   datl = (case when (baltur.datl is null) OR baltur.datl < btdatl THEN btdatl ELSE baltur.datl END),
                   obac = baltur.obac + (curctac + curdtac),
                   obbc = baltur.obbc + (curctlc + curdtbc)
             WHERE btdatto < baltur.datto AND baltur.bsaacid = :nrow.bsaacid;

        ELSIF btdat = :nrow.pod THEN
            -- дата проводки совпадает с началом найденного интервала
            -- корректируем остатки и обороты всех интервалов, начиная с этого
            UPDATE baltur
               SET
                   datl = (CASE WHEN (baltur.datl IS null) OR baltur.datl < btdatl THEN btdatl ELSE baltur.datl END),
                   obac = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.obac ELSE baltur.obac + (curctac + curdtac) END),
                   obbc = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.obbc ELSE baltur.obbc + (curctlc + curdtbc) END),
                   dtac = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.dtac + curdtac ELSE baltur.dtac END),
                   dtbc = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.dtbc + curdtbc ELSE baltur.dtbc END),
                   ctac = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.ctac + curctac ELSE baltur.ctac END),
                   ctbc = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.ctbc + curctlc ELSE baltur.ctbc END)
            WHERE btdatto <= baltur.datto AND baltur.bsaacid = :nrow.bsaacid;
        END IF;
    END IF;
END;
/