CREATE OR REPLACE TRIGGER pstad AFTER DELETE ON pst
	REFERENCES old AS orow FOR EACH ROW
	WHEN (orow.invisible <> '1')
DECLARE
    curdtac NUMBER(19, 0); -- Дебетовый оборот в валюте счета BSAACID
    curdtbc NUMBER(19, 0); -- Дебетовый оборот в валюте локализации
    curctac NUMBER(19, 0); -- Кредитовый оборот в валюте счета BSAACID
    curctbc NUMBER(19, 0); -- Кредитовый оборот в валюте локализации
    cur_acc_id NUMBER(22, 0) := null;
BEGIN

    IF (:orow.amntlc >= 0) THEN
        curdtac := 0; curdtbc := 0;
        curctac := :orow.amnt; curctbc := :orow.amntlc;
    ELSIF (:orow.amntlc < 0) THEN
        curdtac := :orow.amnt; curdtbc := :orow.amntlc;
        curctac := 0; curctbc := 0;
    END IF;

    -- корректируем остатки и обороты всех интервалов, начиная с того, в который попадает проводка
    UPDATE baltur
       SET
           obac = (CASE WHEN baltur.dat = :orow.pod THEN baltur.obac ELSE baltur.obac - (curctac + curdtac) END),
           obbc = (CASE WHEN baltur.dat = :orow.pod THEN baltur.obbc ELSE baltur.obbc - (curctbc + curdtbc) END),
           dtac = (CASE WHEN baltur.dat = :orow.pod THEN baltur.dtac - curdtac ELSE baltur.dtac END),
           dtbc = (CASE WHEN baltur.dat = :orow.pod THEN baltur.dtbc - curdtbc ELSE baltur.dtbc END),
           ctac = (CASE WHEN baltur.dat = :orow.pod THEN baltur.ctac - curctac ELSE baltur.ctac END),
           ctbc = (CASE WHEN baltur.dat = :orow.pod THEN baltur.ctbc - curctbc ELSE baltur.ctbc END)
     WHERE baltur.dat >= :orow.pod AND baltur.acc_id is null AND baltur.bsaacid = :orow.bsaacid;
END ;
/
