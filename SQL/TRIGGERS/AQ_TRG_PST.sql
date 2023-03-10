CREATE OR REPLACE TRIGGER aq_trg_pst
    AFTER INSERT OR DELETE OR UPDATE
    OF invisible, amntlc, amnt, ccy, bsaacid, pod ON pst FOR EACH ROW
DECLARE
    l_aq_type AQ_TYPE;
    l_pbr PST.PBR%TYPE;
BEGIN

    -- check condition (only for not invisible)
    IF ((inserting AND nvl(:new.invisible, '0') = '1') OR
        (updating  AND nvl(:new.invisible, '0') = '1' AND nvl(:old.invisible, '0') = '1') OR
        (deleting  AND nvl(:old.invisible, '0') = '1'))
    THEN
        RETURN;
    END IF;

    IF (inserting OR updating) THEN
        l_pbr := :new.pbr;
    ELSIF (deleting) THEN
        l_pbr := :old.pbr;
    END IF;

    IF (aq_pkg.is_syncbalcalc(l_pbr)) THEN
        IF  (inserting AND nvl(:new.invisible, '0') <> '1' ) THEN
            aq_pkg.pd_after_insert(
                a_new_bsaacid => :new.bsaacid,
                a_new_pod => :new.pod,
                a_new_amntlc => :new.amntlc,
                a_new_amnt => :new.amnt,
                a_new_pbr => :new.pbr);
        ELSIF (updating) THEN
            aq_pkg.pd_after_update(
                a_new_bsaacid => :new.bsaacid,
                a_new_invisible => :new.invisible,
                a_new_pod => :new.pod,
                a_new_amnt => :new.amnt,
                a_new_amntlc => :new.amntlc,
                a_new_pbr => :new.pbr,
                a_old_bsaacid => :old.bsaacid,
                a_old_invisible => :old.invisible,
                a_old_pod => :old.pod,
                a_old_amnt => :old.amnt,
                a_old_amntlc => :old.amntlc);
        ELSIF (deleting) THEN
            aq_pkg.pd_after_delete(
                a_old_bsaacid => :old.bsaacid,
                a_old_pod => :old.pod,
                a_old_amnt => :old.amnt,
                a_old_amntlc => :old.amntlc);
        END IF;
        -- !!! окончание синхронного обновления остатков
        RETURN;
    END IF;

    IF (inserting) THEN
        l_aq_type := AQ_TYPE();
        l_aq_type.id := :new.id;
        l_aq_type.pcid := :new.pcid;
        l_aq_type.new_bsaacid := :new.bsaacid;
        l_aq_type.new_invisible := :new.invisible;
        l_aq_type.new_pod := :new.pod;
        l_aq_type.new_amnt := :new.amnt;
        l_aq_type.new_amntlc := :new.amntlc;
        l_aq_type.new_pbr := :new.pbr;
        l_aq_type.old_bsaacid := null;
        l_aq_type.old_invisible := null;
        l_aq_type.old_pod := null;
        l_aq_type.old_amnt := null;
        l_aq_type.old_amntlc := null;
    ELSIF (updating) THEN
        l_aq_type := AQ_TYPE();
        l_aq_type.id := :new.id;
        l_aq_type.pcid := :new.pcid;
        l_aq_type.new_bsaacid := :new.bsaacid;
        l_aq_type.new_invisible := :new.invisible;
        l_aq_type.new_pod := :new.pod;
        l_aq_type.new_amnt := :new.amnt;
        l_aq_type.new_amntlc := :new.amntlc;
        l_aq_type.new_pbr := :new.pbr;
        l_aq_type.old_bsaacid := :old.bsaacid;
        l_aq_type.old_invisible := :old.invisible;
        l_aq_type.old_pod := :old.pod;
        l_aq_type.old_amnt := :old.amnt;
        l_aq_type.old_amntlc := :old.amntlc;
    ELSIF (deleting) THEN
        l_aq_type := AQ_TYPE();
        l_aq_type.id := :old.id;
        l_aq_type.pcid :=  null;
        l_aq_type.new_bsaacid := null;
        l_aq_type.new_invisible := null;
        l_aq_type.new_pod := null;
        l_aq_type.new_amnt := null;
        l_aq_type.new_amntlc := null;
        l_aq_type.new_pbr := null;
        l_aq_type.old_bsaacid := :old.bsaacid;
        l_aq_type.old_invisible := :old.invisible;
        l_aq_type.old_pod := :old.pod;
        l_aq_type.old_amnt := :old.amnt;
        l_aq_type.old_amntlc := :old.amntlc;
    END IF;

    aq_pkg.enqueue(l_aq_type);

END aq_trg_pst;
/
ALTER TRIGGER aq_trg_pst DISABLE;
/