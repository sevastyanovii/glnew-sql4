package ru.rbt.sqlmodule;

import freemarker.template.Configuration;
import freemarker.template.TemplateExceptionHandler;
import ru.rbt.sqlmodule.parse.TrunkParser;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.logging.Level;
import java.util.logging.Logger;

import static java.lang.String.format;
import static java.util.Optional.ofNullable;

/**
 * Created by Ivan Sevastyanov
 */
public class PatchBuilderMainTrunk {

    private static final Logger logger = Logger.getLogger(PatchBuilderMainTrunk.class.getName());

    public static void main(String[] args) throws Exception {
        final Path trunkFile = Paths.get(ofNullable(args[0]).orElseThrow(() -> aNpe("trunk file is null")));
        logger.log(Level.INFO, "Building TRUNK from " + trunkFile.toAbsolutePath());
        final Configuration configuration = createFreeMarkerConfiguration(trunkFile.getParent());
        final TrunkParser trunkParser = new TrunkParser(configuration, trunkFile.toFile());
        final Path scriptFilePath = Paths.get(trunkFile.getParent().toString(), "/", "trunk.sql");
        logger.info(format("Script file \"%s\"", scriptFilePath.toAbsolutePath().toString()));
        PatchBuilder builder =
                new PatchBuilder(configuration, trunkParser.getVersion()
                        , trunkParser.getApplyedTo(), trunkParser.getDefaultSchema()
                        , trunkParser.getDbpaths(), trunkFile.getParent(), trunkParser.getModule()
                        , trunkParser.getFileItems(), trunkParser.buildModel(), getTrunkTemplates());
        try (FileOutputStream fos = new FileOutputStream(scriptFilePath.toFile())) {
            builder.build(fos);
        }
        createRollback(builder.rollback(), trunkFile.getParent(), "rollback.sql");
    }

    protected static void createRollback(
            String rollbackBody,final Path parent, final String fileName) throws IOException {
        Path rollbackPath = Paths.get(parent.toString() + "/", fileName);
        try (FileOutputStream fos = new FileOutputStream(rollbackPath.toFile());
             OutputStreamWriter writer = new OutputStreamWriter(fos, SqlModuleConstants.getOutputCharset())){
            writer.write(rollbackBody);
        }
        logger.info(format("Rollback file \"%s\"", rollbackPath.toString()));
    }

    protected static Configuration createFreeMarkerConfiguration(Path parentPath) throws IOException {
        Configuration configuration = new Configuration(Configuration.VERSION_2_3_22);
        configuration.setDefaultEncoding(SqlModuleConstants.getInputCharset().name());
        configuration.setDirectoryForTemplateLoading(parentPath.resolve("templates").toFile());
        configuration.setTemplateExceptionHandler(TemplateExceptionHandler.RETHROW_HANDLER);
        return configuration;
    }

    protected static NullPointerException aNpe(String message) {
        return new NullPointerException(message);
    }

    private static TemplatesList getTrunkTemplates() {
        return new TemplatesList().addTemplate(Template.check_version, Template.check_version.name() + "_trunk.ftl")
                .addTemplate(Template.instaLbackup, Template.instaLbackup.name() + "_trunk.ftl")
                .addTemplate(Template.script_completed, Template.script_completed.name() + "_trunk.ftl")
                .addTemplate(Template.init, Template.init.name() + "_trunk.ftl")
                .addTemplate(Template.install_version, Template.install_version.name() + "_trunk.ftl")
                .addTemplate(Template.rollback, Template.rollback.name() + ".ftl")
                .addTemplate(Template.item, Template.item.name() + ".ftl");
    }
}
