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
 * This module handles tree structure of an XML. Every node in XML is
 * represented by an SimpleXMLT object.
 *
 * SimpleXMLT is an template class that represent an XML by tree 
 * structure, you could traverse this tree as normal XML structure.
 *
 * We have following default alias for using convenience.
 * -----------------------------------------------------------------
 * alias SimpleXMLT!(char)  SimpleXML;
 * alias SimpleXMLT!(dchar) DSimpleXML;
 * alias SimpleXMLT!(wchar) WSimpleXML;
 * -----------------------------------------------------------------
 *
 * Note: 
 *
 * For this API Documention and the code itselt, we will use String as 
 * a type to indicate of D string(char [], dchar [] or wchar[]).
 * 
 * And we will use SimpleXML to indicate SimpleXMLT!(char) for less
 * typing and easier to understand.
 *
 * They was defined as:
 * -----------------------------------------------------------------
 * alias T [] String;
 * alias SimpleXMLT!(T) SimpleXML;
 * -----------------------------------------------------------------
 *
 * The main class of this module is SimpleXMLT!(T), we used template
 * to overcome encoding problems.
 * 
 * Using SimpleXML to read a XML file and traverse the XML document 
 * tree is very simple, all you need to do is call a function to read
 * XML from disk, and it will construct XML tree for you.
 *
 * For Example:
 *
 * 1. Loading XML file from disk.
 * -----------------------------------------------------------------
 * // Load "test.xml" from disk
 * SimpleXML root = SimpleXML.loadFile ("test.xml");
 *
 * // We first print out everyting, it is generated by SimpleXML tree,
 * // not original file.
 * Stdout (root.formattedXMLText);
 * -----------------------------------------------------------------
 * 
 * 2. Iterate over all children node.
 * -----------------------------------------------------------------
 * foreach (SimpleXML node; root) {
 *     Stdout.format ("Tag: {}", node.tag).newline;
 *     Stdout.format ("Data:{}", node.data).newline;
 *
 *     SimpleXML [] grandson = node.child;
 *     Stdout.format ("We have {} children", grandson.length).newline;
 *
 *     // Iterate over child's attribute
 *     foreach (char [] key, char [] value; node.attributes) {
 *         Stdout.format ("    attr[{}]={}", key, value).newline;
 *     }
 * }
 * ----------------------------------------------------------------
 *
 * 3. Get children which XML tag is named "tagname"
 * ----------------------------------------------------------------
 * SimpleXML [] node = root["tagname"];
 *
 * for (int i = 0; i < node.length; i++) {
 *     // Do something here.
 * }
 * ----------------------------------------------------------------
 *
 * 4. You could also use this module to build whole new XML document.
 * ----------------------------------------------------------------
 * // Create an root node object
 * SimpleXML root = new SimpleXML ("root");
 *
 * // Create first child node object
 * SimpleXML node = new SimpleXML ("node1", "text");
 *
 * // Add an attribute to the first child node.
 * node.setAttribute ("key", "value");
 *
 * // Append node as root's child
 * root.appendChild (node);
 *
 * // Create anotoer child node object and append it to root.
 * node = new SimpleXML ("node2");
 * root.appendChild (node);
 *
 * // Create an grandson child
 * node.appendChild (new SimpleXML("grandson"));
 *
 * // Output as XML text
 * Stdout (root.formattedXMLText);
 * ----------------------------------------------------------------
 *
 * Will generate following output:
 * ----------------------------------------------------------------
 * <root>
 *     <node1 key="value">text</node1>
 *     <node2>
 *         <grandson />
 *     </node>
 * </root>
 * ----------------------------------------------------------------
 * See_Also: <a href="XMLAttributes.html">XMLAttributes</a>,
 *           <a href="XMLException.html">XMLException</a>
 *
 * Copyright: Copyright (C) 2007 Brian Hsu.  All rights reserved.
 * License:   <a href="http://www.gnu.org/licenses/lgpl-3.0.txt">GNU LGPL</a>.
 *
 * Authors:   Brian Hsu
 * Version:   0.0.2
 */
module SimpleXMLD.SimpleXML;

//=================================================================
// Private import section for internal use.
//=================================================================

private import SimpleXMLD.XMLAttributes;
private import SimpleXMLD.XMLException;

private import mango.xml.sax.model.ISAXParser;
private import mango.xml.sax.model.ISAXHandler;
private import mango.xml.sax.parser.teqXML;
private import mango.xml.sax.DefaultSAXHandler;

