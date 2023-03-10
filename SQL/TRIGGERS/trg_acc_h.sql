CREATE OR REPLACE TRIGGER trg_acc_h BEFORE UPDATE ON acc FOR EACH ROW
DECLARE
    l_row acc_h%rowtype;
BEGIN
    l_row.ts           := systimestamp;
    l_row.acc_id       := :old.acc_id;
    l_row.bsaacid      := :old.bsaacid;
    l_row.bank_id      := :old.bank_id;
    l_row.branch       := :old.branch;
    l_row.ccy          := :old.ccy;
    l_row.custid       := :old.custid;
    l_row.acctype      := :old.acctype;
    l_row.ctype        := :old.ctype;
    l_row.term         := :old.term;
    l_row.gl_seq       := :old.gl_seq;
    l_row.acc2         := :old.acc2;
    l_row.psav         := :old.psav;
    l_row.dealsrc      := :old.dealsrc;
    l_row.dealid       := :old.dealid;
    l_row.subdealid    := :old.subdealid;
    l_row.description  := :old.description;
    l_row.dto          := :old.dto;
    l_row.dtc          := :old.dtc;
    l_row.dtr          := :old.dtr;
    l_row.dtm          := :old.dtm;
    l_row.opentype     := :old.opentype;
    l_row.gloid        := :old.gloid;
    l_row.glo_dc       := :old.glo_dc;
    l_row.rec_no       := :old.rec_no;
    l_row.inp_dt       := :old.inp_dt;

    l_row.chg_vector := 'U';
    :new.rec_no := :old.rec_no + 1;

    INSERT INTO acc_h VALUES l_row;
END;
/
