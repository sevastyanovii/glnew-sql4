BEGIN
	INSERT INTO currates VALUES (to_date('28.11.2022', 'dd.mm.yyyy'),	'RUB',	'185.84',	1,	'186.04');
	INSERT INTO currates VALUES (to_date('29.11.2022', 'dd.mm.yyyy'),	'RUB',	'184.82',	1,	'185.84');
	INSERT INTO currates VALUES (to_date('30.11.2022', 'dd.mm.yyyy'),	'RUB',	'183.62',	1,	'184.82');
	INSERT INTO currates VALUES (to_date('28.11.2022', 'dd.mm.yyyy'),	'USD',	'11246.11',	1,	'11230.39');
	INSERT INTO currates VALUES (to_date('29.11.2022', 'dd.mm.yyyy'),	'USD',	'11230.37',	1,	'11246.11');
	INSERT INTO currates VALUES (to_date('30.11.2022', 'dd.mm.yyyy'),	'USD',	'11212.97',	1,	'11230.37');
	INSERT INTO currates VALUES (to_date('28.11.2022', 'dd.mm.yyyy'),	'EUR',	'11688.08',	1,	'11700.94');
	INSERT INTO currates VALUES (to_date('29.11.2022', 'dd.mm.yyyy'),	'EUR',	'11732.37',	1,	'11688.08');
	INSERT INTO currates VALUES (to_date('30.11.2022', 'dd.mm.yyyy'),	'EUR',	'11622.24',	1,	'11732.37');
	INSERT INTO currates VALUES (to_date('28.11.2022', 'dd.mm.yyyy'),	'GBP',	'13586.43',	1,	'13582.03');
	INSERT INTO currates VALUES (to_date('29.11.2022', 'dd.mm.yyyy'),	'GBP',	'13575.27',	1,	'13586.43');
	INSERT INTO currates VALUES (to_date('30.11.2022', 'dd.mm.yyyy'),	'GBP',	'13442.11',	1,	'13575.27');
EXCEPTION
   WHEN OTHERS THEN
      NULL;
END;
/
