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
package com.netscape.jndi.ldap;

import javax.naming.directory.Attributes;
import javax.naming.directory.SearchResult;
import javax.naming.ldap.Control;
import javax.naming.ldap.HasControls;

/**
 * An extension of SearchResult that allows access to controls sent
 * back with the results of a search
 */
class SearchResultWithControls extends SearchResult implements HasControls {

    Control[] m_ctrls;

    /**
     * Enable constructors
     */
    public SearchResultWithControls(String name, Object obj, Attributes attrs) {
        super(name, obj, attrs);
    }

    public SearchResultWithControls(String name, Object obj, Attributes attrs, boolean isRelative) {
        super(name, obj, attrs, isRelative);
    }

    public SearchResultWithControls(String name, String className, Object obj, Attributes attrs) {
        super(name, className, obj, attrs);
    }

    public SearchResultWithControls(String name, String className, Object obj, Attributes attrs, boolean isRelative) {
        super(name, className, obj, attrs, isRelative);
    }

    /**
     * Implements HasControls interface
     */
    public Control[] getControls() {
        return m_ctrls;
    }

    /**
     * Set controls array
     */
    public void setControls(Control[] ctrls) {
        m_ctrls = ctrls;
    }
}
