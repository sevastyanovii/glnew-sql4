package ru.rbt.sqlmodule;

import freemarker.template.Configuration;
import ru.rbt.sqlmodule.bean.FileItem;
import ru.rbt.sqlmodule.bean.Version;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by Ivan Sevastyanov
 */
public abstract class AbstractPatchParser {

    protected Configuration freemarkerConfiguration;
    protected final File configFile;
    protected List<FileItem> fileItems = new ArrayList<>();
    protected String version;
    protected String applyedTo;
    protected String defaultSchema;
    protected String dbpaths;
    protected String module;

    public AbstractPatchParser(Configuration freemarkerConfiguration, File configFile) {
        this.freemarkerConfiguration = freemarkerConfiguration;
        this.configFile = configFile;
    }

    public List<FileItem> getFileItems() {
        return fileItems;
    }

    public String getVersion() {
        return version;
    }

    public String getApplyedTo() {
        return applyedTo;
    }

    public String getDefaultSchema() {
        return defaultSchema;
    }

    public String getDbpaths() {
        return dbpaths;
    }

    public String getModule() {
        return module;
    }

    public Map<String,Object> buildModel() {
        Version version = new Version().setVersion(this.version)
                .setPath(this.dbpaths).setSchema(this.defaultSchema)
                .setApplyedTo(this.applyedTo).setModule(this.module);
        Map<String,Object> model = new HashMap<>();
        model.put(ModelPaths.version.name(), version);
        return model;
    }

}
