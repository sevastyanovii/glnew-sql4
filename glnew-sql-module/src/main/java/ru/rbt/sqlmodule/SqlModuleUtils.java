package ru.rbt.sqlmodule;

import freemarker.template.Configuration;
import freemarker.template.Template;
import ru.rbt.sqlmodule.bean.*;
import ru.rbt.sqlmodule.parse.xjc.Item;
import ru.rbt.sqlmodule.parse.xjc.table.ColumnType;
import ru.rbt.sqlmodule.parse.xjc.table.ConstraintsType;
import ru.rbt.sqlmodule.parse.xjc.table.IndexesType;
import ru.rbt.sqlmodule.parse.xjc.table.Table;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Unmarshaller;
import java.io.File;
import java.io.IOException;
import java.io.StringWriter;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.function.Supplier;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;

import static java.lang.String.format;
import static java.util.Optional.ofNullable;
import static java.util.stream.Collectors.joining;
import static java.util.stream.Collectors.toList;
import static ru.rbt.sqlmodule.bean.FileItem.ItemType.*;

/**
 * Created by Ivan Sevastyanov
 */
public class SqlModuleUtils {

    private static final Logger logger = Logger.getLogger(SqlModuleUtils.class.getName());

    public static String process(Configuration configuration, String templateName, Map<String, Object> model) {
        try (final StringWriter writer = new StringWriter()){
            final Template template = configuration.getTemplate(templateName);
            template.process(model, writer);
            return writer.toString();
        } catch (Exception e) {
            logger.log(Level.SEVERE, format("error on process template: %s", templateName), e);
            throw new RuntimeException(e.getMessage(), e);
        }
    }

