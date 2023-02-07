CREATE OR REPLACE TRIGGER trg_cbbs_bi BEFORE INSERT ON cbbs FOR EACH ROW
DECLARE
BEGIN
	IF (:new.acc2 IS NOT null) THEN
	    IF (:new.acc0 IS null) THEN
	        :new.acc0 := substr(:new.acc2, 1, 1);
	    END if;
	    IF (:new.lvl is null) THEN
	        :new.lvl := CASE WHEN substr(:new.acc2, 2, 4) = '0000' THEN '0'
	                           WHEN substr(:new.acc2, 4, 2) = '00' THEN '1'
	                           ELSE '2' END;
	    END if;
	END if;
END trg_cbbs_bi;
/