private import tango.io.Stdout;
private import tango.io.FileConduit;
private import tango.text.convert.Sprint;
private import tango.io.Buffer;
private import Utf = tango.text.convert.Utf;

//=================================================================
// Public class for SimpleXML Model.
//=================================================================

/******************************************************************
 * This class represents XML as a tree sturcure and has an static
 * function read XML file and generate corresponding tree structure
 * of SimpleXML model.
 *****************************************************************/
class SimpleXMLT(T = char)
{
    //=============================================================
    // Alias for internal use.
    //=============================================================
    private alias T [] String;
    private alias SimpleXMLT!(T) SimpleXML;
    private alias XMLAttributesT!(T) XMLAttributes;

    //=============================================================
    // XML Tree Strucutre
    //=============================================================
    private SimpleXML     mParent;
    private SimpleXML []  mChild;

    //=============================================================
    // XML Node Data
    //=============================================================
    private String mTag;
    private String mData;
    private XMLAttributes mAttributes;

    //=============================================================
    // Constrouctors
    //=============================================================

    public this (String tag, String data = null) 
    {
        this.mTag = tag;
        this.mData = data;
        this.mAttributes = new XMLAttributes();
    }

    //=============================================================
    // Property Getter
    //=============================================================

    /**
     * Get parent of this node.
     *
     * Returns:
     *    the parent node or null if this node is root.
     */
    public SimpleXML parent () 
    {
        return this.mParent;
    }

    /**
     * Get children nodes of this node.
     *
     * Returns:
     *    An array of SimpleXML which have all children of
     *    this node.
     */
    public SimpleXML [] child () 
    {
        return this.mChild;
    }

    /**
     * Get XML tag name of this node.
     */
    public String tag  () 
    {
        return this.mTag;
    }

    /**
     * Get XML text data of this node.
     *
     * Returns:
     *    the text data or null if this node has no text data.
     */
    public String data () 
    {
        return this.mData;
    }

    /**
     * Get XML Attributes of this node.
     */
    public XMLAttributes attributes () 
    {
        return this.mAttributes;
    }

    /**
     * Wether this node is root node of XML.
     */
    public bool isRoot () 
    {
        // It's a root node if it has no parent.
        return (this.mParent is null);
    }

    //=============================================================
    // Property Setter
    //=============================================================

    /**
     * Set XML tag name of this node.
     *
     * Params:
     *   tag = XML tag name to be set.
     */
    String tag  (String tag) 
    {
        return this.mTag = tag;
    }

    /**
     * Set text data of this node.
     *
     * Example:
     * --------------------------------------------------------------
     * SimpleXML node = new SimpleXML ("node");
     * node.data = "123";
     * --------------------------------------------------------------
     *
     * Will generate following XML:
     * --------------------------------------------------------------
     * <node>123></node>
     * --------------------------------------------------------------
     *
     * Params:
     *     data = text data should be set.
     *
     * Throws:
     *     AssertFailure when this node has children.
     */
    String data (String data) 
    in
    {
        // If there are children, this node can't have any text data.
        assert (this.child.length == 0);
    }
    body
    {
        return this.mData = data;
    }

    //=============================================================
    // Operator Overloading
    //=============================================================

    /**
     * Operator overloading for syntax auto node = node["childname"], 
     * it will return all children which XML tag is "childname" as 
     * array of SimpleXMLT!(T) [].
     *
     * Params:
     *    tag = children's XML tag.
     *
     * Throws:
     *    XMLNodeNotFound when there is no child node named by tag.
     */
    SimpleXML [] opIndex (String tag)
    {
        SimpleXML [] child;

        foreach (SimpleXML target; this.mChild) {
            if (target.mTag == tag) {
                child ~= target;
            }
        }

        if (child.length == 0) {
            throw new XMLNodeNotFound (this.mTag);
        }

        return child;
    }

    /**
     * Operator overloading for foreach statment, so you could
     * iterate over all children node of this node.
     *
     * For Example:
     * -------------------------------------------------------
     * foreach (SimpleXML child; node) {
     *     Stdout.format ("tag:{}", child.tag);
     * }
     * -------------------------------------------------------
     */
    public int opApply (int delegate(ref SimpleXML) dg) 
    {
        int result;

        foreach (SimpleXML node; this.mChild) {
            result = dg (node);

            if ( result )
                break;
        }

        return result;
    }

