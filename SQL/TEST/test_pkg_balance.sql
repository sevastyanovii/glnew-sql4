create or replace package test_pkg_balance is
    procedure test_all;
end test_pkg_balance;
/

create or replace package body test_pkg_balance is

    procedure test_new_credit;
    procedure test_new_debit;

    procedure test_all is
    begin
        test_new_credit();
        test_new_debit();
    end test_all;

    procedure test_new_credit is
        c_bsaacid_cr constant acc.bsaacid%type := '12345678901234567890';
        c_pod date := '2022-11-30';
        c_amnt number := 1200011;
        lr_baltur_cr baltur%rowtype;
        lr_pst_cr pst%rowtype;
        l_pstid_cr pst.id%type;

        procedure init is
        begin
            delete from baltur where bsaacid = c_bsaacid_cr;
            delete from pst where bsaacid = c_bsaacid_cr;
            commit;
        end init;

    begin

        init();

        -- insert into pst
        Insert into PST (POD,VALD,ACC_ID,BSAACID,CCY,AMNT,PBR,INVISIBLE,PCID,NRTL
                ,GLO_REF,EVTP,PROCDATE,DEAL_ID,SUBDEAL_ID,EVT_ID,PMT_REF,NRTE,POST_TYPE)
        values (c_pod, c_pod,0,c_bsaacid_cr,'USD',c_amnt,'CASA','0',974,'МОСБИРЖА',511
                ,null,'2022-11-30',null,null,'1682138913562',null,'NASDAC',2) returning id into l_pstid_cr;
        commit;
        select * into lr_pst_cr from pst where id = l_pstid_cr;

        -- check baltur credit
        select * into lr_baltur_cr from baltur where bsaacid = c_bsaacid_cr;
        if (nvl(lr_baltur_cr.dat, db_conf.c_max_balance_date) <> c_pod) then
            raise_application_error(-20000, pkg_format.msg_format3('некоррект: dat {0} {1}', c_pod,lr_baltur_cr.dat));
        end if;
        if (nvl(lr_baltur_cr.datto, db_conf.c_max_balance_date) <> db_conf.c_max_balance_date) then
            raise_application_error(-20000, pkg_format.msg_format3('некоррект: datto {0}',lr_baltur_cr.datto));
        end if;
        if (nvl(lr_baltur_cr.acc_id, -1) <> lr_pst_cr.acc_id) then
            raise_application_error(-20000, pkg_format.msg_format3('некоррект: acc_id "{0}"',lr_baltur_cr.acc_id));
        end if;
        if (nvl(lr_baltur_cr.datl, db_conf.c_max_balance_date) <> lr_pst_cr.pod) then
            raise_application_error(-20000, pkg_format.msg_format3('некоррект: datl "{0}"',lr_baltur_cr.datl));
        end if;
        if (nvl(lr_baltur_cr.obac, -1) <> 0) then
            raise_application_error(-20000, pkg_format.msg_format3('некоррект: obac "{0}"',lr_baltur_cr.obac));
        end if;
        if (nvl(lr_baltur_cr.dtac, -1) <> 0) then
            raise_application_error(-20000, pkg_format.msg_format3('некоррект: dtac "{0}"',lr_baltur_cr.dtac));
        end if;
        if (nvl(lr_baltur_cr.ctac, -1) <> lr_pst_cr.amnt) then
            raise_application_error(-20000, pkg_format.msg_format3('некоррект: ctac "{0}"',lr_baltur_cr.ctac));
        end if;
    end test_new_credit;

    procedure test_new_debit is
        c_bsaacid_dr constant acc.bsaacid%type := '09876543210987654321';
        c_pod date := '2022-11-30';
        c_amnt number := -1200011;
        lr_baltur_dr baltur%rowtype;
        lr_pst_dr pst%rowtype;
        l_pstid_dr pst.id%type;
        c_amnt_before_dr number := -150;

        procedure init is
        begin
            delete from baltur where bsaacid = c_bsaacid_dr;
            delete from pst where bsaacid = c_bsaacid_dr;
            commit;
        end init;

    begin

        init();

        -- insert into pst
        Insert into PST (POD,VALD,ACC_ID,BSAACID,CCY,AMNT,PBR,INVISIBLE,PCID,NRTL
                ,GLO_REF,EVTP,PROCDATE,DEAL_ID,SUBDEAL_ID,EVT_ID,PMT_REF,NRTE,POST_TYPE)
        values (c_pod, c_pod,0,c_bsaacid_dr,'USD',c_amnt,'CASA','0',974,'МОСБИРЖА',511
                ,null,'2022-11-30',null,null,'1682138913562',null,'NASDAC',2) returning id into l_pstid_dr;
        commit;
        select * into lr_pst_dr from pst where id = l_pstid_dr;

        -- check baltur credit
        select * into lr_baltur_dr from baltur where bsaacid = c_bsaacid_dr;
        if (nvl(lr_baltur_dr.dat, db_conf.c_max_balance_date) <> c_pod) then
            raise_application_error(-20000, pkg_format.msg_format3('некоррект Дт: dat {0} {1}', c_pod,lr_baltur_dr.dat));
        end if;
        if (nvl(lr_baltur_dr.datto, db_conf.c_max_balance_date) <> db_conf.c_max_balance_date) then
            raise_application_error(-20000, pkg_format.msg_format3('некоррект Дт: datto {0}',lr_baltur_dr.datto));
        end if;
        if (nvl(lr_baltur_dr.acc_id, -1) <> lr_pst_dr.acc_id) then
            raise_application_error(-20000, pkg_format.msg_format3('некоррект Дт: acc_id "{0}"',lr_baltur_dr.acc_id));
        end if;
        if (nvl(lr_baltur_dr.datl, db_conf.c_max_balance_date) <> lr_pst_dr.pod) then
            raise_application_error(-20000, pkg_format.msg_format3('некоррект Дт: datl "{0}"',lr_baltur_dr.datl));
        end if;
        if (nvl(lr_baltur_dr.obac, -1) <> 0) then
            raise_application_error(-20000, pkg_format.msg_format3('некоррект Дт: obac "{0}"',lr_baltur_dr.obac));
        end if;
        if (nvl(lr_baltur_dr.dtac, -1) <> lr_pst_dr.amnt) then
            raise_application_error(-20000, pkg_format.msg_format3('некоррект Дт: dtac "{0}"',lr_baltur_dr.dtac));
        end if;
        if (nvl(lr_baltur_dr.ctac, -1) <> 0) then
            raise_application_error(-20000, pkg_format.msg_format3('некоррект Дт: ctac "{0}"',lr_baltur_dr.ctac));
        end if;
        if (nvl(lr_baltur_dr.datl, db_conf.c_max_balance_date) <> c_pod) then
            raise_application_error(-20000, pkg_format.msg_format3('некоррект Дт: datl "{0}"',lr_baltur_dr.datl));
        end if;

        declare
            c_pod_before date := c_pod - 5;
            l_pst_id_dr_before pst.id%type;
            type t_baltur is table of baltur%rowtype;
            lt_baltur t_baltur;
            lr_baltur baltur%rowtype;
        begin
            -- вставляем запись ранее
            Insert into PST (POD,VALD,ACC_ID,BSAACID,CCY,AMNT,PBR,INVISIBLE,PCID,NRTL
                    ,GLO_REF,EVTP,PROCDATE,DEAL_ID,SUBDEAL_ID,EVT_ID,PMT_REF,NRTE,POST_TYPE)
            values (c_pod_before, c_pod_before, 0,c_bsaacid_dr,'USD',c_amnt_before_dr,'CASA','0',974,'МОСБИРЖА',511
                    ,null,'2022-11-30',null,null,'1682138913562',null,'NASDAC',2) returning id into l_pst_id_dr_before;
            commit;

            select * bulk collect into lt_baltur from baltur where bsaacid = c_bsaacid_dr order by dat;
            lr_baltur := lt_baltur(1);
            if (lr_baltur.dat <> c_pod_before) then
                raise_application_error(-20000, pkg_format.msg_format3('некоррект 2 ДТ dat: {0}', lr_baltur.dat));
            end if;
            if (lr_baltur.datto <> c_pod - 1) then
                raise_application_error(-20000, pkg_format.msg_format3('некоррект 2 ДТ datto: {0}', lr_baltur.datto));
            end if;
            if (lr_baltur.obac <> 0) then
                raise_application_error(-20000, pkg_format.msg_format3('некоррект 2 ДТ obac: {0}', lr_baltur.obac));
            end if;
            if (lr_baltur.dtac <> c_amnt_before_dr) then
                raise_application_error(-20000, pkg_format.msg_format3('некоррект 2 ДТ dtac: {0}', lr_baltur.dtac));
            end if;
            if (lr_baltur.ctac <> 0) then
                raise_application_error(-20000, pkg_format.msg_format3('некоррект 2 ДТ ctac: "{0}"', lr_baltur.ctac));
            end if;
            if (nvl(lr_baltur.datl, db_conf.c_max_balance_date) <> c_pod_before) then
                raise_application_error(-20000, pkg_format.msg_format3('некоррект 2 Дт: datl "{0}" "{1}"',lr_baltur.datl, c_pod_before));
            end if;

            lr_baltur := lt_baltur(2);
            if (lr_baltur.dat <> c_pod) then
                raise_application_error(-20000, pkg_format.msg_format3('некоррект 3 ДТ dat: "{0}"', lr_baltur.dat));
            end if;
            if (lr_baltur.datto <> db_conf.c_max_balance_date) then
                raise_application_error(-20000, pkg_format.msg_format3('некоррект 3 ДТ datto: "{0}"', lr_baltur.datto));
            end if;
            if (lr_baltur.obac <> c_amnt_before_dr) then
                raise_application_error(-20000, pkg_format.msg_format3('некоррект 3 ДТ obac: "{0}"', lr_baltur.obac));
            end if;
            if (lr_baltur.dtac <> c_amnt) then
                raise_application_error(-20000, pkg_format.msg_format3('некоррект 3 ДТ dtac: "{0}"', lr_baltur.dtac));
            end if;
            if (lr_baltur.ctac <> 0) then
                raise_application_error(-20000, pkg_format.msg_format3('некоррект 3 ДТ ctac: "{0}"', lr_baltur.ctac));
            end if;
        end;

        declare
            c_pod_btw date := c_pod - 2;
            l_pst_id_dr_before pst.id%type;
            type t_baltur is table of baltur%rowtype;
            lt_baltur t_baltur;
            lr_baltur baltur%rowtype;
            c_amnt_before_dr_2 constant pst.amnt%type := 500;
        begin
            -- вставляем запись между
            Insert into PST (POD,VALD,ACC_ID,BSAACID,CCY,AMNT,PBR,INVISIBLE,PCID,NRTL
                    ,GLO_REF,EVTP,PROCDATE,DEAL_ID,SUBDEAL_ID,EVT_ID,PMT_REF,NRTE,POST_TYPE)
            values (c_pod_btw, c_pod_btw, 0,c_bsaacid_dr,'USD',c_amnt_before_dr_2,'CASA','0',974,'МОСБИРЖА',511
                    ,null,'2022-11-30',null,null,'1682138913562',null,'NASDAC',2) returning id into l_pst_id_dr_before;
            commit;

            select * bulk collect into lt_baltur from baltur where bsaacid = c_bsaacid_dr order by dat;
            if (lt_baltur.count <> 3) then
                raise_application_error(-20000, pkg_format.msg_format3('Некорр кол-во baltur: "{0}"', lt_baltur.count ));
            end if;
            if (lt_baltur(3).obac <> c_amnt_before_dr + c_amnt_before_dr_2) then
                raise_application_error(-20000, pkg_format.msg_format3('Некорр 4 obac: "{0}"', lt_baltur(3).obac));
            end if;
        end;

    end test_new_debit;

end test_pkg_balance;
/

