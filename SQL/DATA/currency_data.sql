DELETE FROM currency WHERE glccy in ('EUR','GBP','RUB','USD','UZS');

INSERT INTO currency (glccy, cbccy, cynm, lcd, nbdp) VALUES ('EUR',	'978',	'ЕВРО',	            to_date('01.12.2022', 'dd.mm.yyyy'),	'0');
INSERT INTO currency (glccy, cbccy, cynm, lcd, nbdp) VALUES ('GBP',	'826',	'Фунт Стерлингов',	to_date('01.12.2022', 'dd.mm.yyyy'),	'0');
INSERT INTO currency (glccy, cbccy, cynm, lcd, nbdp) VALUES ('RUB',	'643',	'Российский рубль',	to_date('01.12.2022', 'dd.mm.yyyy'),	'0');
INSERT INTO currency (glccy, cbccy, cynm, lcd, nbdp) VALUES ('USD',	'840',	'Доллар Сша',	    to_date('01.12.2022', 'dd.mm.yyyy'),	'0');
INSERT INTO currency (glccy, cbccy, cynm, lcd, nbdp) VALUES ('UZS',	'000',	'Узбекский Сум',	to_date('01.12.2022', 'dd.mm.yyyy'),	'0');
