/* -*- Mode: C++; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*-
 *
 * ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1/GPL 2.0/LGPL 2.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is mozilla.org code.
 *
 * The Initial Developer of the Original Code is
 * Netscape Communications Corporation.
 * Portions created by the Initial Developer are Copyright (C) 1999
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * Alternatively, the contents of this file may be used under the terms of
 * either the GNU General Public License Version 2 or later (the "GPL"), or
 * the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
 * in which case the provisions of the GPL or the LGPL are applicable instead
 * of those above. If you wish to allow use of your version of this file only
 * under the terms of either the GPL or the LGPL, and not to allow others to
 * use your version of this file under the terms of the MPL, indicate your
 * decision by deleting the provisions above and replace them with the notice
 * and other provisions required by the GPL or the LGPL. If you do not delete
 * the provisions above, a recipient may use your version of this file under
 * the terms of any one of the MPL, the GPL or the LGPL.
 *
 * ***** END LICENSE BLOCK ***** */
package com.netscape.jndi.ldap.schema;

import javax.naming.Binding;
import javax.naming.Context;
import javax.naming.Name;
import javax.naming.NameClassPair;
import javax.naming.NamingEnumeration;
import javax.naming.NamingException;
import javax.naming.OperationNotSupportedException;
import javax.naming.directory.Attributes;
import javax.naming.directory.DirContext;
import javax.naming.directory.ModificationItem;

public abstract class SchemaElementContainer extends SchemaDirContext {

    SchemaManager m_schemaMgr;

    public SchemaElementContainer(SchemaManager schemaMgr, String path) throws NamingException{
        m_schemaMgr = schemaMgr;
        m_path = path;
    }

    /**
     * Create a new SchemaElement. Called by craeteSubcontext
     */
    abstract DirContext createSchemaElement(String name, Attributes attrs) throws NamingException;

    /**
     * Delete a new SchemaElement. Called by destroySubcontext
     */
    abstract void removeSchemaElement(String name) throws NamingException;

    /**
     * Return a list of names for subordinate SchemaElement. Called by list()
     */
    abstract NamingEnumeration<NameClassPair> getNameList(String name) throws NamingException;

     /**
     * Return a list of bindings for subordinate SchemaElement. Called by
     * listBindings()
     */
    abstract NamingEnumeration<Binding> getBindingsList(String name) throws NamingException;

    /**
     * Get a SchemaElement by name
     */
    abstract Object lookupSchemaElement(String name) throws NamingException;


    /**
     * Attribute Operations
     */
    public Attributes getAttributes(String name) throws NamingException {

        SchemaDirContext schemaElement = (SchemaDirContext)lookup(name);
        if (schemaElement == this) {
            throw new OperationNotSupportedException("No Attributes for " + m_path);
        }
        else {
            return schemaElement.getAttributes("");
        }
    }

    public Attributes getAttributes(String name, String[] attrIds) throws NamingException {
        SchemaDirContext schemaElement = (SchemaDirContext)lookup(name);
        if (schemaElement == this) {
            throw new OperationNotSupportedException("No Attributes for " + m_path);
        }
        else {
            return schemaElement.getAttributes("", attrIds);
        }
    }

    public Attributes getAttributes(Name name) throws NamingException {
        return getAttributes(name.toString());
    }

    public Attributes getAttributes(Name name, String[] attrIds) throws NamingException {
        return getAttributes(name.toString(), attrIds);
    }

    public void modifyAttributes(String name, int mod_op, Attributes attrs) throws NamingException {
        SchemaDirContext schemaElement = (SchemaDirContext)lookup(name);
        if (schemaElement == this) {
            throw new OperationNotSupportedException("No Attributes for " + m_path);
        }
        else {
            schemaElement.modifyAttributes("", mod_op, attrs);
        }
    }

    public void modifyAttributes(String name, ModificationItem[] mods) throws NamingException {
        SchemaDirContext schemaElement = (SchemaDirContext)lookup(name);
        if (schemaElement == this) {
            throw new OperationNotSupportedException("No Attributes for " + m_path);
        }
        else {
            schemaElement.modifyAttributes("", mods);
        }
    }

    public void modifyAttributes(Name name, int mod_op, Attributes attrs) throws NamingException {
        modifyAttributes(name.toString(), mod_op, attrs);
    }

    public void modifyAttributes(Name name, ModificationItem[] mods) throws NamingException {
        modifyAttributes(name.toString(), mods);
    }

    /**
     * Ldap entry operations
     */

    public Context createSubcontext(String name) throws NamingException {
        // Directory entry must have attributes
        throw new OperationNotSupportedException();
    }

    public Context createSubcontext(Name name) throws NamingException {
        // Directory entry must have attributes
        throw new OperationNotSupportedException();
    }

    public DirContext createSubcontext(String name, Attributes attrs) throws NamingException {
        return createSchemaElement(name, attrs);
    }

    public DirContext createSubcontext(Name name, Attributes attrs) throws NamingException {
        return createSubcontext(name.toString(), attrs);
    }

    public void destroySubcontext(String name) throws NamingException {
        removeSchemaElement(name);
    }

    public void destroySubcontext(Name name) throws NamingException {
        destroySubcontext(name.toString());
    }

    /**
     * Naming Bind operations
     */

    public void bind(String name, Object obj) throws NamingException {
        if (obj instanceof DirContext) {
            createSubcontext(name, ((DirContext)obj).getAttributes(""));
        }
        else {
            throw new IllegalArgumentException("Can not bind this type of object");
        }
    }

    public void bind(Name name, Object obj) throws NamingException {
        bind(name.toString(), obj);
    }

    public void rebind(String name, Object obj) throws NamingException {
        throw new OperationNotSupportedException();
    }

    public void rebind(Name name, Object obj) throws NamingException {
        throw new OperationNotSupportedException();
    }

    public void rename(String oldName, String newName) throws NamingException {
        throw new OperationNotSupportedException();
    }

    public void rename(Name oldName, Name newName) throws NamingException {
        throw new OperationNotSupportedException();
    }

    public void unbind(String name) throws NamingException {
        destroySubcontext(name);
    }

    public void unbind(Name name) throws NamingException {
        destroySubcontext(name);
    }

    /**
     * List Operations
     */

    public NamingEnumeration<NameClassPair> list(String name) throws NamingException {
        return getNameList(name);
    }

    public NamingEnumeration<NameClassPair> list(Name name) throws NamingException {
        return list(name.toString());
    }

    public NamingEnumeration<Binding> listBindings(String name) throws NamingException {
        return getBindingsList(name);
    }

    public NamingEnumeration<Binding> listBindings(Name name) throws NamingException {
        return listBindings(name.toString());
    }

    /**
     * Lookup Operations
     */

    public Object lookup(String name) throws NamingException {
        return lookupSchemaElement(name);
    }

    public Object lookup(Name name) throws NamingException {
        return lookup(name.toString());
    }

    public Object lookupLink(String name) throws NamingException {
        throw new OperationNotSupportedException();
    }

    public Object lookupLink(Name name) throws NamingException {
        throw new OperationNotSupportedException();
    }
}
