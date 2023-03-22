package ru.rbt.sqlmodule.bean;

/**
 * Created by Ivan Sevastyanov
 */
public class TabColumn {

    private String name;
    private String type;
    private boolean mandatory;
    private boolean primary;
    private String defaultValue;
    private String comments;
    private RefTabColumn refTabColumn;

    public String getName() {
        return name;
    }

    public TabColumn setName(String name) {
        this.name = name;
        return this;
    }

    public String getType() {
        return type;
    }

    public TabColumn setType(String type) {
        this.type = type;
        return this;
    }

    public boolean isMandatory() {
        return mandatory;
    }

    public TabColumn setMandatory(boolean mandatory) {
        this.mandatory = mandatory;
        return this;
    }

    public boolean isPrimary() {
        return primary;
    }

    public TabColumn setPrimary(boolean primary) {
        this.primary = primary;
        return this;
    }

    public String getDefaultValue() {
        return defaultValue;
    }

    public TabColumn setDefaultValue(String defaultValue) {
        this.defaultValue = defaultValue;
        return this;
    }

    public TabColumn setComments(String comments) {
        this.comments = comments;
        return this;
    }

    public String getComments() {
        return comments;
    }

    public RefTabColumn getRefTabColumn() {
        return refTabColumn;
    }

    public TabColumn setRefTabColumn(RefTabColumn refTabColumn) {
        this.refTabColumn = refTabColumn;
        return this;
    }
}
