CREATE OR REPLACE PROCEDURE process_in_pst(p_id NUMBER, p_od DATE)
IS
	l_gloid    NUMBER(22,0);
	l_d_pst_id NUMBER(22,0);
	l_ecode    NUMBER;
	l_a1   CHAR(1);
	l_a2   CHAR(1);
	l_a3   CHAR(1);
	l_err  VARCHAR2(4000);

	l_d_rate  NUMBER(15,9); -- Официальный курс ЦБ для валюты по дебету
	l_d_amnt  NUMBER(19,3); -- Сумма проводки по дебетуемому счету
	l_d_nbdp  NUMBER(10,0); -- Десятичный логарифм числа минорных единиц в номинальной для валюты дебета
	l_d_eqv   NUMBER(19,3); -- Расчетный эквивалент валюты локализации для суммы дебета

	l_c_rate  NUMBER(15,9); -- Официальный курс ЦБ для валюты по кредиту
	l_c_amnt  NUMBER(19,3); -- Сумма проводки по кредитовому счету
	l_c_nbdp  NUMBER(10,0); -- Десятичный логарифм числа минорных единиц в номинальной для валюты кредита
	l_c_eqv   NUMBER(19,3); -- Расчетный эквивалент валюты локализации для суммы кредита

	l_nbdp_lc NUMBER(10,0); -- Десятичный логарифм числа минорных единиц в номинальной для основной валюты
