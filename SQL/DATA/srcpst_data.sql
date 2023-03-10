DELETE FROM srcpst;

INSERT INTO srcpst (srcid, srcname, srv_actype) VALUES ('CASA',	'Текущие счета', 'AC_CLASS');
INSERT INTO srcpst (srcid, srcname, srv_actype) VALUES ('DEP',	'Депозиты',      'AC_CLASS');
INSERT INTO srcpst (srcid, srcname, srv_actype) VALUES ('LOAN',	'Кредиты',       'PRODKEY');

INSERT INTO srcpst (srcid, srcname, srv_actype) VALUES ('FC_CASA', 'Текущие счета1', 'AC_CLASS');
INSERT INTO srcpst (srcid, srcname, srv_actype) VALUES ('FC_DP',   'Депозиты1',      'AC_CLASS');
INSERT INTO srcpst (srcid, srcname, srv_actype) VALUES ('FC_LN',   'Кредиты1',       'PRODKEY');
