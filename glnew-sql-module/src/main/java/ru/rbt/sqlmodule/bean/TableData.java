package ru.rbt.sqlmodule.bean;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Ivan Sevastyanov
 */
public class TableData {

    private List<InsertUpdate> rows = new ArrayList<>();

    public List<InsertUpdate> getRows() {
        return rows;
    }

    public TableData setRows(List<InsertUpdate> rows) {
        this.rows = rows;
        return this;
    }

    public void addRow(InsertUpdate row) {
        rows.add(row);
    }
}
