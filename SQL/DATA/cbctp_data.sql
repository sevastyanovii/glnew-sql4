DELETE FROM cbctp;

--INSERT INTO cbctp (ctype,name,prcd) VALUES ('00', 'Любые типы клиентов', null);
INSERT INTO cbctp (ctype, name, prcd, dtb) VALUES ('01', 'Правительство','G', to_date('2022-06-01', 'yyyy-mm-dd'));
INSERT INTO cbctp (ctype, name, prcd, dtb) VALUES ('02', 'Государственные организации и предприятия','C', to_date('2022-06-01', 'yyyy-mm-dd'));
INSERT INTO cbctp (ctype, name, prcd, dtb) VALUES ('03', 'Негосударственные некоммерческие организации','C', to_date('2022-06-01', 'yyyy-mm-dd'));
INSERT INTO cbctp (ctype, name, prcd, dtb) VALUES ('04', 'Небанковские финансовые институты','C', to_date('2022-06-01', 'yyyy-mm-dd'));
INSERT INTO cbctp (ctype, name, prcd, dtb) VALUES ('05', 'Другие типы клиентов','C', to_date('2022-06-01', 'yyyy-mm-dd'));
INSERT INTO cbctp (ctype, name, prcd, dtb) VALUES ('06', 'Центральный банк Республики Узбекистан','B', to_date('2022-06-01', 'yyyy-mm-dd'));
INSERT INTO cbctp (ctype, name, prcd, dtb) VALUES ('07', 'Коммерческие банки','B', to_date('2022-06-01', 'yyyy-mm-dd'));
INSERT INTO cbctp (ctype, name, prcd, dtb) VALUES ('08', 'Физические лица','P', to_date('2022-06-01', 'yyyy-mm-dd'));
INSERT INTO cbctp (ctype, name, prcd, dtb) VALUES ('09', 'Частные предприятия, хозяйства, товарищества и общества','C', to_date('2022-06-01', 'yyyy-mm-dd'));
INSERT INTO cbctp (ctype, name, prcd, dtb) VALUES ('10', 'Предприятия с участием иностранного капитала','C', to_date('2022-06-01', 'yyyy-mm-dd'));
INSERT INTO cbctp (ctype, name, prcd, dtb) VALUES ('11', 'Индивидуальные предприниматели','C', to_date('2022-06-01', 'yyyy-mm-dd'));
INSERT INTO cbctp (ctype, name, prcd, dtb) VALUES ('12', 'Бюджетные учреждения','C', to_date('2022-06-01', 'yyyy-mm-dd'));
INSERT INTO cbctp (ctype, name, prcd, dtb) VALUES ('13', 'Республиканский дорожный фонд','C', to_date('2022-06-01', 'yyyy-mm-dd'));
INSERT INTO cbctp (ctype, name, prcd, dtb) VALUES ('21', 'Самозанятые лица','P', to_date('2022-06-01', 'yyyy-mm-dd'));
