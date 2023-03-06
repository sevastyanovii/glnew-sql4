CREATE OR REPLACE TRIGGER pstai AFTER INSERT ON pst
    REFERENCES new AS nrow FOR EACH ROW
	WHEN (nrow.invisible <> '1')
DECLARE
    curdtac NUMBER(19, 0); -- ��������� ������ � ������ ����� BSAACID
    curdtbc NUMBER(19, 0); -- ��������� ������ � ������ �����������
    curctac NUMBER(19, 0); -- ���������� ������ � ������ ����� BSAACID
    curctlc NUMBER(19, 0); -- ���������� ������ � ������ �����������

    btdatl      DATE; -- ���� ��������� �������� �� �����
    btdat       DATE;
    btdatto     DATE;
    btbsaacid   CHAR(20);
    btobac      NUMBER(19, 0); -- ������� �� ������ ��� DAT � ������ �����
    btobbc      NUMBER(19, 0); -- �������� ������� � ������ �����������

    cur_acc_id  NUMBER(22, 0) := null;
BEGIN

    IF :nrow.amntlc >= 0 THEN
        curdtac := 0; curdtbc := 0;
        curctac := :nrow.amnt; curctlc := :nrow.amntlc;
    ELSIF :nrow.amntlc < 0 THEN
        curdtac := :nrow.amnt; curdtbc := :nrow.amntlc;
        curctac := 0; curctlc := 0;
    END IF;

    -- ���� ��������� �������� ������� �� �����
    BEGIN
        SELECT baltur.dat, baltur.datto, baltur.datl, baltur.bsaacid,
            (CASE WHEN baltur.dat = :nrow.pod THEN baltur.obac ELSE baltur.obac + (baltur.ctac + baltur.dtac) END),
            (CASE WHEN baltur.dat = :nrow.pod THEN baltur.obbc ELSE baltur.obbc + (baltur.ctbc + baltur.dtbc) END)
            INTO btdat, btdatto, btdatl, btbsaacid, btobac, btobbc
        FROM baltur WHERE baltur.datto = to_date('01.01.2100', 'DD.MM.YYYY')
          AND baltur.acc_id is null AND baltur.bsaacid = :nrow.bsaacid FOR UPDATE NOWAIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            btdat := null; btdatto := null; btdatl := null; btbsaacid := null; btobac := null; btobbc := null;
    END;

    btdatl := :nrow.pod;

    IF btbsaacid IS null THEN
        -- ��� ������ �� �������� - ��������� ��������
        INSERT INTO baltur (dat, datto, datl, acc_id, bsaacid, dtac, dtbc, ctac, ctbc)
             VALUES (:nrow.pod, to_date('01.01.2100', 'DD.MM.YYYY'), btdatl, cur_acc_id,
                     :nrow.bsaacid, curdtac, curdtbc, curctac, curctlc);
    ELSIF btdat = :nrow.pod THEN
        -- ��������� �������� ������� ��������� � ���� �������������� �������� - ������ ������������ �������
        UPDATE baltur
           SET
               datl = (CASE WHEN (baltur.datl IS null) OR baltur.datl < btdatl THEN btdatl ELSE baltur.datl END),
               dtac = baltur.dtac + curdtac,
               dtbc = baltur.dtbc + curdtbc,
               ctac = baltur.ctac + curctac,
               ctbc = baltur.ctbc + curctlc
         WHERE baltur.dat = :nrow.pod AND baltur.datto = btdatto AND baltur.acc_id is null AND baltur.bsaacid = :nrow.bsaacid;

    ELSIF btdat < :nrow.pod THEN
        -- ��������� �������� ���������� ������ ���� �������� - ������ � ���� �������� ���� � ��������� ����� �������� ��������
        UPDATE baltur
           SET datto = :nrow.pod - 1
         WHERE baltur.dat = btdat AND baltur.acc_id is null AND baltur.bsaacid = :nrow.bsaacid AND baltur.datto = btdatto;

        INSERT INTO baltur (dat, datto, datl, acc_id, bsaacid, obac, obbc, dtac, dtbc, ctac, ctbc)
             VALUES (:nrow.pod, btdatto, btdatl, cur_acc_id, :nrow.bsaacid,
                    btobac, btobbc, curdtac, curdtbc, curctac, curctlc);

    ELSIF btdat > :nrow.pod THEN
        -- ��������� �������� ���������� ����� ���� ��������, ���� ���������� �������� ��� ���� ����
        BEGIN
          SELECT baltur.dat, baltur.datto, baltur.datl, baltur.bsaacid,
                (CASE WHEN baltur.dat = :nrow.pod THEN baltur.obac ELSE baltur.obac + (baltur.ctac + baltur.dtac) END),
                (CASE WHEN baltur.dat = :nrow.pod THEN baltur.obbc ELSE baltur.obbc + (baltur.ctbc + baltur.dtbc) END)
                INTO btdat, btdatto, btdatl, btbsaacid, btobac, btobbc
            FROM baltur WHERE (baltur.dat <= :nrow.pod AND :nrow.pod <= baltur.datto)
                 AND baltur.acc_id is null AND baltur.bsaacid = :nrow.bsaacid FOR UPDATE NOWAIT;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                btdat := null; btdatto := null; btdatl := null; btbsaacid := null; btobac := null; btobbc := null;
        END;

        IF btbsaacid IS null THEN
            -- �� ����� ���������� ��������, ������ ���� �������� ������ ������ ������� ������� �� �����
            -- ������� ����� ������ �������� ������� � ������������ ������� � ���� ����������� ����������
            SELECT min(baltur.dat) INTO btdat FROM baltur WHERE baltur.acc_id is null AND baltur.bsaacid = :nrow.bsaacid;

            IF btdat IS null THEN
                btdatto := to_date('01.01.2100', 'DD.MM.YYYY');
            ELSE
                btdatto := btdat - 1;
            END IF;

            INSERT INTO baltur (dat, datto, datl, acc_id, bsaacid, obac, obbc, dtac, dtbc, ctac, ctbc)
                 VALUES (:nrow.pod, btdatto, btdatl, cur_acc_id, :nrow.bsaacid, 0, 0, curdtac, curdtbc, curctac, curctlc);

            UPDATE baltur
               SET
                   datl = (CASE WHEN (baltur.datl IS null) OR baltur.datl < btdatl THEN btdatl ELSE baltur.datl END),
                   obac = baltur.obac + (curctac + curdtac),
                   obbc = baltur.obbc + (curctlc + curdtbc)
             WHERE btdatto < baltur.datto AND baltur.acc_id is null AND baltur.bsaacid = :nrow.bsaacid;

        ELSIF btdat < :nrow.pod THEN
            -- ���� �������� �������� � ��������� �������� - ����� ��� �� ���, � ������������ ������� � ���� ����������� ����������
            UPDATE baltur SET datto = :nrow.pod - 1
             WHERE baltur.dat = btdat AND baltur.acc_id is null AND
                   baltur.bsaacid = :nrow.bsaacid AND baltur.datto = btdatto;

            INSERT INTO baltur (dat, datto, datl, acc_id, bsaacid, obac, obbc, dtac, dtbc, ctac, ctbc)
                 VALUES (:nrow.pod, btdatto, btdatl, cur_acc_id, :nrow.bsaacid, btobac, btobbc, curdtac, curdtbc, curctac, curctlc);

            UPDATE baltur
               SET
                   datl = (case when (baltur.datl is null) OR baltur.datl < btdatl THEN btdatl ELSE baltur.datl END),
                   obac = baltur.obac + (curctac + curdtac),
                   obbc = baltur.obbc + (curctlc + curdtbc)
             WHERE btdatto < baltur.datto AND baltur.acc_id is null AND baltur.bsaacid = :nrow.bsaacid;

        ELSIF btdat = :nrow.pod THEN
            -- ���� �������� ��������� � ������� ���������� ���������
            -- ������������ ������� � ������� ���� ����������, ������� � �����
            UPDATE baltur
               SET
                   datl = (CASE WHEN (baltur.datl IS null) OR baltur.datl < btdatl THEN btdatl ELSE baltur.datl END),
                   obac = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.obac ELSE baltur.obac + (curctac + curdtac) END),
                   obbc = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.obbc ELSE baltur.obbc + (curctlc + curdtbc) END),
                   dtac = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.dtac + curdtac ELSE baltur.dtac END),
                   dtbc = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.dtbc + curdtbc ELSE baltur.dtbc END),
                   ctac = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.ctac + curctac ELSE baltur.ctac END),
                   ctbc = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.ctbc + curctlc ELSE baltur.ctbc END)
            WHERE btdatto <= baltur.datto AND baltur.acc_id is null AND baltur.bsaacid = :nrow.bsaacid;
        END IF;
    END IF;
END;
/