    //=============================================================
    // XML Tree building function
    //=============================================================

    /**
     * Append a child node to this node. You should confirm that 
     * this node doesn't have text data since this is XML.
     *
     * Params:
     *    node = The child node to be set.
     *
     * Throws:
     *    AssertError if this node has text data.
     */
    public SimpleXML appendChild (SimpleXML node) 
    in
    {
        assert (this.mData is null);
    }
    out
    {
        assert (this.mChild[this.mChild.length-1] == node);
    }
    body
    {
        int last = (this.mChild.length = this.mChild.length + 1) - 1;

        this.mChild[last] = node;
        node.mParent = this;

        return this;
    }
    
    /**
     * Insert a child node to this node at certain position. 
     * You should confirm that this node doesn't have text data 
     * since this is XML.
     *
     * Params:
     *    node     = The child node to be set.
     *    position = The position to insert.
     *
     * Throws:
     *    AssertError if this node has text data.
     */
    public SimpleXML insertChild (SimpleXML node, int position = 0) 
    in
    {
        assert (this.mData is null);
    }
    out
    {
        assert (this.mChild[position] == node);
    }
    body
    {
        // Add space of this.mChild and get last index.
        int last = (this.mChild.length = this.mChild.length + 1) - 1;

        // Move all node after position
        for (int i = last; i > position; i--) {
            this.mChild[i] = this.mChild[i-1];
        }

        // Insert new node.
        this.mChild[position] = node;
        node.mParent = this;

        return this;
    }

    /**
     * Remove a child node. You should confirm that this node 
     * doesn't have text data and has children.
     *
     * Params:
     *    target = The child node to be removed.
     *
     * Throws:
     *    AssertError     if this node has text data or it has no children.
     *
     *    XMLNodeNotFound if the target node is not child of this node.
     */
    public SimpleXML removeChild (SimpleXML target) 
    in
    {
        // Current node must have child and has no text data.
        assert (this.mData is null);
        assert (this.mChild.length > 0);
    }
    body
    {
        bool found = false;
        SimpleXML [] newChild;

        foreach (SimpleXML node; this.mChild) {

            if ( node == target ) {
                found = true;
                continue;
            }

            int index = (newChild.length = newChild.length + 1) - 1; 
            newChild[index] = node;
        }

        if ( !found ) {
            throw new XMLNodeNotFound(target.tag);
        }

        this.mChild = newChild;

        return this;
    }

    //=============================================================
    // XML Attribute method
    //=============================================================

    /**
     * Create an attribute or set orignal attribute to new value.
     *
     * If key doesn't exist in current node, it will create an new
     * attributes.
     *
     * Params:
     *    key   = XML name of the attribute.
     *    value = The value you to be set.
     * 
     * Throws:
     *    AssertError if key or value is null.
     */
    public SimpleXML setAttribute (String key, String value) 
    in
    {
        assert (key);
        assert (value);
    }
    body
    {
        this.mAttributes[key] = value;
        return this;
    }

    /**
     * Remove attribute named by key.
     *
     * If key doesn't exist in current node, nothing will happen.
     *
     * Params:
     *    key   = XML name of the attribute to be removed.
     *
     * Throws:
     *    AssertError if key is null.
     */
    public SimpleXML removeAttribute (String key)
    in
    {
        assert (key);
    }
    body
    {
        this.mAttributes.remove (key);
        return this;
    }

    //=============================================================
    // XML Output
    //=============================================================

    /**
     * Convert this tree to XML string using this node as root.
     *
     * Params:
     *     indentLevel = Default indent level
     *     indentSpace = How many space use in an indent.
     */
    public String formattedXMLText (int indentLevel = 0, int indentSpace = 4)
    {
        // Indent function
        auto sprint = new Sprint!(T);

        String indent (int level)
        {
            String result;

            for (int i = 0; i < level * indentSpace; i++) {
                result ~= " ";
            }

            return result;
        }

        // The result is here.
        String document;

        // Is this node a self closed node?
        bool empty = !(this.mChild.length != 0 || this.mData);

        // Opening tag
        document ~= sprint.format ("{}<{}", indent(indentLevel), mTag);

        // Attributes
        foreach (String key, String value; this.mAttributes) {
            document ~= sprint.format (" {}=\"{}\"", key, value);
        }

        // Text data
        if (!empty)      {document ~= ">";}
        if (this.mData)  {document ~= sprint.format ("{}", this.mData);};
        if (this.mChild) {document ~= "\n";}

        // Children node
        foreach (SimpleXML child; this.mChild) {
            document ~= child.formattedXMLText (indentLevel+1);
        }

        // Closing tag
        if (this.mChild) {document ~= indent (indentLevel);}

        document ~= (empty) ? sprint.format ("/>\n") : 
                              sprint.format ("</{}>\n", mTag);

        return document;
    }

