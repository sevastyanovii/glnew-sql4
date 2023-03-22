package ru.rbt.sqlmodule.bean;

import ru.rbt.sqlmodule.parse.xjc.OnSqlErrorType;

public class OnSqlError {

    private OnSqlErrorType type;

    public OnSqlError(OnSqlErrorType type) {
        this.type = type;
    }

    public boolean isExit() {
        return type == OnSqlErrorType.EXIT;
    }

    public boolean isContinue() {
        return type == OnSqlErrorType.CONTINUE;
    }
}