    public static List<FileItem> parseFiles(Configuration configuration, File parentDir
            , List<Item> items, Map<String, Object> rootModel) throws Exception {
        return items.stream().map(item -> {
            try {
                return createFileItem(configuration, parentDir, item, rootModel);
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        }).collect(Collectors.toList());
    }

    private static FileItem createFileItem (Configuration configuration, File parentDir
            , Item item, Map<String, Object> rootModel) throws Exception {
        FileItem fileItem;
        if (!isEmpty(item.getFile())) {
            fileItem = new FileItem(item, FILE, Paths.get(parentDir.getAbsolutePath() + "/" + item.getFile()).toFile());
        } else
        if (!isEmpty(item.getBody())) {
            fileItem = createFileFromBody(item);
        } else
        if (!isEmpty(item.getTable())){
            fileItem = createFileFromTableBody(configuration, item, rootModel, parentDir);
        } else {
            throw new UnsupportedOperationException(format("Unexpected type item: '%s'", item.getItemName()));
        }

        if (null != item.getBackup()) {
            fileItem.setBackupObjects(item.getBackup().stream().map(b -> new BackupObject(b.getObjectName(), b.getObjectType())).collect(toList()));
        }
        return fileItem;
    }

    public static String assertNotEmpty(String testee, String claim) {
        if (!isEmpty(testee)) {
            return testee;
        } else {
            throw new IllegalArgumentException(claim);
        }
    }

    public static boolean isEmpty(String testee) {
        return null == testee || testee.trim().isEmpty();
    }

    public static String prefix() {
        return (System.currentTimeMillis() + "pre_");
    }

    public static String suffix() {
        return (System.currentTimeMillis() + "_sfx");
    }

    public static String postProcessItem(Configuration configuration, FileItem fileItem, String itemBody, Map<String, Object> rootModel) {
        rootModel.put("item", fileItem);
        rootModel.put("body", itemBody);
        return process(configuration, "item.ftl", rootModel);
    }

    private static FileItem createFileFromBody(Item item) throws IOException {
        File tempFile = createTemporaryFile(item.getItemName(), item.getBody());
        return new FileItem(item, INLINE, tempFile);
    }

    private static FileItem createFileFromTableBody(Configuration configuration
            , Item item, Map<String, Object> rootModel, File parentDir) throws Exception {
        try {
            Table table = unmarshalXml(Table.class, Paths.get(parentDir.getAbsolutePath(), "/", item.getTable()).toFile());

            DbTable dbtable = new DbTable()
                    .setName(table.getName())
                    .setComments(table.getComments())
                    .setColumns(table.getColumns().getColumn()
                            .stream().map(SqlModuleUtils::createColumn).collect(toList()))
                    .setConstraints(ofNullable(table.getConstraints()).orElseGet(ConstraintsType::new).getConstraint()
                            .stream().map(t -> new TabConstraint(t.getConstraintName(), t.getSqlExpression())).collect(toList()))
                    .setIndexes(ofNullable(table.getIndexes()).orElseGet(IndexesType::new).getIndex()
                            .stream().map(t -> new TabIndex(t.getName(), t.isUnique(), t.getSqlExpression())).collect(toList()))
                    .setTableData(creataTableData(table));
            rootModel.put("table", dbtable);

            final String tableBody = process(configuration, "table.ftl", rootModel);
            final File tempFile = createTemporaryFile(item.getItemName(), tableBody);
            return new FileItem(item, TABLE, tempFile);
        } catch (Exception e) {
            throw new RuntimeException(format("Error on process item: '%s'", item.getItemName()), e);
        }
    }

    public static void assertThat(boolean check) {
        assertThat(check, "Expression is not true");
    }

    public static void assertThat(boolean check, String message) {
        if (!check) throw new IllegalArgumentException(message);
    }

    public static void assertNull(Object target, String claim) {
        assertThat(null == target, claim);
    }

    private static File createTemporaryFile(String itemName, String body) throws IOException {
        File tempFile = File.createTempFile(itemName, suffix()
                , Paths.get(System.getProperty("java.io.tmpdir")).toFile());
        Files.write(tempFile.toPath(), Arrays.asList(body.split("\\r\\n"))
                        .stream().collect(toList())
                , Charset.forName(SqlModuleConstants.getInputCharset().name()));
        return tempFile;
    }

    public static <T> T unmarshalXml(Class<T> clazz, File file) throws JAXBException {
        JAXBContext jc = JAXBContext.newInstance(clazz);
        Unmarshaller unmarshaller = jc.createUnmarshaller();
        return (T) unmarshaller.unmarshal(file);
    }

    private static TabColumn createColumn(ColumnType column) {
        return new TabColumn()
                .setName(column.getName())
                .setType(column.getType())
                .setDefaultValue(column.getDefaultValue())
                .setComments(column.getComments())
                .setMandatory(null != column.isMandatory() ? column.isMandatory() : false)
                .setPrimary(null != column.isPrimary() ? column.isPrimary() : false)
                .setRefTabColumn(null != column.getForeign()
                        ? new RefTabColumn(column.getForeign().getForeignTableName(), column.getForeign().getForeignTabColumnName())
                        : null);
    }

    private static TableData creataTableData(Table table) {
        final TableData data = new TableData();
        if (null != table.getData()) {
            for (int i = 0; i < table.getData().getValues().size(); i++) {
                InsertUpdate insertUpdate = new InsertUpdate();
                insertUpdate.setWhereClass(buildWhereClass(table, i));
                insertUpdate.setInsertSql("insert into " + table.getName() + "(" + allColumnList(table)
                        + ") values (" + normalizeValues(table.getData().getValues().get(i)) + ")");
                final String updateColumns = buildUpdateColumns(table, i);
                insertUpdate.setUpdateSql(!isEmpty(updateColumns)
                        ? "update " + table.getName() + " set " + buildUpdateColumns(table, i) + " " + insertUpdate.getWhereClass()
                        : "");
                data.addRow(insertUpdate);
            }
        }
        return data;
    }

    private static String allColumnList(Table table) {
        return table.getColumns().getColumn().stream().map(ColumnType::getName).collect(joining(","));
    }

    private static String getDataValue(String value) {
        return (value.matches(".*[^']'$") || value.matches("^'[^'].*"))
                ? value.replaceAll("^'", "''").replaceAll("'$","''") : value;
    }

    private static String normalizeValues(String commaDelimString) {
        return Arrays.asList(commaDelimString.split(","))
                .stream().map(SqlModuleUtils::getDataValue).collect(joining(","));
    }

    private static String buildWhereClass(Table table, int rowIndex) {
        String[] values = table.getData().getValues().get(rowIndex).split(",");
        StringBuilder whereClass = new StringBuilder("where ");
        for (int i = 0; i < table.getColumns().getColumn().size(); i++) {
            ColumnType column = table.getColumns().getColumn().get(i);
            if (ofNullable(column.isPrimary()).orElse(false)) {
                whereClass.append(column.getName()).append(" = ").append(getDataValue(values[i])).append(" and ");
            }
        }
        return whereClass.toString().replaceAll("and.$", "").trim();
    }

    private static String buildUpdateColumns(Table table, int rowIndex) {
        String[] values = table.getData().getValues().get(rowIndex).split(",");
        assertThat(table.getColumns().getColumn().size() == values.length
                , format("Columns count '%s' not equals values count '%s'"
                        , table.getColumns().getColumn().size(), values.length));
        StringBuilder setUpdateClass = new StringBuilder();
        for (int i = 0; i < table.getColumns().getColumn().size(); i++) {
            ColumnType column = table.getColumns().getColumn().get(i);
            if (!ofNullable(column.isPrimary()).orElse(false)) {
                setUpdateClass.append(column.getName()).append(" = ").append(getDataValue(values[i])).append(",");
            }
        }
        return setUpdateClass.toString().replaceAll(",$", "").trim();
    }

    public static <T, X extends Throwable> void assertTrue(boolean test, Supplier<X> supplier) throws X {
        if (!test) {
            throw supplier.get();
        }
    }
}
