package ru.rbt.sqlmodule.bean;

/**
 * Created by Ivan Sevastyanov
 */
public class TabConstraint {

    private String constraintName;
    private String sqlExpression;

    public TabConstraint() {
    }

    public TabConstraint(String constraintName, String sqlExpression) {
        this.constraintName = constraintName;
        this.sqlExpression = sqlExpression;
    }

    public String getConstraintName() {
        return constraintName;
    }

    public void setConstraintName(String constraintName) {
        this.constraintName = constraintName;
    }

    public String getSqlExpression() {
        return sqlExpression;
    }

    public void setSqlExpression(String sqlExpression) {
        this.sqlExpression = sqlExpression;
    }
}
