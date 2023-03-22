package ru.rbt.sqlmodule.bean;

/**
 * Created by Ivan Sevastyanov
 * foreign key
 */
public class RefTabColumn extends TabColumn {

    private String foreignTableName;
    private String foreignTabColumnName;

    public RefTabColumn() {}

    public RefTabColumn(String foreignTableName, String foreignTabColumnName) {
        this.foreignTableName = foreignTableName;
        this.foreignTabColumnName = foreignTabColumnName;
    }

    public String getForeignTableName() {
        return foreignTableName;
    }

    public void setForeignTableName(String foreignTableName) {
        this.foreignTableName = foreignTableName;
    }

    public String getForeignTabColumnName() {
        return foreignTabColumnName;
    }

    public void setForeignTabColumnName(String foreignTabColumnName) {
        this.foreignTabColumnName = foreignTabColumnName;
    }
}
