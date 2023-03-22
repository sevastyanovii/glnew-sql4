//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, v2.2.8-b130911.1802 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2018.12.25 at 07:29:27 PM GMT+03:00 
//


package ru.rbt.sqlmodule.parse.xjc;

import javax.xml.bind.annotation.*;
import javax.xml.bind.annotation.adapters.CollapsedStringAdapter;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;
import java.util.ArrayList;
import java.util.List;


/**
 * <p>Java class for anonymous complex type.
 *
 * <p>The following schema fragment specifies the expected content contained within this class.
 *
 * <pre>
 * &lt;complexType>
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;choice>
 *           &lt;element name="file" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *           &lt;element name="body" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *           &lt;element name="table" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;/choice>
 *         &lt;element name="backup" type="{www.sqlpatchbuilder.org}BackupType" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element name="onSqlError" type="{www.sqlpatchbuilder.org}OnSqlErrorType" minOccurs="0"/>
 *         &lt;element name="rollback" type="{www.sqlpatchbuilder.org}RollbackActionType" minOccurs="0"/>
 *       &lt;/sequence>
 *       &lt;attribute name="itemName" use="required" type="{http://www.w3.org/2001/XMLSchema}ID" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 *
 *
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "file",
    "body",
    "table",
    "backup",
    "onSqlError",
    "rollback"
})
@XmlRootElement(name = "item")
public class Item {

    protected String file;
    protected String body;
    protected String table;
    protected List<BackupType> backup;
    @XmlSchemaType(name = "string")
    protected OnSqlErrorType onSqlError;
    protected RollbackActionType rollback;
    @XmlAttribute(name = "itemName", required = true)
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlID
    @XmlSchemaType(name = "ID")
    protected String itemName;

    /**
     * Gets the value of the file property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFile() {
        return file;
    }

    /**
     * Sets the value of the file property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFile(String value) {
        this.file = value;
    }

    /**
     * Gets the value of the body property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getBody() {
        return body;
    }

    /**
     * Sets the value of the body property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setBody(String value) {
        this.body = value;
    }

    /**
     * Gets the value of the table property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTable() {
        return table;
    }

    /**
     * Sets the value of the table property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTable(String value) {
        this.table = value;
    }

    /**
     * Gets the value of the backup property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the backup property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getBackup().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link BackupType }
     * 
     * 
     */
    public List<BackupType> getBackup() {
        if (backup == null) {
            backup = new ArrayList<BackupType>();
        }
        return this.backup;
    }

    /**
     * Gets the value of the onSqlError property.
     * 
     * @return
     *     possible object is
     *     {@link OnSqlErrorType }
     *     
     */
    public OnSqlErrorType getOnSqlError() {
        return onSqlError;
    }

    /**
     * Sets the value of the onSqlError property.
     * 
     * @param value
     *     allowed object is
     *     {@link OnSqlErrorType }
     *     
     */
    public void setOnSqlError(OnSqlErrorType value) {
        this.onSqlError = value;
    }

    /**
     * Gets the value of the rollback property.
     * 
     * @return
     *     possible object is
     *     {@link RollbackActionType }
     *     
     */
    public RollbackActionType getRollback() {
        return rollback;
    }

    /**
     * Sets the value of the rollback property.
     * 
     * @param value
     *     allowed object is
     *     {@link RollbackActionType }
     *     
     */
    public void setRollback(RollbackActionType value) {
        this.rollback = value;
    }

    /**
     * Gets the value of the itemName property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getItemName() {
        return itemName;
    }

    /**
     * Sets the value of the itemName property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setItemName(String value) {
        this.itemName = value;
    }

}
