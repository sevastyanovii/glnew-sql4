package ru.rbt.sqlmodule.bean;

import ru.rbt.sqlmodule.parse.xjc.Item;
import ru.rbt.sqlmodule.parse.xjc.RollbackActionType;

import java.io.File;
import java.util.List;

/**
 * Created by Ivan Sevastyanov
 */
public class FileItem {

    public enum ItemType {
        FILE, INLINE, TABLE
    }

    private final String itemName;
    private final ItemType itemType;
    private final File file;
    private final String itemString;
    private List<BackupObject> backupObjects;
    private OnSqlError onSqlError;
    private Item patchItem;

    public FileItem(String itemName, ItemType itemType, File file, String itemString, OnSqlError onSqlError) {
        this.itemName = itemName;
        this.itemType = itemType;
        this.file = file;
        this.itemString = itemString;
        this.onSqlError = onSqlError;
    }

    public FileItem(Item patchItem, ItemType itemType, File tempFile) {
        this(patchItem.getItemName(), itemType, tempFile, patchItem.getFile()
                , new OnSqlError(patchItem.getOnSqlError()));
        this.patchItem = patchItem;
    }

    public String getItemName() {
        return itemName;
    }

    public ItemType getItemType() {
        return itemType;
    }

    public File getFile() {
        return file;
    }

    public String getItemString() {
        return itemString;
    }

    public List<BackupObject> getBackupObjects() {
        return backupObjects;
    }

    public FileItem setBackupObjects(List<BackupObject> backupObjects) {
        this.backupObjects = backupObjects;
        return this;
    }

    public boolean isExitOnError() {
        return onSqlError.isExit();
    }

    public boolean isContinueOnError() {
        return onSqlError.isContinue();
    }

    public RollbackActionType getRollbackType() {
        return patchItem.getRollback();
    }
}
