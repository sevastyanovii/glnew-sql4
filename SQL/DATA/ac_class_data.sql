DELETE FROM ac_class;

INSERT INTO ac_class (class, class_name, dtb) VALUES ('20200',  'Депозиты до востребования', to_date('2022-06-01', 'yyyy-mm-dd'));
INSERT INTO ac_class (class, class_name, dtb) VALUES ('20203',  'Депозиты до востребования бюджетных организаций республиканского подчинения по внебюджетным средствам', to_date('2022-06-01', 'yyyy-mm-dd'));
INSERT INTO ac_class (class, class_name, dtb) VALUES ('20204',  'Депозиты до востребования бюджетных организаций местного подчинения по внебюджетным средствам', to_date('2022-06-01', 'yyyy-mm-dd'));
INSERT INTO ac_class (class, class_name, dtb) VALUES ('20400',  'Сберегательные депозиты', to_date('2022-06-01', 'yyyy-mm-dd'));
INSERT INTO ac_class (class, class_name, dtb) VALUES ('20403',  'Сберегательные депозиты бюджетных организаций республиканского подчинения по внебюджетным средствам', to_date('2022-06-01', 'yyyy-mm-dd'));
INSERT INTO ac_class (class, class_name, dtb) VALUES ('20404',  'Сберегательные депозиты бюджетных организаций местного подчинения по внебюджетным средствам', to_date('2022-06-01', 'yyyy-mm-dd'));
INSERT INTO ac_class (class, class_name, dtb) VALUES ('NOSTRO', 'К получению с корреспондентских счетов – Ностро', to_date('2022-06-01', 'yyyy-mm-dd'));
INSERT INTO ac_class (class, class_name, dtb) VALUES ('20814',  'Средства к уплате в ЦБ - Система быстрых платежей', to_date('2022-06-01', 'yyyy-mm-dd'));
INSERT INTO ac_class (class, class_name, dtb) VALUES ('10313',  'Средства к получению от ЦБ - Система быстрых платежей', to_date('2022-06-01', 'yyyy-mm-dd'));
INSERT INTO ac_class (class, class_name, dtb) VALUES ('20816',  'Средства, причитающиеся ЦБ - клиринговая система ЦБ', to_date('2022-06-01', 'yyyy-mm-dd'));
INSERT INTO ac_class (class, class_name, dtb) VALUES ('10315',  'Средства к получению от ЦБ - клиринговая система ЦБ', to_date('2022-06-01', 'yyyy-mm-dd'));
INSERT INTO ac_class (class, class_name, dtb) VALUES ('29801S', 'Расчеты с клиентами по платежам SWIFT', to_date('2022-06-01', 'yyyy-mm-dd'));
