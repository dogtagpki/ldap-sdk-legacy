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
package org.ietf.ldap.client;

import org.ietf.ldap.ber.stream.BERElement;
import org.ietf.ldap.ber.stream.BEROctetString;
import org.ietf.ldap.ber.stream.BERSequence;

/**
 * This class implements the attribute value assertion.
 * This object is used with filters.
 * <pre>
 * AttributeValueAssertion ::= SEQUENCE {
 *   attributType AttributeType,
 *   attributValue AttributeValue
 * }
 * </pre>
 *
 * @version 1.0
 */
public class JDAPAVA {
    /**
     * Internal variables
     */
    protected String m_type = null;
    protected String m_val = null;

    /**
     * Constructs the attribute value assertion.
     * @param type attribute type
     * @param val attribute value
     */
    public JDAPAVA(String type, String val) {
        m_type = type;
        m_val = val;
    }

    /**
     * Retrieves the AVA type.
     * @return AVA type
     */
    public String getType() {
        return m_type;
    }

    /**
     * Retrieves the AVA value.
     * @return AVA value
     */
    public String getValue() {
        return m_val;
    }

    /**
     * Retrieves the ber representation.
     * @return ber representation
     */
    public BERElement getBERElement() {
        BERSequence seq = new BERSequence();
        seq.addElement(new BEROctetString(m_type));

        seq.addElement(JDAPFilterOpers.getOctetString(m_val));

        return seq;
    }

    /**
     * Retrieves the string representation parameters.
     * @return string representation parameters
     */
    public String getParamString() {
        return "{type=" + m_type + ", value=" + m_val + "}";
    }

    /**
     * Retrieves the string representation.
     * @return string representation
     */
    public String toString() {
        return "JDAPAVA " + getParamString();
    }
}
