package ru.rbt.sqlmodule;

import freemarker.template.Configuration;
import ru.rbt.sqlmodule.parse.VersionParser;

import java.io.FileOutputStream;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.logging.Level;
import java.util.logging.Logger;

import static java.lang.String.format;
import static java.util.Optional.ofNullable;

/**
 * Created by Ivan Sevastyanov
 */
public class PatchBuilderMainVersion extends PatchBuilderMainTrunk {

    private static final Logger logger = Logger.getLogger(PatchBuilderMainVersion.class.getName());

    public static void main(String[] args) throws Exception {
        final Path versionsFile = Paths.get(ofNullable(args[0])
                .orElseThrow(() -> aNpe("versionsFile is null ([0])")));
        logger.log(Level.INFO, "Building patch from " + versionsFile.toAbsolutePath());
        final String release = ofNullable(args[1]).orElseThrow(() -> aNpe("release is null ([1])"));
        logger.log(Level.INFO, "Release: " + release);
        final Configuration configuration = createFreeMarkerConfiguration(versionsFile.getParent());
        final VersionParser versionParser = new VersionParser(configuration, versionsFile.toFile(), release);
        final Path scriptFilePath = Paths.get(versionsFile.getParent().toString(), "/", "patch-" + release + ".sql");
        logger.info(format("Script file \"%s\"", scriptFilePath.toAbsolutePath().toString()));
        PatchBuilder builder =
                new PatchBuilder(configuration
                        , versionParser.getVersion(), versionParser.getApplyedTo()
                        , versionParser.getDefaultSchema(), versionParser.getDbpaths()
                        , versionsFile.getParent(), versionParser.getModule(), versionParser.getFileItems()
                        , versionParser.buildModel());
        try (FileOutputStream fos = new FileOutputStream(scriptFilePath.toFile())) {
            builder.build(fos);
        }

        createRollback(builder.rollback(), versionsFile.getParent(), "rollback-" + release + ".sql");
    }
}
