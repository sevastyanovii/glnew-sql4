package ru.rbt.sqlmodule.bean;

/**
 * Created by Ivan Sevastyanov
 */
public class Version {
    private String version;
    private String schema;
    private String path;
    private String module;
    private String applyedTo;

    public Version() {
    }

    public Version setSchema(String schema) {
        this.schema = schema;
        return this;
    }

    public Version setPath(String path) {
        this.path = path;
        return this;
    }

    public String getVersion() {

        return version;
    }

    public Version setVersion(String version) {
        this.version = version;
        return this;
    }

    public String getSchema() {
        return schema;
    }

    public String getPath() {
        return path;
    }

    public String getModule() {
        return module;
    }

    public Version setModule(String module) {
        this.module = module;
        return this;
    }

    public String getApplyedTo() {
        return applyedTo;
    }

    public Version setApplyedTo(String applyedTo) {
        this.applyedTo = applyedTo;
        return this;
    }
}
