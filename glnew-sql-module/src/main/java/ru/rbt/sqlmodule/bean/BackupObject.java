package ru.rbt.sqlmodule.bean;

import ru.rbt.sqlmodule.parse.xjc.DbObjectType;

/**
 * Created by Ivan Sevastyanov
 */
public class BackupObject {

    private final String objectName;
    private final DbObjectType objectType;

    public BackupObject(String objectName, DbObjectType objectType) {
        this.objectName = objectName;
        this.objectType = objectType;
    }

    public String getObjectName() {
        return objectName;
    }

    public DbObjectType getObjectType() {
        return objectType;
    }

    public boolean isTable() {
        return objectType == DbObjectType.TABLE;
    }

    public boolean isProcedure() {
        return objectType == DbObjectType.PROCEDURE;
    }

    public boolean isFunction() {
        return objectType == DbObjectType.FUNCTION;
    }

    public boolean isView() {
        return objectType == DbObjectType.VIEW;
    }

    public boolean isPackage () {
        return objectType == DbObjectType.PACKAGE;
    }

    public boolean isTrigger () {
        return objectType == DbObjectType.TRIGGER;
    }
}
