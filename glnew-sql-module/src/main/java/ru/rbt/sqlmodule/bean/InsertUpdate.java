package ru.rbt.sqlmodule.bean;

/**
 * Created by Ivan Sevastyanov
 */
public class InsertUpdate {

    private String insertSql;
    private String updateSql;
    private String whereClass;

    public String getInsertSql() {
        return insertSql;
    }

    public InsertUpdate setInsertSql(String insertSql) {
        this.insertSql = insertSql;
        return this;
    }

    public String getUpdateSql() {
        return updateSql;
    }

    public InsertUpdate setUpdateSql(String updateSql) {
        this.updateSql = updateSql;
        return this;
    }

    public String getWhereClass() {
        return whereClass;
    }

    public InsertUpdate setWhereClass(String whereClass) {
        this.whereClass = whereClass;
        return this;
    }
}