BEGIN
	pkg_sys_utl.log_audit_info('ProcessAE', 'Старт обработки проводки '||p_id);

	-- verifying posting
	SELECT
	    ecode,
		CASE WHEN (ac_cr = ac_dr AND amt_cr != amt_dr) THEN '1' ELSE '0' END,
		CASE WHEN adr.ccy IS null THEN '2' WHEN (p.ccy_dr <> adr.ccy) THEN '3' ELSE '0' END,
		CASE WHEN acr.ccy IS null THEN '4' WHEN (p.ccy_cr <> acr.ccy) THEN '5' ELSE '0' END,
		p.amt_dr,
		pkg_currency.get_rate(p.ccy_dr, p_od),
		pkg_currency.get_nbdp(p.ccy_dr),
		p.amt_cr,
		pkg_currency.get_rate(p.ccy_cr, p_od),
		pkg_currency.get_nbdp(p.ccy_cr)
	  INTO l_ecode, l_a1, l_a2, l_a3, l_d_amnt, l_d_rate, l_d_nbdp, l_c_amnt, l_c_rate, l_c_nbdp
	  FROM ae_in_pst p
		   LEFT JOIN acc adr ON adr.bsaacid = p.ac_dr AND p_od BETWEEN adr.dto AND nvl(adr.dtc, p_od)
		   LEFT JOIN acc acr ON acr.bsaacid = p.ac_cr AND p_od BETWEEN acr.dto AND nvl(acr.dtc, p_od)
	 WHERE id = p_id;

	IF l_ecode IS NOT null THEN
		pkg_sys_utl.log_audit_info('ProcessAE', 'Проводка '||p_id||' уже была обработана ранее');
		RETURN;
	END IF;

	IF l_a1 != '0' OR l_a2 != '0' OR l_a3 != '0' OR l_d_amnt = 0 OR l_c_amnt = 0
	               OR l_d_rate IS null OR l_d_nbdp IS null OR l_c_rate IS null OR l_c_nbdp IS null THEN
		l_err := (CASE l_a1 WHEN '1' THEN 'Суммы по дебету и кредиту не равны;'||chr(10) ELSE '' END)
			||  (CASE l_a2 WHEN '2' THEN 'Не найден подходящий дебетовый счет;'||chr(10)
			               WHEN '3' THEN 'Код валюты дебета не соответствует валюте счета;'||chr(10) ELSE '' END)
			||  (CASE l_a3 WHEN '4' THEN 'Не найден подходящий кредитный счет;'||chr(10)
				           WHEN '5' THEN 'Код валюты кредита не соответствует валюте счета;'||chr(10) ELSE '' END)
			||  (CASE WHEN l_d_amnt = 0 THEN 'Сумма по дебету равна нулю;'||chr(10) ELSE '' END)
			||  (CASE WHEN l_c_amnt = 0 THEN 'Сумма по дебету равна нулю;'||chr(10) ELSE '' END)
			||  (CASE WHEN l_d_nbdp IS null THEN 'Не найдена валюта по дебету;'||chr(10) ELSE '' END)
			||  (CASE WHEN l_c_nbdp IS null THEN 'Не найдена валюта по кредиту;'||chr(10) ELSE '' END)
			||  (CASE WHEN l_d_rate IS null THEN 'Не найден курс валюты по дебету;'||chr(10) ELSE '' END)
			||  (CASE WHEN l_c_rate IS null THEN 'Не найден курс валюты по кредиту;'||chr(10) ELSE '' END);

		UPDATE ae_in_pst SET ecode = 1, emsg = l_err WHERE id = p_id;

		pkg_sys_utl.log_audit_error('ProcessAE', 'Проводка '||p_id||' обработана с ошибкой валидации, операция не создана',
			l_err);

		COMMIT;
		RETURN;
	END IF;

	l_nbdp_lc := pkg_currency.get_nbdp_lc();
	l_d_eqv := round(l_d_amnt * l_d_rate, l_nbdp_lc);
	l_c_eqv := round(l_c_amnt * l_c_rate, l_nbdp_lc);

	BEGIN -- try {1}
		-- создание операции

		SELECT OPERATION_SEQ.nextval INTO l_gloid FROM dual;

		INSERT INTO operation (
			-- Поля регистрации операции
			gloid, id_pst, src_pst, inp_method, evt_id, evtp, deal_id, subdeal_id, pmt_ref,
			-- Даты операции
			vdate, ots, postdate, procdate,
			-- Поля описания
			nrte, nrtl,
			-- Параметры сторнирующей операции
			strn, strn_ref,
			-- Параметры регистрации полупроводки по дебету
			ac_dr, ccy_dr, amt_dr,
			-- Расчетные параметры полупроводки по дебету
			rate_dr,
			eqv_dr,
			-- Параметры регистрации полупроводки по кредиту
			ac_cr, ccy_cr, amt_cr,
			-- Расчетные параметры кредитовой полупроводки
			rate_cr,
			eqv_cr,
			-- Связь с проводками
			pst_scheme, state,
			-- Ключи открытия/поиска счета
			acckey_dr, acckey_cr)
		SELECT
			-- Поля регистрации операции
			l_gloid, p.id, p.src_pst, 'AE', p.evt_id, p.evtp, p.deal_id, p.subdeal_id, p.pmt_ref,
			-- Даты операции
			p.vdate, p.ots, p_od, p_od,
			-- Поля описания
			p.nrte, p.nrtl,
			-- Параметры сторнирующей операции
			p.strn, p.strnrf,
			-- Параметры регистрации полупроводки по дебету
			p.ac_dr, p.ccy_dr, p.amt_dr,
			-- Расчетные параметры полупроводки по дебету
			l_d_rate,
			l_d_eqv,
			-- Параметры регистрации полупроводки по дебету
			p.ac_cr, p.ccy_cr, p.amt_cr,
			-- Расчетные параметры кредитовой полупроводки
			l_c_rate,
			l_c_eqv,
			-- Связь с проводками
			'S', 'LOAD',
			-- Ключи открытия/поиска счета
			p.acckey_dr, p.acckey_cr
		  FROM ae_in_pst p WHERE id = p_id;

		UPDATE ae_in_pst SET ecode = 0 WHERE id = p_id;
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			l_err := sqlerrm;
			pkg_sys_utl.log_audit_error('ProcessAE', 'Нижнеуровневая ошибка при создании операции по проводке '||p_id,
				l_err, dbms_utility.format_error_backtrace);
			UPDATE ae_in_pst SET ecode = 1, emsg = l_err WHERE id = p_id;
			COMMIT;
	END; -- try{1}

	-- creating psts
	BEGIN -- try {2}
		-- создание дебетной полупроводки
		SELECT pst_seq.nextval INTO l_d_pst_id FROM dual;

		INSERT INTO pst (
			id, pod, vald, bsaacid, ccy,
			amnt,
			amntlc,
			pbr, invisible, pcid, nrtl, nrte,
			glo_ref, evtp, procdate,
			deal_id, subdeal_id, evt_id, pmt_ref)
		SELECT
			l_d_pst_id, o.postdate, o.vdate, o.ac_dr, o.ccy_dr,
			-o.amt_dr * power(10, l_d_nbdp),
			-o.eqv_dr * power(10, l_nbdp_lc),
			o.src_pst, 0, l_d_pst_id, o.nrtl, o.nrte,
			o.gloid, o.evtp, o.procdate,
			o.deal_id, o.subdeal_id, o.evt_id, o.pmt_ref
		  FROM operation o WHERE  gloid = l_gloid;

		-- создание кредитной полупроводки
		INSERT INTO pst (
			pod, vald, bsaacid, ccy,
			amnt,
			amntlc,
			pbr, invisible, pcid, nrtl, nrte,
			glo_ref, evtp, procdate,
			deal_id, subdeal_id, evt_id, pmt_ref)
		SELECT
			o.postdate, o.vdate, o.ac_cr, o.ccy_cr,
			o.amt_cr * power(10, l_c_nbdp),
			o.eqv_cr * power(10, l_nbdp_lc),
			o.src_pst, 0, l_d_pst_id, o.nrtl, o.nrte,
			o.gloid, o.evtp, o.procdate,
			o.deal_id, o.subdeal_id, o.evt_id, o.pmt_ref
		  FROM operation o WHERE  gloid = l_gloid;

		UPDATE operation SET state = 'POST' WHERE gloid = l_gloid;
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			l_err := sqlerrm;
			pkg_sys_utl.log_audit_error('ProcessAE',
				'Нижнеуровневая ошибка при создании полупроводок по проводке '||p_id||', операция '||l_gloid,
				l_err, dbms_utility.format_error_backtrace);
			UPDATE operation SET state = 'ERPST', emsg = l_err WHERE gloid = l_gloid;
			COMMIT;
	END; -- try{2}

	pkg_sys_utl.log_audit_info('ProcessAE', 'Конец обработки проводки '||p_id);
END;
/

/*
BEGIN
	dbms_scheduler.create_program(
		'prg_prc_ae',       -- program_name
		'STORED_PROCEDURE', -- program_type
		'process_in_pst',   -- program_action
		2,                  -- number_of_arguments
		false,              -- enabled
		null);              -- comments
	dbms_scheduler.define_program_argument('prg_prc_ae', 1, 'p_id', 'NUMBER');
	dbms_scheduler.define_program_argument('prg_prc_ae', 2, 'p_od', 'DATE');
	dbms_scheduler.enable('prg_prc_ae');
END;
/
	FOR v_i IN 1 .. v_max_concurrency
	LOOP
		v_jobname := 'PRCAE'||to_char(v_i);
		dbms_scheduler.create_job(
			job_name      => v_jobname,
			program_name  => 'prg_prc_ae',
			job_style     => 'IN_MEMORY_FULL',
			start_date    => systimestamp,
			enabled       => false
		);
		dbms_scheduler.set_job_anydata_value(v_jobname, 1, anydata.ConvertNumber(nn.id));
		dbms_scheduler.set_job_anydata_value(v_jobname, 2, anydata.ConvertDate(v_od));
		dbms_scheduler.enable(v_jobname);
	END LOOP;
*/
