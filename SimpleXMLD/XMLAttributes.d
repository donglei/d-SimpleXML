/*====================================================================
  This file is part of SimpleXMLD.

  SimpleXMLD is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  SimpleXMLD is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with SimpleXMLD.  If not, see <http://www.gnu.org/licenses/>.
  ==================================================================*/

/**
 * This module handles attributes of an XML Node.
 *
 * XMLAttributesT is an class template which represent attributes lik
 * an associative array. We use template is in order to solve encoding
 * problem.
 *
 * We have following default alias for using convenience.
 * -----------------------------------------------------------------
 * alias XMLAttributesT!(char)  XMLAttributes;
 * alias XMLAttributesT!(dchar) DXMLAttributes;
 * alias XMLAttributesT!(wchar) WXMLAttributes;
 * -----------------------------------------------------------------
 *
 * Note:
 *
 * For this API Documention and the code itselt, we will use String as 
 * a type to indicate of D string(char [], dchar [] or wchar[]).
 * 
 * And we will use XMLAttributes to indicate XMLAttributesT!(char) for 
 * less typing and easier to understand.
 *
 * They was defined as:
 * -----------------------------------------------------------------
 * alias T [] String;
 * alias XMLAttributes!(T) XMLAttributes;
 * -----------------------------------------------------------------
 *
 * Using this module is just like using an associative array, the
 * following is some example.
 *
 * Note: You should never to try create instance of XMLAttribute by
 * keyword new, since it should not exist without an XML node.
 * -----------------------------------------------------------------
 * XMLAttributes attr = new XMLAttributes(); // Compile Error
 * -----------------------------------------------------------------
 *
 * Instead of create an instance by new, always get attributes from 
 * a node:
 * -----------------------------------------------------------------
 * XMLAttributes attrs = node.attributes; 
 * -----------------------------------------------------------------
 *
 * Add new attributes to node:
 * -----------------------------------------------------------------
 * attrs["key1"] = "value1"; // <node key1="value1" />
 * attrs["key2"] = "value2"; // <node key1="value1" key2="value2" />
 * -----------------------------------------------------------------
 *
 * Iterate over all key/value attribute pair:
 * -----------------------------------------------------------------
 * foreach (char [] key, char [] value; attrs) {
 *     Stdout ("{}:{}", key, value).newline;
 * }
 * -----------------------------------------------------------------
 *
 * It will throw an AttributeNotFound exception if the attribute key
 * is not found.
 * -----------------------------------------------------------------
 * try {
 *     char [] value = attrs["key3"];
 * }
 * catch (AttributeNoFound e) {
 *     // Got here if no attribute named "key3"
 * }
 * -----------------------------------------------------------------
 *
 * Copyright: Copyright (C) 2007 Brian Hsu.  All rights reserved.
 * License:   <a href="http://www.gnu.org/licenses/lgpl-3.0.txt">GNU LGPL</a>.
 *
 * Authors:   Brian Hsu
 * Version:   0.0.2
 *
 * See_Also:  <a href="SimpleXML.html">SimpleXML</a>, 
 *            <a href="XMLException.html">XMLException</a>
 */

module SimpleXMLD.XMLAttributes;

private import SimpleXMLD.XMLException;

private import Array = tango.core.Array;
private import tango.io.Stdout;

/**
 * XMLAttributesT represent attributes by acting like associative array.
 *
 */
public class XMLAttributesT(T = char)
{
    // For internal use convince.
    private alias T [] String;

    private String [String] content; // associtave array of XML attributes.
    package this () {}               // Instance should never created by user.

    /**
     * Get the number of attributes this node has.
     *
     * Returns: The number of attributes the node has.
     */
    public int length () 
    {
        return this.content.length;
    }
    
    /**
     * Remove specfic attribute in the node
     *
     * Params: 
     *    key = The name of attribute you want to delete.
     */
    public void remove (String key) 
    {
        this.content.remove (key);
    }

    /**
     * This is an operator overloading of a["key"] = "value", 
     * so your colud use XMLAttributes as an associative 
     * array.
     *
     * For example, the following code:
     * --------------------------------------------------
     * SimpleXML node = new SimpleXML ("node");
     * XMLAttributes attrs = node.attributes;
     * attrs["key"] = "value";
     * --------------------------------------------------
     *
     * It will generate the following XML structure:
     *
     * --------------------------------------------------
     * <node key="value" />
     * --------------------------------------------------
     */
    public int opIndexAssign (String value, String key)
    in
    {
        // key must not be null.
        assert (key);
    }
    body
    {
        this.content[key] = value;
        return 0;
    }

    /**
     * This is an operator overloading of a["key"], so your 
     * colud use XMLAttributes as an associative array.
     *
     * Throws: 
     *
     * It will throw an AttributeNotFound exception if there
     * is no attribute named by key.
     */
    public String opIndex (String key)
    {
        String result = null;

        if ( Array.find(this.content.keys, key) ) {
            result = this.content[key];
        }

        if (result is null) {
            throw new XMLAttributeNotFound (key);
        }

        return result;
    }

    /**
     * This is an operator overloading for foreach statement
     * use. With this overloading, you could use foreach to
     * iterate all attributes of the node.
     *
     * For example:
     * -----------------------------------------------------
     * auto attrs = node.attributes;
     * foreach (String key, String value; attrs) {
     *     Stdout ("{}:{}", key, value).newline;
     * }
     * -----------------------------------------------------
     */
    public int opApply (int delegate(ref String, ref String) dg) 
    {
        int result;

        foreach (String key, value; this.content) {
            result = dg (key, value);

            if ( result )
                break;
        }

        return result;
    }

}

unittest
{
    Stdout ("==== Unit testing of XMLAttributes =====").newline;
    alias char [] String;
    
    XMLAttributes attributes = new XMLAttributes();

    attributes["key1"] = "key1";
    attributes["key2"] = "key2";

    // Now we should have 2 attributes.
    assert (attributes.length == 2);

    // Print out everyting.
    Stdout ("Before remove anyting:").newline;
    foreach (String key, String value; attributes) {
        Stdout.format ("attributes[{}] = {}", key, value).newline;
    }

    Stdout ("Remove key1:").newline;
    attributes.remove ("key1");

    // We should have only one attribute now
    assert (attributes.length == 1);
    foreach (String key, String value; attributes) {
        Stdout.format ("attributes[{}] = {}", key, value).newline;
    }
 
    Stdout ("Remove key2:").newline;
    attributes.remove ("key2");

    // We should have no attribute now
    assert (attributes.length == 0);
    foreach (String key, String value; attributes) {
        Stdout.format ("attributes[{}] = {}", key, value).newline;
    }

    Stdout ("==== End testing of XMLAttributes =====\n").newline;
}

alias XMLAttributesT!(char)  XMLAttributes;
alias XMLAttributesT!(dchar) DXMLAttributes;
alias XMLAttributesT!(wchar) WXMLAttributes;
