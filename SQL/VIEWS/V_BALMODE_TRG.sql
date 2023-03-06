CREATE OR REPLACE VIEW v_balmode_trg AS
SELECT trigger_name,
       CASE
            WHEN trigger_name IN ('PSTAD', 'PSTAI', 'PSTAU') THEN aq_pkg_const.get_const_trigger_form_online
            WHEN trigger_name IN ('AQ_TRG_PST') THEN aq_pkg_const.get_const_trigger_form_gibrid
            ELSE 'OTHER'
       END form, status
  FROM user_triggers
 WHERE table_name = 'PST';

