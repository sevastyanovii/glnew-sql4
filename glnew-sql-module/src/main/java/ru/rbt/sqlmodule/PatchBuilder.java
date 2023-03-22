package ru.rbt.sqlmodule;

import freemarker.template.Configuration;
import ru.rbt.sqlmodule.bean.BackupObject;
import ru.rbt.sqlmodule.bean.FileItem;
import ru.rbt.sqlmodule.bean.RollbackScript;
import ru.rbt.sqlmodule.parse.xjc.DbObjectType;

import java.io.*;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

import static java.lang.String.format;
import static ru.rbt.sqlmodule.ModelPaths.*;
import static ru.rbt.sqlmodule.SqlModuleUtils.*;
import static ru.rbt.sqlmodule.parse.xjc.DbObjectType.*;

/**
 * Created by Ivan Sevastyanov
 */
public class PatchBuilder {

    private final String version;
    private final String applyedTo;
    private final String defaultSchema;
    private final String dbpaths;
    private final Path parent;
    private String module;
    private final List<FileItem> scripts;
    private final Configuration freeMarkerConfiguration;
    private final Map<String, Object> model;
    private TemplatesList templatesList = new TemplatesList();


    public PatchBuilder(Configuration freeMarkerConfiguration, String version
            , String applyedTo, String defaultSchema
            , String dbpaths, Path parent, String module
            , List<FileItem> scripts, Map<String,Object> model) throws IOException {
        this.version = version;
        this.applyedTo = applyedTo;
        this.defaultSchema = defaultSchema;
        this.dbpaths = dbpaths;
        this.parent = parent;
        this.module = module;
        this.scripts = scripts;
        this.freeMarkerConfiguration = freeMarkerConfiguration;
        this.model = model;

        enrichModel();
        buildDefaultTemplates();
    }

    public PatchBuilder(Configuration freeMarkerConfiguration, String version
            , String applyedTo, String defaultSchema
            , String dbpaths, Path parent, String module
            , List<FileItem> scripts, Map<String,Object> model, TemplatesList templatesList) throws IOException {
        this(freeMarkerConfiguration, version
                , applyedTo, defaultSchema
                , dbpaths, parent, module
                , scripts, model);
        this.templatesList = templatesList;
    }

    public void build(OutputStream fos) {
        try(OutputStreamWriter osr = new OutputStreamWriter(fos, SqlModuleConstants.getOutputCharset());
            BufferedWriter patchFileBufferedWriter = new BufferedWriter(osr)) {

            patchFileBufferedWriter.newLine();
            patchFileBufferedWriter.append(init());
            patchFileBufferedWriter.newLine();
            patchFileBufferedWriter.append(checkVersion());
            patchFileBufferedWriter.newLine();
            patchFileBufferedWriter.append(backup());
            patchFileBufferedWriter.newLine();

            for (FileItem scriptFile : scripts) {
                patchFileBufferedWriter.newLine();
                patchFileBufferedWriter.newLine();
                patchFileBufferedWriter.write("-- ================= Patch script: " + getCaption(parent, scriptFile) + "   =================");
                patchFileBufferedWriter.newLine();
                patchFileBufferedWriter.newLine();
                try (FileInputStream scriptFileInputStream = new FileInputStream(scriptFile.getFile());
                     InputStreamReader scriptFileInputStreamReader = new InputStreamReader(scriptFileInputStream, SqlModuleConstants.getInputCharset());
                     BufferedReader scriptFileBufferedReader = new BufferedReader(scriptFileInputStreamReader)
                ) {

                    char[] buffer = new char[1024];
                    int cnt;
                    try (StringWriter stringWriter = new StringWriter()){
                        while ((cnt = scriptFileBufferedReader.read(buffer)) > 0) {
                            stringWriter.write(buffer, 0, cnt);
                        }
                        stringWriter.flush();
                        String itemBody = SqlModuleUtils.postProcessItem(freeMarkerConfiguration, scriptFile, stringWriter.toString(), model);
                        patchFileBufferedWriter.write(itemBody);
                        patchFileBufferedWriter.flush();
                    }
                }
            }
            patchFileBufferedWriter.newLine();
            patchFileBufferedWriter.append(installVersion());
            patchFileBufferedWriter.newLine();
            patchFileBufferedWriter.append(scriptCompleted());
        } catch (Throwable e) {
            e.printStackTrace();
            throw new RuntimeException(e.getMessage(), e);
        }
    }

    private String getCaption(Path parent, FileItem item) {
        switch (item.getItemType()) {
            case FILE: return format("item '%s', type '%s', file '%s'"
                    , item.getItemName(), item.getItemType(), parent.relativize(item.getFile().toPath()));
            case INLINE: return format("item '%s', type '%s', file '%s'", item.getItemName(), item.getItemType(), "");
            case TABLE: return format("item '%s', type '%s', file '%s'"
                    , item.getItemName(), item.getItemType(), item.getItemString());
        }
        throw new UnsupportedOperationException(item.getItemType().name());
    }


    private String init() {
        return SqlModuleUtils.process(freeMarkerConfiguration, templatesList.getTemplateFilename(Template.init), model);
    }

