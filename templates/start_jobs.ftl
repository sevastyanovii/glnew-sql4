-- восстановление заданий по сохраненному состоянию
declare
    function restore_job(a_job_name varchar2) return boolean is
        pragma autonomous_transaction;
        l_res boolean := false;
    begin
        declare
            l_nf exception;
            l_nf2 exception;
            pragma exception_init(l_nf, -27475);
            pragma exception_init(l_nf2, -27476);
        begin
            dbms_scheduler.enable(a_job_name);
            l_res := true;
        exception
            when l_nf then
                dbms_output.put_line('WARNING: error on enabling job '||a_job_name||': '||sqlerrm);
                l_res := false;
            when l_nf2 then
                dbms_output.put_line('WARNING: error on enabling job '||a_job_name||': '||sqlerrm);
                l_res := false;
        end;
        update install_job t set chk = 'RESTORED' where t.job_name = a_job_name;
        commit;
        return l_res;
    end restore_job;
begin
    for nn in (select * from install_job where chk = 'SAVED') loop
        if (restore_job(nn.job_name)) then
          dbms_output.put_line('Enabled job: '||nn.job_name);
        end if;
    end loop;
end;
/
