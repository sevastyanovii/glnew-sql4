BEGIN
	db_conf.drop_job_if_exists('BALANCE_QUEUE_LISTENER02');
	db_conf.drop_job_if_exists('BALANCE_QUEUE_LISTENER01');
	db_conf.drop_job_if_exists('CHECK_ERROR_QUEUE');
	db_conf.drop_job_if_exists('AE_PROCESS_JOB');
	db_conf.drop_program_if_exists('PRG_PRC_AE_FROM_PIPE');
END;
/
