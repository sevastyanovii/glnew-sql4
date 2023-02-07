CREATE TABLE appuser
(
	id_user    NUMBER GENERATED ALWAYS AS IDENTITY (NOCACHE) PRIMARY KEY,
	user_name  VARCHAR2(255 CHAR) NOT NULL UNIQUE,
	user_pwd   VARCHAR2(64  CHAR) NOT NULL,
	user_role  VARCHAR2(32  CHAR) NOT NULL,
	surname    VARCHAR2(255 CHAR) NOT NULL,
	firstname  VARCHAR2(255 CHAR) NOT NULL,
	patronymic VARCHAR2(255 CHAR),
	filial     CHAR(3),
	create_dt  TIMESTAMP DEFAULT SYSTIMESTAMP not null,
	end_dt     TIMESTAMP,
	locked     CHAR(1) DEFAULT '0' not null,
	CONSTRAINT ch_user_locked CHECK (locked IN ('0', '1'))
);

COMMENT ON TABLE appuser IS 'Пользователь приложения';
COMMENT ON COLUMN appuser.id_user     IS 'ИД';
COMMENT ON COLUMN appuser.user_name   IS 'Логин';
COMMENT ON COLUMN appuser.user_pwd    IS 'Хэш пароля';
COMMENT ON COLUMN appuser.user_role   IS 'Роль';
COMMENT ON COLUMN appuser.surname     IS 'Фамилия';
COMMENT ON COLUMN appuser.firstname   IS 'Имя';
COMMENT ON COLUMN appuser.patronymic  IS 'Отчество';
COMMENT ON COLUMN appuser.filial      IS 'Филиал';
COMMENT ON COLUMN appuser.create_dt   IS 'Время создания';
COMMENT ON COLUMN appuser.end_dt      IS 'Время блокировки';
COMMENT ON COLUMN appuser.locked      IS 'Состояние блокировки';
