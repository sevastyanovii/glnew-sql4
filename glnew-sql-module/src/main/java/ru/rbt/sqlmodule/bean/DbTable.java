package ru.rbt.sqlmodule.bean;

import java.util.List;

/**
 * Created by Ivan Sevastyanov
 */
public class DbTable {

    private String name;
    private List<TabColumn> columns;
    private List<TabConstraint> constraints;
    private List<TabIndex> indexes;
    private String comments;
    private TableData tableData;

    public String getName() {
        return name;
    }

    public DbTable setName(String name) {
        this.name = name;
        return this;
    }

    public List<TabColumn> getColumns() {
        return columns;
    }

    public DbTable setColumns(List<TabColumn> columns) {
        this.columns = columns;
        return this;
    }

    public List<TabConstraint> getConstraints() {
        return constraints;
    }

    public DbTable setConstraints(List<TabConstraint> constraints) {
        this.constraints = constraints;
        return this;
    }

    public String getComments() {
        return comments;
    }

    public DbTable setComments(String comments) {
        this.comments = comments;
        return this;
    }

    public List<TabIndex> getIndexes() {
        return indexes;
    }

    public DbTable setIndexes(List<TabIndex> indexes) {
        this.indexes = indexes;
        return this;
    }

    public TableData getTableData() {
        return tableData;
    }

    public DbTable setTableData(TableData tableData) {
        this.tableData = tableData;
        return this;
    }
}
