package ru.rbt.sqlmodule.parse;

import freemarker.template.Configuration;
import ru.rbt.sqlmodule.AbstractPatchParser;
import ru.rbt.sqlmodule.SqlModuleUtils;
import ru.rbt.sqlmodule.parse.xjc.Release;
import ru.rbt.sqlmodule.parse.xjc.Versions;

import java.io.File;
import java.util.List;

import static java.util.stream.Collectors.joining;
import static java.util.stream.Collectors.toList;
import static ru.rbt.sqlmodule.SqlModuleUtils.*;

/**
 * внимание!!!!!!!! копипаст из trunkparser, переписать с AbstractFactory
 * Created by Ivan Sevastyanov
 */
public class VersionParser extends AbstractPatchParser {

    private String release;

    public VersionParser(Configuration freemarkerConfiguration, File configFile, String release) throws Exception {
        super(freemarkerConfiguration, configFile);
        this.release = release;
        parse();
    }

    private void parse() throws Exception {
        Versions versions = SqlModuleUtils.unmarshalXml(Versions.class, configFile);
        List<Release> targetReleases = versions.getRelease().stream().filter(r -> r.getVersion().equals(release)).collect(toList());
        assertThat(1 == targetReleases.size(), "Incorrected release: " + release + ", Found releases count: " + targetReleases.size());

        Release release = targetReleases.get(0);
        this.version = assertNotEmpty(release.getVersion(), "version is not set");
        this.applyedTo = assertNotEmpty(release.getApplyedTo().getVersion()
                .stream().map(String::trim).collect(joining(",")), "applyedTo is not set");
        this.defaultSchema = assertNotEmpty(release.getDefaultSchema(), "defaultSchema");
//        this.dbpaths = assertNotEmpty(release.getDbpaths().getDbpath()
//                .stream().map(String::trim).collect(joining(",")), "dbpaths is not set");
        this.fileItems = parseFiles(freemarkerConfiguration, configFile.getParentFile(), release.getItem(), buildModel());
        this.module = release.getModule();
    }
    
}