    //=============================================================
    // Static util function
    //=============================================================

    /**
     * Read XML file from disk and create corresponding tree strucure
     * of SimpleXML model.
     *
     * Bugs:
     *
     *  Can't read XML file contain Unicode literal, it will cause
     *  mango.xml produce array index out of bound exception.
     *
     *  For example, following XML will not work with this parser.
     *  -------------------------------------------------------------
     *  <node>This is unicode: &#211; character</node>
     *  -------------------------------------------------------------
     *
     * Params:
     *     filename = The filename of XML file to be read.
     *
     * Returns:
     *  The root node of the document.
     *
     * Throws:
     *  XMLParseException if XML parsing is faild.
     */
    public static SimpleXML loadFile (char [] filename)
    {
        SimpleXML root;

        ISAXReader!(T) reader  = new XMLReader!(T);
        SAXHandler!(T) handler = new SAXHandler!(T);

        FileConduit file = new FileConduit (filename);

        try {
            reader.parse (file, handler);
            root = handler.buildXMLTree ();
        } catch (Exception e) {
            
            auto sprint = new Sprint!(char);
            char [] msg = sprint.format ("Error: {} when parse {}", e, 
                                         filename);

            throw new XMLParseException (msg);

        } finally{
            file.close ();
        }

        return root;
    }

    /**
     * Read XML file from String and create corresponding tree strucure
     * of SimpleXML model.
     *
     * Bugs:
     *
     *  Can't read XML file contain Unicode literal, it will cause
     *  mango.xml produce array index out of bound exception.
     *
     *  For example, following XML will not work with this parser.
     *  -------------------------------------------------------------
     *  <node>This is unicode: &#211; character</node>
     *  -------------------------------------------------------------
     *
     * Params:
     *     xml = The XML string literal to be read.
     *
     * Returns:
     *  The root node of the document.
     *
     * Throws:
     *  XMLParseException if XML parsing is faild.
     */
    public static SimpleXML loadString (char [] xml)
    {
        SimpleXML root;

        Buffer buffer = new Buffer(xml);
        buffer.flush();

        ISAXReader!(T) reader  = new XMLReader!(T);
        SAXHandler!(T) handler = new SAXHandler!(T);

        try {
            reader.parse (buffer, handler);
            root = handler.buildXMLTree ();
        } catch (Exception e) {
            auto sprint = new Sprint!(char);
            char [] msg = sprint.format ("Error: {} when parse:\n{}", e, 
                                         xml);

            throw new XMLParseException (msg);
        }

        return root;
    }

    // Not implement yet.
    /+
    public SimpleXML [] xpath (String query)
    {
        SimpleXML [] result;
        return result;
    }
    +/
}

//=================================================================
// Default type alias for convenience
//=================================================================
alias SimpleXMLT!(char)  SimpleXML;
alias SimpleXMLT!(dchar) DSimpleXML;
alias SimpleXMLT!(wchar) WSimpleXML;

//=================================================================
// Private class for interal XML Stream parser.
//=================================================================
private class SAXHandler(T): DefaultSAXHandler!(T)
{
    alias T [] String;
    alias SimpleXMLT!(T) SimpleXML;

    //=============================================================
    // Define Type to indicate current token is which type of XML
    // element.
    //=============================================================
    enum Type 
    {
        START,      // Tag opening
        END,        // Tag closing
        ATTRIBUTE,  // XML attribute
        DATA        // XML text data
    };

    //=============================================================
    // Define a simple queue which store all XML token.
    //=============================================================
    private Token [] tokens;

    struct Token
    {
        Type type;      // Token type
        String key;     // Tag name or attribute name
        String value;   // Text data or attribute value
    }

    // Create an token at push it into tokens array.
    private void push (Type type, String key, String value)
    {
        Token token;
        token.type  = type;
        token.key   = (key)   ? key.dup   : null;
        token.value = (value) ? value.dup : null;

        tokens.length = tokens.length+1;
        tokens[tokens.length-1] = token;
    }

