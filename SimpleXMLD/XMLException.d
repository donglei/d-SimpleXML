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
 * This module defined SimpleXML specfic exception, XMLAttributesNotFound
 * and XMLNode not found.
 *
 * Copyright: Copyright (C) 2007 Brian Hsu.  All rights reserved.
 * License:   <a href="http://www.gnu.org/licenses/lgpl-3.0.txt">GNU LGPL</a>.
 *
 * Authors:   Brian Hsu
 * Version:   0.0.2
 *
 * See_Also:  <a href="SimpleXML.html">SimpleXML</a>, 
 *            <a href="XMLAttributes.html">XMLAttributes</a>
 *
 */
module SimpleXMLD.XMLException;

private import tango.text.convert.Sprint;

/**
 * This exception will be throw when you try to read an attributes
 * which does not exist in current node.
 */
class XMLAttributeNotFound: Exception
{
    public this (char [] key) {
        super ("Attribute '" ~ key ~ "' not found.");
    }

    public this (dchar [] key) {
        super ("Attribute '" ~ cast(char [])key ~ "' not found.");
    }

    public this (wchar [] key) {
        super ("Attribute '" ~ cast(char [])key ~ "' not found.");
    }
}

/**
 * This exception will be throw when you try to access an XML node
 * which does not exist.
 */
class XMLNodeNotFound: Exception
{
    public this (char [] tag) {
        super ("Node '" ~ tag ~ "' not found.");
    }

    public this (dchar [] tag) {
        super ("Node '" ~ cast(char [])tag ~ "' not found.");
    }

    public this (wchar [] tag) {
        super ("Node '" ~ cast(char [])tag ~ "' not found.");
    }
}

/**
 * This exception will be throw when parsing XML file or XML 
 * literal is faild.
 */
public class XMLParseException : Exception
{
    public this (char [] msg)  {
        super (msg);
    }
}
