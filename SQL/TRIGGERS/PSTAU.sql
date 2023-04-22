CREATE OR REPLACE TRIGGER pstau
	AFTER UPDATE OF invisible, amnt, ccy, bsaacid, pod ON pst
	REFERENCES old AS orow new AS nrow FOR EACH ROW
DECLARE
    curdtac NUMBER(19, 0);
    curdtbc NUMBER(19, 0);
    curctac NUMBER(19, 0);
    curctbc NUMBER(19, 0);

    ncurdtac NUMBER(19, 0);
    ncurdtbc NUMBER(19, 0);
    ncurctac NUMBER(19, 0);
    ncurctbc NUMBER(19, 0);

    btdatl  DATE;
    btdat   DATE;
    btdatto DATE;
    btbsaacid CHAR(20);
    btobac  NUMBER(19, 0);
    btobbc  NUMBER(19, 0);

    cur_acc_id NUMBER(22, 0) := null;
BEGIN
    -- изменилась только сумма проводки
	IF (:nrow.invisible <> '1' AND :nrow.pod = :orow.pod AND :nrow.bsaacid = :orow.bsaacid AND
		:nrow.invisible = :orow.invisible) THEN

		IF :orow.amnt >= 0 THEN
            curdtac := 0;
            curdtbc := 0;
            curctac := :orow.amnt;
            curctbc := :orow.amnt;
		ELSIF :orow.amnt < 0 THEN
            curdtac := :orow.amnt;
            curdtbc := :orow.amnt;
            curctac := 0;
            curctbc := 0;
		END IF;

		IF :nrow.amnt >= 0 THEN
            ncurdtac := 0;
            ncurdtbc := 0;
            ncurctac := :nrow.amnt;
            ncurctbc := :nrow.amnt;
		ELSIF :nrow.amnt < 0 THEN
            ncurdtac := :nrow.amnt;
            ncurdtbc := :nrow.amnt;
            ncurctac := 0;
            ncurctbc := 0;
		END IF;

		-- корректируем остатки и обороты всех интервалов, начиная с того, в который попадает проводка
		UPDATE baltur
		   SET
		       obac = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.obac ELSE baltur.obac + (ncurctac + ncurdtac - curctac - curdtac) END),
			   obbc = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.obbc ELSE baltur.obbc + (ncurctbc + ncurdtbc - curctbc - curdtbc) END),
			   dtac = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.dtac + ncurdtac - curdtac ELSE baltur.dtac END),
			   dtbc = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.dtbc + ncurdtbc - curdtbc ELSE baltur.dtbc END),
			   ctac = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.ctac + ncurctac - curctac ELSE baltur.ctac END),
			   ctbc = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.ctbc + ncurctbc - curctbc ELSE baltur.ctbc END)
		 WHERE baltur.datto >= :nrow.pod AND baltur.bsaacid = :nrow.bsaacid;
    elsif (:nrow.invisible = '1' and :orow.invisible <> '1') then
        declare
            diff_dtac pst.amnt%type := 0;
            diff_dtbc pst.amnt%type := 0;
            diff_ctac pst.amnt%type := 0;
            diff_ctbc pst.amnt%type := 0;
        begin
            -- подавлена
            IF :orow.amnt >= 0 THEN
                diff_dtac := 0;
                diff_dtbc := 0;
                diff_ctac := :orow.amnt;
                diff_ctbc := :orow.amnt;
            ELSIF :nrow.amnt < 0 THEN
                diff_dtac := :nrow.amnt;
                diff_dtbc := :nrow.amnt;
                diff_ctac := 0;
                diff_ctbc := 0;
            END IF;

            UPDATE baltur
               SET
                   obac = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.obac ELSE baltur.obac - diff_dtac - diff_ctac  END),
                   obbc = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.obbc ELSE baltur.obbc - diff_dtbc - diff_ctbc END),
                   dtac = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.dtac - diff_dtac ELSE baltur.dtac END),
                   dtbc = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.dtbc - diff_dtbc ELSE baltur.dtbc END),
                   ctac = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.ctac - diff_ctac ELSE baltur.ctac END),
                   ctbc = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.ctbc - diff_ctbc ELSE baltur.ctbc END)
             WHERE baltur.datto >= :nrow.pod AND baltur.bsaacid = :nrow.bsaacid;
        end;
	ELSE
		-- изменились существенные параметры проводки - возможно, нужно менять две цепочки состаков
		IF :orow.amnt >= 0 THEN
            curdtac := 0;
            curdtbc := 0;
            curctac := :orow.amnt;
            curctbc := :orow.amnt;
		ELSIF :orow.amnt < 0 THEN
            curdtac := :orow.amnt;
            curdtbc := :orow.amnt;
            curctac := 0;
            curctbc := 0;
		END IF;

		-- если проводка не была подавлена до изменения, корректируем цепочку остатков, как если бы проводку удалили
		-- (по "старому" счету проводки)
		IF :orow.invisible <> '1' THEN
			UPDATE baltur
			   SET
			       obac = (CASE WHEN baltur.dat = :orow.pod THEN baltur.obac ELSE baltur.obac - (curctac + curdtac) END),
				   obbc = (CASE WHEN baltur.dat = :orow.pod THEN baltur.obbc ELSE baltur.obbc - (curctbc + curdtbc) END),
				   dtac = (CASE WHEN baltur.dat = :orow.pod THEN baltur.dtac - curdtac ELSE baltur.dtac END),
				   dtbc = (CASE WHEN baltur.dat = :orow.pod THEN baltur.dtbc - curdtbc ELSE baltur.dtbc END),
				   ctac = (CASE WHEN baltur.dat = :orow.pod THEN baltur.ctac - curctac ELSE baltur.ctac END),
				   ctbc = (CASE WHEN baltur.dat = :orow.pod THEN baltur.ctbc - curctbc ELSE baltur.ctbc END)
			 WHERE baltur.dat >= :orow.pod AND baltur.bsaacid = :orow.bsaacid;
		END IF;

		-- если проводка не подавлена, выполняем те же действия, что и при вставке проводки
		IF :nrow.invisible <> '1' THEN
			IF (:nrow.amnt >= 0) THEN
                curdtac := 0; curdtbc := 0;
                curctac := :nrow.amnt; curctbc := :nrow.amnt;
			ELSIF (:nrow.amnt < 0) THEN
                curdtac := :nrow.amnt; curdtbc := :nrow.amnt;
                curctac := 0; curctbc := 0;
			END IF;

			-- ищем последний интервал баланса по счету
            BEGIN
                SELECT baltur.dat, baltur.datto, baltur.datl, baltur.bsaacid,
                       (CASE WHEN baltur.dat = :nrow.pod THEN baltur.obac ELSE baltur.obac + (baltur.ctac + baltur.dtac) END),
                       (CASE WHEN baltur.dat = :nrow.pod THEN baltur.obbc ELSE baltur.obbc + (baltur.ctbc + baltur.dtbc) END)
                       INTO btdat, btdatto, btdatl, btbsaacid, btobac, btobbc
                  FROM baltur WHERE baltur.datto = to_date('01.01.2100', 'DD.MM.YYYY')
                       AND baltur.bsaacid = :nrow.bsaacid FOR UPDATE NOWAIT;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    btdat := null; btdatto := null; btdatl := null; btbsaacid := null; btobac := null; btobbc := null;
            END;

            btdatl := :nrow.pod;

    		IF (btbsaacid IS null) THEN
    			-- нет данных по остаткам - добавляем интервал
				INSERT INTO baltur (dat, datto, datl, acc_id, bsaacid, dtac, dtbc, ctac, ctbc)
				     VALUES (:nrow.pod, to_date('01.01.2100', 'DD.MM.YYYY'), btdatl, cur_acc_id,
				     	    :nrow.bsaacid, curdtac, curdtbc, curctac, curctbc);

			ELSIF (btdat = :nrow.pod) THEN
				-- последний интервал баланса совпадает с днем обрабатываемой проводки - просто корректируем обороты
				UPDATE baltur
				   SET datl = (CASE WHEN (baltur.datl IS null) OR baltur.datl < btdatl THEN btdatl ELSE baltur.datl END),
					   dtac = baltur.dtac + curdtac,
					   dtbc = baltur.dtbc + curdtbc,
					   ctac = baltur.ctac + curctac,
					   ctbc = baltur.ctbc + curctbc
				 WHERE baltur.dat = :nrow.pod AND baltur.bsaacid = :nrow.bsaacid;

			ELSIF btdat < :nrow.pod THEN
			    -- последний интервал начинается раньше даты проводки - меняем у него конечную дату и добавляем новый конечный интревал
				UPDATE baltur
				   SET datto = :nrow.pod - 1
				 WHERE baltur.dat = btdat AND baltur.bsaacid = :nrow.bsaacid;

				INSERT INTO baltur (dat, datto, datl, acc_id, bsaacid, obac, obbc, dtac, dtbc, ctac, ctbc)
				     VALUES (:nrow.pod, btdatto, btdatl, cur_acc_id, :nrow.bsaacid, btobac, btobbc, curdtac, curdtbc, curctac, curctbc);

			ELSIF (btdat > :nrow.pod) THEN
				-- последний интервал начинается позже даты проводки, ищем актуальный интервал для этой даты
			    BEGIN
                    SELECT baltur.dat, baltur.datto, baltur.datl, baltur.bsaacid,
                           (CASE WHEN baltur.dat = :nrow.pod THEN baltur.obac ELSE baltur.obac + (baltur.ctac + baltur.dtac) END),
                           (CASE WHEN baltur.dat = :nrow.pod THEN baltur.obbc ELSE baltur.obbc + (baltur.ctbc + baltur.dtbc) END)
                           INTO btdat, btdatto, btdatl, btbsaacid, btobac, btobbc
                      FROM baltur
                    WHERE (baltur.dat <= :nrow.pod AND :nrow.pod <= baltur.datto)
                          AND baltur.bsaacid = :nrow.bsaacid FOR UPDATE NOWAIT;
			    EXCEPTION
			        WHEN NO_DATA_FOUND THEN
                        btdat := null; btdatto := null; btdatl := null; btbsaacid := null; btobac := null; btobbc := null;
			    END;

				IF (btbsaacid IS null) THEN
		            -- не нашли подходящий интервал, значит дата проводки раньше начала ведения баланса по счету
		            -- создаем новый первый интервал баланса и корректируем остатки у всех последующих интервалов
					SELECT min(baltur.dat) INTO btdat
					  FROM baltur WHERE baltur.bsaacid = :nrow.bsaacid;

					IF btdat IS null THEN
						btdatto := to_date('01.01.2100', 'DD.MM.YYYY');
					ELSE
						btdatto := btdat - 1;
					END IF;

					INSERT INTO baltur (dat, datto, datl, acc_id, bsaacid, obac, obbc, dtac, dtbc, ctac, ctbc)
					     VALUES (:nrow.pod, btdatto, btdatl, cur_acc_id, :nrow.bsaacid, 0, 0,
					     	    curdtac, curdtbc, curctac, curctbc);

					UPDATE baltur
					   SET datl = (CASE WHEN (baltur.datl IS null) OR baltur.datl < btdatl THEN btdatl ELSE baltur.datl END),
						   obac = baltur.obac + (curctac + curdtac),
						   obbc = baltur.obbc + (curctbc + curdtbc)
					 WHERE baltur.dat > :nrow.pod AND baltur.bsaacid = :nrow.bsaacid;

				ELSIF btdat < :nrow.pod THEN
					-- дата проводки попадает в найденный интервал - делим его на два, и корректируем остатки у всех последующих интервалов
					UPDATE baltur SET datto = :nrow.pod  - 1
					 WHERE baltur.dat = btdat AND baltur.bsaacid = :nrow.bsaacid;

					INSERT INTO baltur (dat, datto, datl, acc_id, bsaacid, obac, obbc, dtac, dtbc, ctac, ctbc)
					     VALUES (:nrow.pod, btdatto, btdatl, cur_acc_id, :nrow.bsaacid,
					     	    btobac, btobbc, curdtac, curdtbc, curctac, curctbc);

					UPDATE baltur
					SET datl = (CASE WHEN (baltur.datl IS null) OR baltur.datl < btdatl THEN btdatl ELSE baltur.datl END),
						obac = baltur.obac + (curctac + curdtac),
						obbc = baltur.obbc + (curctbc + curdtbc)
					WHERE baltur.dat > :nrow.pod AND baltur.bsaacid = :nrow.bsaacid;
				ELSIF btdat = :nrow.pod THEN
					-- дата проводки совпадает с началом найденного интервала
            		-- корректируем остатки и обороты всех интервалов, начиная с этого
					UPDATE baltur
					SET datl = (CASE WHEN (baltur.datl IS null) OR baltur.datl < btdatl THEN btdatl ELSE baltur.datl END),
						obac = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.obac ELSE baltur.obac + (curctac + curdtac) END),
						obbc = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.obbc ELSE baltur.obbc + (curctbc + curdtbc) END),
						dtac = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.dtac + CURDTAC ELSE baltur.dtac END),
						dtbc = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.dtbc + CURDTBC ELSE baltur.dtbc END),
						ctac = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.ctac + CURCTAC ELSE baltur.ctac END),
						ctbc = (CASE WHEN baltur.dat = :nrow.pod THEN baltur.ctbc + CURCTBC ELSE baltur.ctbc END)
					WHERE baltur.dat >= btdat AND baltur.bsaacid = :nrow.bsaacid;
				END IF;
			END IF;
		END IF;
	END IF;
END ;
/
