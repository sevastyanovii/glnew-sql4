BEGIN
	dbms_scheduler.create_program(
		'prg_prc_ae_from_pipe',  -- program_name
		'STORED_PROCEDURE',      -- program_type
		'process_ae_from_pipe',  -- program_action
		0,                       -- number_of_arguments
		true,                    -- enabled);
END;
/

BEGIN
	dbms_scheduler.create_job(
		job_name   => aq_pkg_const.get_balance_queue_listnr_prfx()||'01',
		job_type   => 'PLSQL_BLOCK',
		job_action => 'BEGIN aq_pkg.start_deq(''BAL_QUEUE'', 5, 5); END;',
		start_date => systimestamp,
		repeat_interval => 'freq=secondly;interval=1',
		end_date   => systimestamp + 1,
		store_output => false,
		enabled    => true);
	dbms_scheduler.create_job(
		job_name   => aq_pkg_const.get_balance_queue_listnr_prfx()||'02',
		job_type   => 'PLSQL_BLOCK',
		job_action => 'BEGIN aq_pkg.start_deq(''BAL_QUEUE'', 5, 5); END;',
		start_date => systimestamp,
		repeat_interval => 'freq=secondly;interval=1',
		end_date   => systimestamp + 1,
		enabled    => true);
	dbms_scheduler.create_job(
		job_name   => 'CHECK_ERROR_QUEUE',
		job_type   => 'PLSQL_BLOCK',
		job_action => 'BEGIN aq_pkg_utl.check_error_queue; END;',
		start_date => systimestamp,
		repeat_interval => 'freq=minutely;interval=10',
		end_date   => systimestamp + 1,
		store_output => false,
		enabled    => true);
END;
/

BEGIN
	dbms_scheduler.create_job(
		job_name   => 'AE_PROCESS_JOB',
		job_type   => 'PLSQL_BLOCK',
		job_action => 'BEGIN process_ae; END;',
		start_date => systimestamp,
		repeat_interval => 'freq=secondly;interval=15',
		end_date   => systimestamp + 1,
		store_output => false,
		enabled    => true);
END;
/
