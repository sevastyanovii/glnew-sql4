CREATE OR REPLACE PACKAGE pkg_currency IS

    FUNCTION get_rate(a_ccy CHAR, a_dat DATE) RETURN NUMBER RESULT_CACHE;
    FUNCTION get_nbdp(a_ccy CHAR) RETURN NUMBER RESULT_CACHE;
    FUNCTION get_nbdp_lc RETURN NUMBER RESULT_CACHE;
    FUNCTION get_curdate RETURN DATE RESULT_CACHE;

END pkg_currency;
/

CREATE OR REPLACE PACKAGE BODY pkg_currency IS

    FUNCTION get_rate(a_ccy CHAR, a_dat DATE) RETURN NUMBER RESULT_CACHE IS
        l_res NUMBER(15, 9);
    BEGIN
        SELECT rate INTO l_res FROM currates WHERE dat = a_dat AND ccy = a_ccy;
        return l_res;
    END get_rate;

    FUNCTION get_nbdp(a_ccy CHAR) RETURN NUMBER RESULT_CACHE IS
        l_res NUMBER(10, 0);
    BEGIN
        SELECT nbdp INTO l_res FROM currency WHERE glccy = a_ccy;
        return l_res;
    END get_nbdp;

    FUNCTION get_nbdp_lc RETURN NUMBER RESULT_CACHE IS
        l_res NUMBER(10, 0);
    BEGIN
        SELECT nbdp INTO l_res FROM currency WHERE cbccy = '000';
        return l_res;
    END get_nbdp_lc;

    FUNCTION get_curdate RETURN DATE RESULT_CACHE IS
    	l_od DATE;
    BEGIN
        SELECT curdate INTO l_od FROM od;
        return l_od;
    END get_curdate;

END pkg_currency;
/
