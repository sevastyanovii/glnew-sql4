//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, v2.2.8-b130911.1802 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2017.03.03 at 07:04:59 PM MSK
//


package ru.rbt.sqlmodule.parse.xjc;

import javax.xml.bind.annotation.XmlRegistry;


/**
 * This object contains factory methods for each 
 * Java content interface and Java element interface 
 * generated in the ru.rbt.sqlmodule.parse.xjc package. 
 * <p>An ObjectFactory allows you to programatically 
 * construct new instances of the Java representation 
 * for XML content. The Java representation of XML 
 * content can consist of schema derived interfaces 
 * and classes representing the binding of schema 
 * type definitions, element declarations and model 
 * groups.  Factory methods for each of these are 
 * provided in this class.
 * 
 */
@XmlRegistry
public class ObjectFactory {


    /**
     * Create a new ObjectFactory that can be used to create new instances of schema derived classes for package: ru.rbt.sqlmodule.parse.xjc
     * 
     */
    public ObjectFactory() {
    }

    /**
     * Create an instance of {@link Dbpaths }
     * 
     */
    public Dbpaths createDbpaths() {
        return new Dbpaths();
    }

    /**
     * Create an instance of {@link Item }
     * 
     */
    public Item createItem() {
        return new Item();
    }

    /**
     * Create an instance of {@link BackupType }
     * 
     */
    public BackupType createBackupType() {
        return new BackupType();
    }

    /**
     * Create an instance of {@link RollbackActionType }
     * 
     */
    public RollbackActionType createRollbackActionType() {
        return new RollbackActionType();
    }

    /**
     * Create an instance of {@link Versions }
     * 
     */
    public Versions createVersions() {
        return new Versions();
    }

    /**
     * Create an instance of {@link Release }
     * 
     */
    public Release createRelease() {
        return new Release();
    }

    /**
     * Create an instance of {@link ApplyedToType }
     * 
     */
    public ApplyedToType createApplyedToType() {
        return new ApplyedToType();
    }

    /**
     * Create an instance of {@link Trunk }
     * 
     */
    public Trunk createTrunk() {
        return new Trunk();
    }

}
