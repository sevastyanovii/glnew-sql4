package ru.rbt.sqlmodule;

import java.nio.charset.Charset;
import java.nio.charset.IllegalCharsetNameException;
import java.util.Optional;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Created by Ivan Sevastyanov
 */
public class SqlModuleConstants {

    private static final Logger log = Logger.getLogger(SqlModuleConstants.class.getName());

    public static final String SQL_SCRIPTS_ENCODING = "cp1251";
    private static final String SQL_OUT_ENCODING = "Cp866";

    private static final String SQL_OUT_ENCODING_PROPERTY = "output_charset";
    private static final String SQL_INPUT_ENCODING_PROPERTY = "input_charset";

    public static Charset getOutputCharset() {
        try {
            return Charset.forName(Optional.ofNullable(System.getProperty(SQL_OUT_ENCODING_PROPERTY))
                    .orElse(SQL_OUT_ENCODING));
        } catch (IllegalCharsetNameException e) {
            log.log(Level.WARNING, String.format("Error in calculating the output encoding. Installed by default: '%s'", SQL_OUT_ENCODING), e);
            return Charset.forName(SQL_OUT_ENCODING);
        }
    }

    public static Charset getInputCharset() {
        try {
            return Charset.forName(Optional.ofNullable(System.getProperty(SQL_INPUT_ENCODING_PROPERTY))
                    .orElse(SQL_SCRIPTS_ENCODING));
        } catch (IllegalCharsetNameException e) {
            log.log(Level.WARNING, String.format("Error in calculating the INPUT encoding. Installed by default: '%s'", SQL_SCRIPTS_ENCODING), e);
            return Charset.forName(SQL_SCRIPTS_ENCODING);
        }
    }
}
