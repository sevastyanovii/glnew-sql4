package ru.rbt.sqlmodule.bean;

/**
 * Created by Ivan Sevastyanov on 26.12.2018.
 */
public class RollbackScript {

    private final int counter;
    private final String itemName;
    private final String rollbackBody;


    public RollbackScript(int counter, String itemName, String rollbackBody) {
        this.counter = counter;
        this.itemName = itemName;
        this.rollbackBody = rollbackBody;
    }

    public String getItemName() {
        return itemName;
    }

    public String getRollbackBody() {
        return rollbackBody;
    }

    public int getCounter() {
        return counter;
    }
}
