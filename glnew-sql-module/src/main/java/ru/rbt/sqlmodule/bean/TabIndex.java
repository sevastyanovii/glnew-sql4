package ru.rbt.sqlmodule.bean;

/**
 * Created by Ivan Sevastyanov
 */
public class TabIndex {

    private String indexName;
    private boolean unique;
    private String sqlExpression;

    public TabIndex(String indexName, boolean unique, String sqlExpression) {
        this.indexName = indexName;
        this.unique = unique;
        this.sqlExpression = sqlExpression;
    }

    public String getIndexName() {
        return indexName;
    }

    public void setIndexName(String indexName) {
        this.indexName = indexName;
    }

    public boolean isUnique() {
        return unique;
    }

    public void setUnique(boolean unique) {
        this.unique = unique;
    }

    public String getSqlExpression() {
        return sqlExpression;
    }

    public void setSqlExpression(String sqlExpression) {
        this.sqlExpression = sqlExpression;
    }
}