    private String checkVersion() {
        return SqlModuleUtils.process(freeMarkerConfiguration, templatesList.getTemplateFilename(Template.check_version), model);
    }

    private String installVersion() {
        return SqlModuleUtils.process(freeMarkerConfiguration, templatesList.getTemplateFilename(Template.install_version), model);
    }

    private String scriptCompleted() {
        return SqlModuleUtils.process(freeMarkerConfiguration, templatesList.getTemplateFilename(Template.script_completed), model);
    }

    private String backup() {
        return SqlModuleUtils.process(freeMarkerConfiguration, templatesList.getTemplateFilename(Template.instaLbackup), model);
    }

    public String rollback() {
        return SqlModuleUtils.process(freeMarkerConfiguration, templatesList.getTemplateFilename(Template.rollback), model);
    }

    private String item() {
        return SqlModuleUtils.process(freeMarkerConfiguration, templatesList.getTemplateFilename(Template.rollback), model);
    }

    private void enrichModel() {
        List<BackupObject> allBackupObjects = allBackupObjects();
        assertNull(model.put(all_backup_tables.name(), allBackupObjects(allBackupObjects, TABLE)), all_backup_tables.name());
        assertNull(model.put(all_backup_procedures.name(), allBackupObjects(allBackupObjects, PROCEDURE)), all_backup_procedures.name());
        assertNull(model.put(all_backup_views.name(), allBackupObjects(allBackupObjects, VIEW)), all_backup_views.name());
        assertNull(model.put(all_backup_functions.name(), allBackupObjects(allBackupObjects, FUNCTION)), all_backup_functions.name());
        assertNull(model.put(all_backup_packages.name(), allBackupObjects(allBackupObjects, PACKAGE)), all_backup_packages.name());
        assertNull(model.put(all_backup_objects.name(), allBackupObjects()), all_backup_objects.name());
        assertNull(model.put(all_rollback_scripts.name(), allRollbackScripts()), all_rollback_scripts.name());
    }

    private List<BackupObject> allBackupObjects() {
        final List<BackupObject> result = new ArrayList<>();
        for (FileItem item : scripts) {
            if (null != item.getBackupObjects()) {
                result.addAll(item.getBackupObjects());
            }
        }
        return result;
    }

    private String allBackupObjects(List<BackupObject> allBackupObjects, DbObjectType objectType) {
        return allBackupObjects.stream()
                .filter(i -> i.getObjectType() == objectType).map(BackupObject::getObjectName).collect(Collectors.joining(" "));
    }

    private List<RollbackScript> allRollbackScripts() {
        final int[] i = {0};
        return scripts.stream().map(item -> {
            if (null != item.getRollbackType()) {
                if (!SqlModuleUtils.isEmpty(item.getRollbackType().getBody())) {
                    return new RollbackScript(i[0]++, item.getItemName(), item.getRollbackType().getBody());
                } else if(!SqlModuleUtils.isEmpty(item.getRollbackType().getCommand())) {
                    return new RollbackScript(i[0]++, item.getItemName(), commandToBody(parent, item.getRollbackType().getCommand()));
                }
            }
            return null;
            // sorted descending
        }).filter(Objects::nonNull).sorted((o1, o2) -> o1.getCounter()> o2.getCounter() ? -1 : (o1.getCounter() == o2.getCounter() ? 0 : 1)).collect(Collectors.toList());
    }

    private void buildDefaultTemplates() {
        templatesList.addTemplate(Template.check_version, Template.check_version.name() + ".ftl")
                .addTemplate(Template.instaLbackup, Template.instaLbackup.name() + ".ftl")
                .addTemplate(Template.script_completed, Template.script_completed.name() + ".ftl")
                .addTemplate(Template.init, Template.init.name() + ".ftl")
                .addTemplate(Template.install_version, Template.install_version.name() + ".ftl")
                .addTemplate(Template.rollback, Template.rollback.name() + ".ftl")
                .addTemplate(Template.item, Template.item.name() + ".ftl");
    }

    private static String commandToBody(Path parent, String command) {
        try {
            ProcessBuilder processBuilder = new ProcessBuilder(command.split(" "));
            processBuilder.directory(parent.toFile());
            Process process = processBuilder.start();
            String normalOutput = inputStreamToString(process.getInputStream());
            String errorOutput = inputStreamToString(process.getErrorStream());
            assertTrue(isEmpty(errorOutput), () -> new RuntimeException(format("Error output is detected on command '%s' \n error: >>%s<<", command, errorOutput)));
            assertTrue(!isEmpty(normalOutput), () -> new RuntimeException(format("Normal output is empty on command '%s'", command)));
            return normalOutput;
        } catch (IOException e) {
            throw new RuntimeException(e.getMessage(), e);
        }
    }

    private static String inputStreamToString(InputStream inputStream) throws IOException {
        try (InputStreamReader isr = new InputStreamReader(inputStream, SqlModuleConstants.getInputCharset())
             ; BufferedReader reader = new BufferedReader(isr)) {
            StringBuilder builder = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                builder.append(line).append(System.getProperty("line.separator"));
            }
            return builder.toString();
        }
    }

}
