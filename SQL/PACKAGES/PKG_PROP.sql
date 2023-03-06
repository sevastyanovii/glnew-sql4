CREATE OR REPLACE PACKAGE pkg_prop IS

    /**
        возвращает значение числового свойства NVL(DECIMAL_VALUE, NUMBER_VALUE) по названию или NULL, если нет такого свойства
    */
    FUNCTION get_number_value(A_PROPNAME VARCHAR2, A_DEFAULT NUMBER := NULL) RETURN NUMBER RESULT_CACHE;
    FUNCTION get_string_value(a_propname sys_prop.id_prp%type, a_default sys_prop.string_value%type := null) return varchar2 result_cache;
    FUNCTION get_boolean_value(a_propname sys_prop.id_prp%type, a_default boolean := null) return boolean result_cache;

    procedure set_parameter(a_id_prp sys_prop.ID_PRP%type
        , a_value varchar2
        , a_descr sys_prop.DESCRP%type default null
        , a_type sys_prop.PRPTP%type default null);

END pkg_prop;
/

CREATE OR REPLACE PACKAGE BODY pkg_prop IS

    FUNCTION GET_NUMBER_VALUE(A_PROPNAME VARCHAR2, A_DEFAULT NUMBER := NULL) RETURN NUMBER RESULT_CACHE IS
        L_RES NUMBER;
        FUNCTION not_null(a_value number) return number is
        BEGIN
            IF (a_value is null) THEN
                raise_application_error(-20000, pkg_format.msg_format3('Не установлено значение для параметра "{0}"', A_PROPNAME));
            ELSE
                return a_value;
            END IF;
        END not_null;
    BEGIN
        SELECT coalesce(DECIMAL_VALUE, NUMBER_VALUE, CAST(STRING_VALUE AS NUMBER)) INTO L_RES FROM sys_prop WHERE ID_PRP = A_PROPNAME;
        RETURN not_null(L_RES);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN A_DEFAULT;
    END get_number_value;

    FUNCTION get_string_value(a_propname sys_prop.id_prp%type, a_default sys_prop.string_value%type := null) return varchar2 result_cache is
        l_res varchar2(4000);
    BEGIN
        select coalesce(to_char(decimal_value), string_value, to_char(number_value), boolean_value) into l_res from sys_prop where id_prp = a_propname;
        return l_res;
    EXCEPTION
        when no_data_found then
            return a_default;
    END get_string_value;

    FUNCTION get_boolean_value(a_propname sys_prop.id_prp%type, a_default boolean := null) return boolean result_cache is
        l_res varchar2(16) := get_string_value(a_propname);
    BEGIN
        return case when lower(l_res) = 'true' then true when l_res is null then a_default else false end;
    END get_boolean_value;

    PROCEDURE set_parameter(a_id_prp sys_prop.ID_PRP%type
        , a_value varchar2
        , a_descr sys_prop.DESCRP%type default null
        , a_type sys_prop.PRPTP%type default null) is
        pragma autonomous_transaction;

        l_prp sys_prop%rowtype;
        l_col user_tab_cols.column_name%type;

        FUNCTION type2column return varchar2 is
        BEGIN
            return case nvl(a_type, 'STRING_TYPE')
                       when 'DECIMAL_TYPE' then 'DECIMAL_VALUE'
                       when 'NUMBER_TYPE' then 'NUMBER_VALUE'
                       when 'STRING_TYPE' then 'STRING_VALUE'
                       when 'BOOLEAN_TYPE' then 'BOOLEAN_VALUE'
                       else 'UNKNOWN_TYPE_PROPERTY'
                     end;
        END type2column;

        FUNCTION others2null(a_exclude user_tab_cols.column_name%type) return varchar2 is
            l_setnull_cols varchar2(4000);
        BEGIN
            select LISTAGG(column_name||' = null', ', ') WITHIN GROUP (ORDER BY column_name) cols into l_setnull_cols
             from user_tab_cols where table_name = 'sys_prop' and column_name like '%VALUE'
              and column_name not in (a_exclude);
            return l_setnull_cols;
         END others2null;
    begin
        l_col := type2column();
        declare
            l_cmd varchar2(4000);
        begin
            select * into l_prp from sys_prop where ID_PRP = a_id_prp;
            l_cmd := 'update sys_prop set '
                ||l_col||'= :a_value, DESCRP = nvl(:a_descr, DESCRP), PRPTP = nvl(:a_type, PRPTP),'
                ||others2null(l_col)
                ||' where id_prp = :id_prp';
            execute immediate l_cmd using a_value, a_descr, a_type, a_id_prp;
        EXCEPTION
            WHEN no_data_found THEN
                l_prp.PRPTP := nvl(a_type, 'STRING_TYPE');
                execute immediate pkg_format.msg_format3(q'[
                INSERT INTO sys_prop(ID_PRP, ID_PRN, REQUIRED, PRPTP, DESCRP, {0})
                VALUES (:a_id_prp, 'root', 'Y', :prptp, nvl(:a_descr, 'Parameter '||:a_id_prp), :a_value)
                ]'
                , l_col)
                using a_id_prp, l_prp.PRPTP, a_descr, a_id_prp, a_value;
        END;
        COMMIT;
    END set_parameter;

END pkg_prop;
/
