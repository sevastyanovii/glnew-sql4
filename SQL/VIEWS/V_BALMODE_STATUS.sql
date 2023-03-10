-- представление используется для вычисления текущего режима расчета остатков
CREATE OR REPLACE VIEW v_balmode_status AS
SELECT current_form current_mode
       ,
       /**проверка кол-ва включенных триггеров в соответствие с режимом*/
       CASE WHEN current_form = aq_pkg_const.get_const_trigger_form_gibrid THEN
                CASE WHEN cnt_trg = 1 THEN 'OK' ELSE 'ERROR' END
            WHEN current_form = aq_pkg_const.get_const_trigger_form_online THEN
                CASE WHEN cnt_trg = 3 THEN 'OK' ELSE 'ERROR' END
       END mode_status,
       /**Внимание!!! не должны быть отновременно включены режим ONLINE и GIBRID*/
       decode(cnt_enabled_modes, 1, 'OK', 'ERROR') mode_status_cnt
    FROM (
        SELECT count(1) cnt_trg, form current_form
          FROM v_balmode_trg
         WHERE status = 'ENABLED'
           AND form IN (aq_pkg_const.get_const_trigger_form_gibrid, aq_pkg_const.get_const_trigger_form_online)
        GROUP BY form
    ) v1,
    (
        SELECT count(distinct form) cnt_enabled_modes
          FROM v_balmode_trg
         WHERE status = 'ENABLED'
           AND form IN (aq_pkg_const.get_const_trigger_form_gibrid, aq_pkg_const.get_const_trigger_form_online)
    ) v2;
