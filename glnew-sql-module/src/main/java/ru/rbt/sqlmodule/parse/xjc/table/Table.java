//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, v2.2.8-b130911.1802 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2015.09.08 at 01:10:04 PM MSK 
//


package ru.rbt.sqlmodule.parse.xjc.table;

import javax.xml.bind.annotation.*;


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
 *         &lt;element name="name" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="comments" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="columns" type="{www.sqlpatchbuilder.org/table}columnsType"/>
 *         &lt;element name="constraints" type="{www.sqlpatchbuilder.org/table}constraintsType" minOccurs="0"/>
 *         &lt;element name="indexes" type="{www.sqlpatchbuilder.org/table}indexesType" minOccurs="0"/>
 *         &lt;element name="data" type="{www.sqlpatchbuilder.org/table}dataType" minOccurs="0"/>
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
    "name",
    "comments",
    "columns",
    "constraints",
    "indexes",
    "data"
})
@XmlRootElement(name = "table")
public class Table {

    @XmlElement(required = true)
    protected String name;
    protected String comments;
    @XmlElement(required = true)
    protected ColumnsType columns;
    protected ConstraintsType constraints;
    protected IndexesType indexes;
    protected DataType data;

    /**
     * Gets the value of the name property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getName() {
        return name;
    }

    /**
     * Sets the value of the name property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setName(String value) {
        this.name = value;
    }

    /**
     * Gets the value of the comments property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getComments() {
        return comments;
    }

    /**
     * Sets the value of the comments property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setComments(String value) {
        this.comments = value;
    }

    /**
     * Gets the value of the columns property.
     * 
     * @return
     *     possible object is
     *     {@link ColumnsType }
     *     
     */
    public ColumnsType getColumns() {
        return columns;
    }

    /**
     * Sets the value of the columns property.
     * 
     * @param value
     *     allowed object is
     *     {@link ColumnsType }
     *     
     */
    public void setColumns(ColumnsType value) {
        this.columns = value;
    }

    /**
     * Gets the value of the constraints property.
     * 
     * @return
     *     possible object is
     *     {@link ConstraintsType }
     *     
     */
    public ConstraintsType getConstraints() {
        return constraints;
    }

    /**
     * Sets the value of the constraints property.
     * 
     * @param value
     *     allowed object is
     *     {@link ConstraintsType }
     *     
     */
    public void setConstraints(ConstraintsType value) {
        this.constraints = value;
    }

    /**
     * Gets the value of the indexes property.
     * 
     * @return
     *     possible object is
     *     {@link IndexesType }
     *     
     */
    public IndexesType getIndexes() {
        return indexes;
    }

    /**
     * Sets the value of the indexes property.
     * 
     * @param value
     *     allowed object is
     *     {@link IndexesType }
     *     
     */
    public void setIndexes(IndexesType value) {
        this.indexes = value;
    }

    /**
     * Gets the value of the data property.
     * 
     * @return
     *     possible object is
     *     {@link DataType }
     *     
     */
    public DataType getData() {
        return data;
    }

    /**
     * Sets the value of the data property.
     * 
     * @param value
     *     allowed object is
     *     {@link DataType }
     *     
     */
    public void setData(DataType value) {
        this.data = value;
    }

}
