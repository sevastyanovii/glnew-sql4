//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, v2.2.8-b130911.1802 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2017.03.03 at 06:51:14 PM MSK
//


package ru.rbt.sqlmodule.parse.xjc;

import javax.xml.bind.annotation.*;
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
 *         &lt;element name="module" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="version" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="applyedTo" type="{www.sqlpatchbuilder.org}applyedToType"/>
 *         &lt;element name="defaultSchema" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element ref="{www.sqlpatchbuilder.org}dbpaths" minOccurs="0"/>
 *         &lt;element ref="{www.sqlpatchbuilder.org}item" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "module",
    "version",
    "applyedTo",
    "defaultSchema",
    "dbpaths",
    "item"
})
@XmlRootElement(name = "release")
public class Release {

    @XmlElement(required = true)
    protected String module;
    @XmlElement(required = true)
    protected String version;
    @XmlElement(required = true)
    protected ApplyedToType applyedTo;
    @XmlElement(required = true)
    protected String defaultSchema;
    protected Dbpaths dbpaths;
    protected List<Item> item;

    /**
     * Gets the value of the module property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getModule() {
        return module;
    }

    /**
     * Sets the value of the module property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setModule(String value) {
        this.module = value;
    }

    /**
     * Gets the value of the version property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getVersion() {
        return version;
    }

    /**
     * Sets the value of the version property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setVersion(String value) {
        this.version = value;
    }

    /**
     * Gets the value of the applyedTo property.
     * 
     * @return
     *     possible object is
     *     {@link ApplyedToType }
     *     
     */
    public ApplyedToType getApplyedTo() {
        return applyedTo;
    }

    /**
     * Sets the value of the applyedTo property.
     * 
     * @param value
     *     allowed object is
     *     {@link ApplyedToType }
     *     
     */
    public void setApplyedTo(ApplyedToType value) {
        this.applyedTo = value;
    }

    /**
     * Gets the value of the defaultSchema property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDefaultSchema() {
        return defaultSchema;
    }

    /**
     * Sets the value of the defaultSchema property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDefaultSchema(String value) {
        this.defaultSchema = value;
    }

    /**
     * Gets the value of the dbpaths property.
     * 
     * @return
     *     possible object is
     *     {@link Dbpaths }
     *     
     */
    public Dbpaths getDbpaths() {
        return dbpaths;
    }

    /**
     * Sets the value of the dbpaths property.
     * 
     * @param value
     *     allowed object is
     *     {@link Dbpaths }
     *     
     */
    public void setDbpaths(Dbpaths value) {
        this.dbpaths = value;
    }

    /**
     * Gets the value of the item property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the item property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getItem().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Item }
     * 
     * 
     */
    public List<Item> getItem() {
        if (item == null) {
            item = new ArrayList<Item>();
        }
        return this.item;
    }

}
