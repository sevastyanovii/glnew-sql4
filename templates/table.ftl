ALTER SESSION SET nls_timestamp_format = 'YYYY-MM-DD HH24:MI:SS.FF6';

ALTER SESSION SET nls_date_format = 'YYYY-MM-DD HH24:MI:SS';

<#if (table.columns[0].defaultValue)??>
    <#assign defaultExpr=" DEFAULT ${table.columns[0].defaultValue}">
<#else>
    <#assign defaultExpr="">
</#if>

<#if table.columns[0].mandatory>
    <#assign notNull=" NOT NULL">
<#else>
    <#assign notNull="">
</#if>

/

BEGIN
 DB_CONF.CREATE_TABLE_IF_ABSENT(
    USER
    , '${table.name}'
    , '${table.columns[0].name} ${table.columns[0].type} ${defaultExpr}${notNull}'
    , ''
);
END;
/

COMMIT;

COMMIT;

COMMENT ON TABLE ${table.name} IS q'[${table.comments!""}]';

<#assign primaryKeys="">


COMMIT;

<#list table.columns as column>

-- === Adding table column ${table.name}.${column.name} ===

<#if (column.defaultValue)??>
    <#assign defaultExpr=" DEFAULT ${column.defaultValue}">
<#else>
    <#assign defaultExpr="">
</#if>

COMMIT;

BEGIN
    DB_CONF.ADD_COLUMN_IF_ABSENT(USER, '${table.name}', '${column.name}', q'[${column.type} ${defaultExpr}]');
END;
/

<#if (column.mandatory)>
COMMIT;

DECLARE
  L_ALREADY_NOTNULL EXCEPTION;
  PRAGMA EXCEPTION_INIT(L_ALREADY_NOTNULL, -01442);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE ${table.name} MODIFY ${column.name} NOT NULL';
EXCEPTION
  WHEN L_ALREADY_NOTNULL THEN NULL;
END;
/
</#if>


COMMENT ON COLUMN ${table.name}. ${column.name} IS q'[${column.comments!""}]';

<#if column.primary>
    <#assign primaryKeys=primaryKeys + column.name + ",">
</#if>

<#if (column.refTabColumn)??>

COMMIT;

begin
    DB_CONF.ADD_CONSTRAINT_IF_ABSENT(USER, '${table.name}', 'FK01_${table.name}_${column.name}',
    'FOREIGN KEY (${column.name}) REFERENCES ${column.refTabColumn.foreignTableName} (${column.refTabColumn.foreignTabColumnName})');
end;
/
</#if>

</#list>

<#assign primaryKeys=primaryKeys?remove_ending(",")>

<#if primaryKeys?has_content>
COMMIT;

begin
    DB_CONF.ADD_CONSTRAINT_IF_ABSENT(USER, '${table.name}', 'PK01_${table.name}', 'PRIMARY KEY (${primaryKeys})');
end;
/
</#if>

<#list table.constraints as constraint>
COMMIT;

begin
    DB_CONF.ADD_CONSTRAINT_IF_ABSENT(USER, '${table.name}', '${constraint.constraintName}', q'[${constraint.sqlExpression}]');
end;
/

</#list>

<#list table.indexes as index>

<#if index.unique>
    <#assign uniqueChar="1">
<#else>
    <#assign uniqueChar="0">
</#if>

COMMIT;

BEGIN
    DB_CONF.CREATE_INDEX_IF_ABSENT(USER, '${index.indexName}', q'[${index.sqlExpression}]', '${uniqueChar}');
END;
/


</#list>

<#if table.tableData.rows?has_content>
-- Filling data of table ${table.name}. Number of rows: ${table.tableData.rows?size}
<#else>
-- No rows for filling
</#if>

<#list table.tableData.rows as data>
BEGIN
    DB_CONF.GL_SYS_CU_REF(USER, '${table.name}', '${data.whereClass}', '${data.insertSql}', '${data.updateSql}');
END;
/
</#list>

