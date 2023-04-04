-- обработка проводок АЕ перенесена в Java

CREATE OR REPLACE PROCEDURE process_ae
IS
	v_od_phase VARCHAR2(16);
	v_od_prc   VARCHAR2(32);
	v_od   DATE;
	v_from DATE;
	v_i NUMBER := 0;
	v_jobname VARCHAR2(16);
	v_max_concurrency   NUMBER := 1;   -- pkg_prop.get_number_value('ETL_MAX_THREAD_COUNT', 10);
	v_max_processed_pst NUMBER := 100; -- pkg_prop.get_number_value('ETL_MAX_PST_COUNT', 100);
	v_status NUMBER;
	v_cnt NUMBER;
BEGIN
	SELECT curdate, phase, prc INTO v_od, v_od_phase, v_od_prc FROM od;
	IF v_od_phase != 'ONLINE' THEN
		pkg_sys_utl.log_audit_warn('ProcessAE', 'Обработка входящих сообщений невозможна',
			'Текущий опердень '||v_od||' в статусе '||v_od_phase);
		RETURN;
	END IF;

	IF v_od_prc = 'REQUIRED' OR v_od_prc = 'STOPPED' THEN
		pkg_sys_utl.log_audit_warn('ProcessAE', 'Обработка проводок запрещена');
		IF v_od_prc = 'REQUIRED' THEN
			UPDATE od SET prc = 'STOPPED';
			COMMIT;
			pkg_sys_utl.log_audit_warn('ProcessAE', 'Запрошена остановка обработки проводок', 'Обработка остановлена');
		END IF;
		RETURN;
	ELSIF v_od_prc = 'ALLOWED' THEN
		UPDATE od SET prc = 'STARTED';
		COMMIT;
		pkg_sys_utl.log_audit_warn('ProcessAE', 'Запрошен запуск обработки проводок', 'Обработка запущена');
	END IF;

	-- создаем задания на обработку каждой проводки
	--v_od := trunc(sysdate);
	v_from := v_od - 7;
	pkg_sys_utl.log_audit_info('ProcessAE', 'Старт сеанса обработки проводок АЕ '||v_from||'-'||v_od);

	-- создаем очередь сообщений из id проводок, требующих обработки
	dbms_pipe.purge(pipename => 'ae_pst_ids');
	v_cnt := 0;
	FOR nn IN (SELECT id FROM ae_in_pst WHERE (vdate BETWEEN v_from AND v_od) AND ecode is null and rownum <= v_max_processed_pst)
	LOOP
		dbms_pipe.pack_message(nn.id);
        v_status := dbms_pipe.send_message(pipename => 'ae_pst_ids');
        IF v_status != 0 THEN
        	pkg_sys_utl.log_audit_warn('ProcessAE', 'Ошибка передачи сообщения рабочим потокам', 'Статус '||v_status);
        END IF;
		v_cnt := v_cnt + 1;
	END LOOP;

	IF v_cnt > 0 THEN
		-- создаем пул рабочих потоков
		FOR v_i IN 1 .. least(v_cnt, v_max_concurrency)
		LOOP
			v_jobname := 'PRCAE'||to_char(v_i);
			dbms_scheduler.create_job(
				job_name      => v_jobname,
				program_name  => 'prg_prc_ae_from_pipe',
				job_style     => 'IN_MEMORY_FULL',
				start_date    => systimestamp,
				enabled       => true
			);
			pkg_sys_utl.log_audit_info('ProcessAEcr', 'Создан job '||v_jobname);
		END LOOP;

		-- ожидание завершения всех заданий
		v_i := v_max_concurrency;
		WHILE v_i > 0
		LOOP
			dbms_lock.sleep(0.1);
			SELECT count(1) INTO v_i FROM user_scheduler_jobs WHERE job_name LIKE 'PRCAE%' AND job_style='IN_MEMORY_FULL';
			--pkg_sys_utl.log_audit_info('ProcessAE', 'Осталось задач: '||v_i);
		END LOOP;
	END IF;

	pkg_sys_utl.log_audit_info('ProcessAE', 'Сеанс обработки проводок завершен. Обработано '||v_cnt||' проводок');

END process_ae;
/

CREATE OR REPLACE PROCEDURE process_ae_from_pipe
IS
	l_id NUMBER(22,0);
	l_status NUMBER := 0;
	l_od DATE := pkg_currency.get_curdate();
BEGIN
	pkg_sys_utl.log_audit_info('ProcessAE.cr',
		'Запущен job id='||sys_context('USERENV', 'BG_JOB_ID')||' sid='||sys_context('USERENV', 'SID'));
	WHILE l_status = 0 LOOP
		l_status := dbms_pipe.receive_message('ae_pst_ids', 0);
		IF l_status = 0 THEN
			dbms_pipe.unpack_message(l_id);
			process_in_pst(l_id, l_od);
		ELSIF l_status != 1 THEN
			pkg_sys_utl.log_audit_info('ProcessAE.ex',
				'Не удалось получить job id='||sys_context('USERENV', 'BG_JOB_ID')||' status='||l_status);
		END IF;
	END LOOP;
EXCEPTION
	WHEN OTHERS THEN
		pkg_sys_utl.log_audit_error('ProcessAE', 'Нижнеуровневая ошибка при обработке проводки '||l_id,
			sqlerrm, dbms_utility.format_error_backtrace);
END;
/
