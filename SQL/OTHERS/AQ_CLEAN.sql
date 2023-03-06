-- скрипт для удаления очереди AQ
declare
    l_qe_nf exception;
    pragma exception_init(l_qe_nf, -24010);
begin
    dbms_aqadm.stop_queue('BAL_QUEUE');
exception when l_qe_nf then null;
end;
/

declare
    l_qe_nf exception;
    pragma exception_init(l_qe_nf, -24010);
begin
    DBMS_AQADM.DROP_QUEUE('BAL_QUEUE');
exception when l_qe_nf then null;
end;
/

declare
    l_qet_nf exception;
    pragma exception_init(l_qet_nf, -24002);
begin
    DBMS_AQADM.DROP_QUEUE_TABLE('BAL_QUEUE_TAB', true);
exception when l_qet_nf then null;
end;
/

declare
    l_obj_nf exception;
    pragma exception_init(l_obj_nf, -04043);
begin
    execute immediate 'drop type body GLAQ_TYPE';
exception when l_obj_nf then null;
end;
/

declare
    l_obj_nf exception;
    pragma exception_init(l_obj_nf, -04043);
begin
    execute immediate 'drop type GLAQ_TYPE force';
exception when l_obj_nf then null;
end;
/