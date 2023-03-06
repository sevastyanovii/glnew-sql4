CREATE OR REPLACE PACKAGE pkg_format IS
  FUNCTION msg_format3(a_template VARCHAR2, a_replace1 VARCHAR2) RETURN VARCHAR2;
  FUNCTION msg_format3(a_template VARCHAR2, a_replace1 VARCHAR2, a_replace2 VARCHAR2) RETURN VARCHAR2;
  FUNCTION msg_format3(a_template VARCHAR2, a_replace1 VARCHAR2, a_replace2 VARCHAR2, a_replace3 VARCHAR2) RETURN VARCHAR2;
  FUNCTION msg_format3(a_template VARCHAR2, a_replace1 VARCHAR2, a_replace2 VARCHAR2, a_replace3 VARCHAR2, a_replace4 VARCHAR2) RETURN VARCHAR2;
  FUNCTION msg_format3(a_template VARCHAR2, a_replace1 VARCHAR2, a_replace2 VARCHAR2, a_replace3 VARCHAR2, a_replace4 VARCHAR2, a_replace5 VARCHAR2) RETURN VARCHAR2;
END pkg_format;
/

CREATE OR REPLACE PACKAGE BODY pkg_format IS

  FUNCTION msg_format3(a_template VARCHAR2, a_replace1 VARCHAR2) RETURN VARCHAR2 is
  begin
    RETURN replace(a_template, '{0}', a_replace1);
  END msg_format3;

  FUNCTION msg_format3(a_template VARCHAR2, a_replace1 VARCHAR2, a_replace2 VARCHAR2) RETURN VARCHAR2 is
  begin
    RETURN replace(replace(a_template, '{0}', a_replace1), '{1}', a_replace2);
  END msg_format3;

  FUNCTION msg_format3(a_template VARCHAR2, a_replace1 VARCHAR2, a_replace2 VARCHAR2, a_replace3 VARCHAR2) RETURN VARCHAR2 is
  begin
    RETURN replace(replace(replace(a_template, '{0}', a_replace1), '{1}', a_replace2), '{2}', a_replace3);
  END msg_format3;

  FUNCTION msg_format3(a_template VARCHAR2, a_replace1 VARCHAR2, a_replace2 VARCHAR2, a_replace3 VARCHAR2, a_replace4 VARCHAR2) RETURN VARCHAR2 is
  begin
    RETURN replace(replace(replace(replace(a_template, '{0}', a_replace1), '{1}', a_replace2), '{2}', a_replace3), '{3}', a_replace4);
  END msg_format3;

  FUNCTION msg_format3(a_template VARCHAR2, a_replace1 VARCHAR2, a_replace2 VARCHAR2, a_replace3 VARCHAR2, a_replace4 VARCHAR2, a_replace5 VARCHAR2) RETURN VARCHAR2 is
  begin
    RETURN replace(replace(replace(replace(replace(a_template, '{0}', a_replace1), '{1}', a_replace2), '{2}', a_replace3), '{3}', a_replace4), '{4}', a_replace5);
  END msg_format3;

END pkg_format;
/