    //=============================================================
    // ISAXHandler interface.
    //
    // It just push all XML token into Data.stack, the main 
    // construction will be handled by buildXMLTree()
    //
    // We sperate this as two sperate because it may be a failure
    // when reading XML file.
    //
    // Since we used an array of structure as an buffer, it pareser
    // is aborted by an error, instead of cleanup all SimpleXML 
    // object we have created, we just let GC to cleanup the tokens
    // array.
    //
    // This should avoid memroy leak when read XML is faild, if I
    // misunderstand D's GC/Array/Structure, please correct me.
    //=============================================================
    public void startElement (String name) 
    {
        push (Type.START, name, null);
    }

    public void endElement (String name) 
    {
        push (Type.END, name, null);
    }

    public void addAttribute(String key, String value) 
    {
        push (Type.ATTRIBUTE, key, value);
    }

    public void characterData (String data, CDataStatus status) 
    {
        push (Type.DATA, null, data);
    }

    //=============================================================
    // Main construction work will do in here.
    //
    // We just iterate over all XML token and create corresponding
    // object and build the tree structure.
    //
    // It will return root node of XML document. 
    //=============================================================
    package SimpleXML buildXMLTree ()
    {
        SimpleXML root = null;   // Document root, return value
        SimpleXML parent = null; // Parent node
        SimpleXML node = null;   // Current node

        foreach (Token token; this.tokens) {
            switch ( token.type ) {
                case Type.START:
                    
                    node = new SimpleXML (token.key);

                    if ( root is null )
                        root = node;

                    if ( parent )
                        parent.appendChild (node);

                    parent = node;
                    break;

                case Type.ATTRIBUTE:
                    node.setAttribute (token.key, token.value);
                    break;

                case Type.DATA:
                    node.data = token.value;
                    break;

                case Type.END:
                    parent = node.parent;

                default:
            }
        }
        return root;
    }
}

//=================================================================
// Unit test for construct a whole new XML tree.
//=================================================================
unittest
{
    Stdout ("=== SimpleXMLD for constructing XML ===").newline;

    SimpleXML rootNode   = new SimpleXML("root");
    rootNode.tag = "rootRenamed";
    assert (rootNode.isRoot);

    SimpleXML childNode1 = new SimpleXML("child1");
    SimpleXML childNode2 = new SimpleXML("child2", "2");
    SimpleXML childNode3 = new SimpleXML("child3", "3");

    childNode1.data = "1";
    childNode1.setAttribute ("key1", "value1");
    childNode1.removeAttribute ("key1");

    XMLAttributes attrs = childNode1.attributes;
    attrs["key2"] = "value2";
    attrs["key3"] = "value3";

    assert (attrs.length == 2);
    attrs.remove ("key3");
    assert (attrs.length == 1);

    rootNode.appendChild (childNode3);
    rootNode.insertChild (childNode1);
    rootNode.insertChild (childNode2, 1);

    assert (!childNode1.isRoot);
    assert (!childNode2.isRoot);
    assert (!childNode3.isRoot);

    assert (rootNode.child.length == 3);

    rootNode.removeChild (childNode2);
    assert (rootNode.child.length == 2);

    Stdout (rootNode.formattedXMLText());
    Stdout ("======= End of constructing XML =======\n").newline;
}

//=================================================================
// Unit test for read a XML file and build the tree structure.
//=================================================================
unittest
{
    Stdout ("=== SimpleXMLD For parse XML ===").newline;

    SimpleXML root = SimpleXML.loadFile ("test.xml");
    
    foreach (SimpleXML node; root) {
        Stdout.format ("Lv1 Tag: {}", node.tag).newline;
        Stdout.format ("    Data:{}", node.data).newline;

        foreach (char [] key, char [] value; node.attributes) {
            Stdout.format ("    attr[{}]={}", key, value).newline;
        }
    }

    assert (root.isRoot);

    SimpleXML [] node = root["node"];

    assert (node.length == 2);
    for (int i = 0; i < 2; i++) {
        assert (!node[i].isRoot);
        assert (node[i].attributes.length == 1);
        assert (node[i].tag == "node");
    }

    Stdout (root.formattedXMLText);

    Stdout ("======= End of parse XML =======\n").newline;
}

//=================================================================
// Unit test for read XML from string and build the tree structure.
//=================================================================

unittest
{
    char [] xml = "<root><node>text</node></root>";

    SimpleXML s = SimpleXML.loadString (xml);
    Stdout (s.formattedXMLText).newline;
}