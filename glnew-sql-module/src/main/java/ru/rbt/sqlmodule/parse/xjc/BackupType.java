//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, v2.2.8-b130911.1802 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2017.03.03 at 07:04:59 PM MSK
//


package ru.rbt.sqlmodule.parse.xjc;

import javax.xml.bind.annotation.*;


/**
 * <p>Java class for BackupType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="BackupType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="objectName" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="objectType" type="{www.sqlpatchbuilder.org}DbObjectType"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "BackupType", propOrder = {
    "objectName",
    "objectType"
})
public class BackupType {

    @XmlElement(required = true)
    protected String objectName;
    @XmlElement(required = true)
    @XmlSchemaType(name = "string")
    protected DbObjectType objectType;

    /**
     * Gets the value of the objectName property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getObjectName() {
        return objectName;
    }

    /**
     * Sets the value of the objectName property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setObjectName(String value) {
        this.objectName = value;
    }

    /**
     * Gets the value of the objectType property.
     * 
     * @return
     *     possible object is
     *     {@link DbObjectType }
     *     
     */
    public DbObjectType getObjectType() {
        return objectType;
    }

    /**
     * Sets the value of the objectType property.
     * 
     * @param value
     *     allowed object is
     *     {@link DbObjectType }
     *     
     */
    public void setObjectType(DbObjectType value) {
        this.objectType = value;
    }

}
