package ru.rbt.sqlmodule.parse;

import freemarker.template.Configuration;
import ru.rbt.sqlmodule.AbstractPatchParser;
import ru.rbt.sqlmodule.SqlModuleUtils;
import ru.rbt.sqlmodule.parse.xjc.Trunk;

import java.io.File;

import static java.util.stream.Collectors.joining;
import static ru.rbt.sqlmodule.SqlModuleUtils.assertNotEmpty;
import static ru.rbt.sqlmodule.SqlModuleUtils.parseFiles;

/**
 * Created by Ivan Sevastyanov
 */
public class TrunkParser extends AbstractPatchParser {

    public TrunkParser(Configuration freemarkerConfiguration, File configFile) throws Exception {
        super(freemarkerConfiguration, configFile);
        parse();
    }

    private void parse() throws Exception {
        Trunk trunk = SqlModuleUtils.unmarshalXml(Trunk.class, configFile);
        this.version = assertNotEmpty(trunk.getVersion(), "version is not set");
        this.applyedTo = assertNotEmpty(trunk.getApplyedTo().getVersion().stream().map(String::trim).collect(joining(",")), "applyedTo is not set");
        this.defaultSchema = null != trunk.getDefaultSchema() ? trunk.getDefaultSchema() : null;
        this.dbpaths = null != trunk.getDbpaths() ? assertNotEmpty(trunk.getDbpaths().getDbpath().stream().map(String::trim).collect(joining(",")), "dbpaths is not set") : null ;
        this.fileItems = parseFiles(freemarkerConfiguration, configFile.getParentFile(), trunk.getItem(), buildModel());
        this.module = trunk.getModule();
    }


}
