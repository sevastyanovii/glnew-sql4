//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, v2.2.8-b130911.1802 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2015.09.08 at 01:10:04 PM MSK 
//


package ru.rbt.sqlmodule.parse.xjc.table;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for foreignType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="foreignType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="foreignTableName" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="foreignTabColumnName" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "foreignType", propOrder = {
    "foreignTableName",
    "foreignTabColumnName"
})
public class ForeignType {

    @XmlElement(required = true)
    protected String foreignTableName;
    @XmlElement(required = true)
    protected String foreignTabColumnName;

    /**
     * Gets the value of the foreignTableName property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getForeignTableName() {
        return foreignTableName;
    }

    /**
     * Sets the value of the foreignTableName property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setForeignTableName(String value) {
        this.foreignTableName = value;
    }

    /**
     * Gets the value of the foreignTabColumnName property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getForeignTabColumnName() {
        return foreignTabColumnName;
    }

    /**
     * Sets the value of the foreignTabColumnName property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setForeignTabColumnName(String value) {
        this.foreignTabColumnName = value;
    }

}
