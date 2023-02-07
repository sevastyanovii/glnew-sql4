-- остановка запущенных задач с сохранением состояния
declare
    e_notstarted exception;
    pragma exception_init(e_notstarted, -27366);

    procedure clean_sched is
        pragma autonomous_transaction;
    begin
        delete from install_job where chk = 'RESTORED';
        commit;
    end clean_sched;

    procedure create_sched(a_job_name varchar2, a_state varchar2) is
        pragma autonomous_transaction;
    begin
        begin
            insert into install_job (job_name, state,chk) values (a_job_name, a_state, 'SAVED');
        exception
            when dup_val_on_index then
                update install_job t set ts = systimestamp where t.job_name = a_job_name;
                dbms_output.put_line('Saved job '||a_job_name||' is found. Timestamp is updated now');
        end;
        commit;
    end create_sched;

begin
    clean_sched();
    for nn in (select * from user_scheduler_jobs where ENABLED = 'TRUE') loop
        create_sched(nn.job_name, nn.state);
        dbms_scheduler.disable(nn.job_name, true);
        dbms_output.put_line('Disabled job: '||nn.job_name);
        begin
            dbms_scheduler.stop_job(nn.job_name, true);
            dbms_output.put_line('Stopped job with force option: '||nn.job_name);
        exception
            when e_notstarted then null;
        end;
    end loop;
end;
/
