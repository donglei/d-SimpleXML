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
 *
 * SimpleXMLD is an simple XML parser for 
 * <a href="http://www.digitalmars.com/d/">D Programming Language</a> 
 * inspired by PHP's SimpleXML, this libary could help you read XML file
 * and traverse XML structure as an node tree in RAM.
 *
 * It is suitable when your XML file is small, and you just want quickly
 * access those data in XML easily.
 *
 * Website:
 * The <a href="http://dsource.org/projects/simplexmld">official website of 
 * SimpleXMLD</a> is hosting on <a href="http://dsource.org">DSource</a>, 
 * you colud find more documents and a forum there.
 *
 * Requirement: 
 * You will need <a href="http://dsource.org/projects/tango">Tango</a> 
 * and <a href="http://dsource.org./projects/mango">Mango</a> to build 
 * this libary, since we use mango.xml as interanl XML file parser, 
 * instead of writng a new one. 
 *
 * <a href="http://dsource.org/projects/dsss">DSSS</a> also may help you 
 * install those libary mush easier.
 *
 * Download:
 * You may download current version (0.0.2) as 
 * <a href="SimpleXMLD-0.0.2.zip">ZIP archive</a> or 
 * <a href="SimpleXMLD-0.0.2.tar.gz">tar.gz archive</a>.
 *
 * Installation:
 *
 * If you are already using Tango as your D runtime and had installed
 * DSSS, please first install mango by typing following command at 
 * command line window:
 * ------------------------------------------------------------------
 * dsss net install mango
 * ------------------------------------------------------------------
 *
 * When mango installtion is done, all you need to do is copy the
 * SimpleXMLD folder in the libary archive to D's include folder where
 * DSSS could find them.
 *
 * Usage:
 *
 * If you installed DSS/Tango/Mango successfully, then it should be 
 * able to use SimpleXMLD now, just import SimpleXMLD.all.
 * ------------------------------------------------------------------
 * // Filename: test.d
 *
 * import SimpleXMLD.all;
 * void main ()
 * {
 *     // Load XML from disk file.
 *     SimpleXML root = SimpleXML.loadFile ("test.xml");
 *
 *     // Print out XML text constructed by SimpleXML objec tree.
 *     Stdout (root.formattedXMLText);
 *
 *     // Iterate over all first level child
 *     foreach (SimpleXML node; root) {
 *     }
 *
 *     // Iterate over all first level child which XML tag is "tagname"
 *     foreach (SimpleXML node; root["tagname"]) {
 *     }
 * }
 * ------------------------------------------------------------------
 * More examples could be found in <a href="SimpleXML.html">SimpleXML</a> 
 * API document.
 *
 * Compile:
 *
 * If you already have DSSS/Tango/Mango, it should be very easy to
 * compile source code that use SimpleXMLD, just follow normal dsss
 * build process:
 * ------------------------------------------------------------------
 * dsss build test.d
 * ------------------------------------------------------------------
 * DSSS should compile and link your source code successfully now. 
 *
 * See_Also:
 * For detail, please see <a href="SimpleXML.html">SimpleXML</a>,
 * <a href="XMLAttributes.html">XMLAttributes</a>, and 
 * <a href="XMLException.html">XMLException</a> these API documents.
 *
 * Copyright: Copyright (C) 2007 Brian Hsu.  All rights reserved.
 * License:   <a href="http://www.gnu.org/licenses/lgpl-3.0.txt">GNU LGPL</a>.
 *
 * Authors:   Brian Hsu
 * Version:   0.0.2
 *
 * See_Also:  <a href="SimpleXML.html">SimpleXML</a>, 
 *            <a href="XMLAttributes.html">XMLAttributes</a>,
 *            <a href="XMLException.html">XMLException</a>
 */

module SimpleXMLD.all;

public import SimpleXMLD.SimpleXML,
              SimpleXMLD.XMLException,
              SimpleXMLD.XMLAttributes;
