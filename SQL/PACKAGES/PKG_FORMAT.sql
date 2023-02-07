create or replace package PKG_FORMAT is
  function msg_format3(a_template varchar2, a_replace1 varchar2) return varchar2;
  function msg_format3(a_template varchar2, a_replace1 varchar2, a_replace2 varchar2) return varchar2;
  function msg_format3(a_template varchar2, a_replace1 varchar2, a_replace2 varchar2, a_replace3 varchar2) return varchar2;
  function msg_format3(a_template varchar2, a_replace1 varchar2, a_replace2 varchar2, a_replace3 varchar2, a_replace4 varchar2) return varchar2;
  function msg_format3(a_template varchar2, a_replace1 varchar2, a_replace2 varchar2, a_replace3 varchar2, a_replace4 varchar2, a_replace5 varchar2) return varchar2;
end PKG_FORMAT;
/

create or replace package body PKG_FORMAT is

  function msg_format3(a_template varchar2, a_replace1 varchar2) return varchar2 is
  begin
    return replace(a_template, '{0}', a_replace1);
  end msg_format3;

  function msg_format3(a_template varchar2, a_replace1 varchar2, a_replace2 varchar2) return varchar2 is
  begin
    return replace(replace(a_template, '{0}', a_replace1), '{1}', a_replace2);
  end msg_format3;

  function msg_format3(a_template varchar2, a_replace1 varchar2, a_replace2 varchar2, a_replace3 varchar2) return varchar2 is
  begin
    return replace(replace(replace(a_template, '{0}', a_replace1), '{1}', a_replace2), '{2}', a_replace3);
  end msg_format3;

  function msg_format3(a_template varchar2, a_replace1 varchar2, a_replace2 varchar2, a_replace3 varchar2, a_replace4 varchar2) return varchar2 is
  begin
    return replace(replace(replace(replace(a_template, '{0}', a_replace1), '{1}', a_replace2), '{2}', a_replace3), '{3}', a_replace4);
  end msg_format3;

  function msg_format3(a_template varchar2, a_replace1 varchar2, a_replace2 varchar2, a_replace3 varchar2, a_replace4 varchar2, a_replace5 varchar2) return varchar2 is
  begin
    return replace(replace(replace(replace(replace(a_template, '{0}', a_replace1), '{1}', a_replace2), '{2}', a_replace3), '{3}', a_replace4), '{4}', a_replace5);
  end msg_format3;

end PKG_FORMAT;
/
