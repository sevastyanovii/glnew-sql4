create or replace trigger TRG_CUSTOMER_H before update on customer for each row
declare
    l_row customer_h%rowtype;
begin
    l_row.TS := systimestamp;
    l_row.idpk    := :old.idpk;
    l_row.custid  := :old.custid;
    l_row.custype := :old.custype;
    l_row.br_id   := :old.br_id;
    l_row.c_name  := :old.c_name;
    l_row.inn     := :old.inn;
    l_row.surname := :old.surname;
    l_row.p_name  := :old.p_name;
    l_row.snd_name:= :old.snd_name;
    l_row.docser  := :old.docser;
    l_row.docnum  := :old.docnum;
    l_row.docdt   := :old.docdt;
    l_row.birthdt := :old.birthdt;
    l_row.pinfl   := :old.pinfl;
    l_row.res     := :old.res;
    l_row.fcstatus:= :old.fcstatus;
    l_row.bnk_br  := :old.bnk_br;
    l_row.rec_no  := :old.rec_no;
    l_row.inp_dt  := :old.inp_dt;
    l_row.inputter:= :old.inputter;

    l_row.chg_vector := 'U';
    :new.rec_no := :old.rec_no + 1;

    insert into customer_h values l_row;

end;
/
