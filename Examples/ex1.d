import SimpleXMLD.all;
import tango.io.Stdout;

void main ()
{
    SimpleXML rootNode   = new SimpleXML("root");
    rootNode.tag = "rootRenamed";

    SimpleXML childNode1 = new SimpleXML("child1");
    SimpleXML childNode2 = new SimpleXML("child2", "2");
    SimpleXML childNode3 = new SimpleXML("child3", "3");

    childNode1.data = "1";
    childNode1.setAttribute ("key1", "value1");
    childNode1.removeAttribute ("key1");

    XMLAttributes attrs = childNode1.attributes;
    attrs["key2"] = "value2";
    attrs["key3"] = "value3";

    attrs.remove ("key3");

    rootNode.appendChild (childNode3);
    rootNode.insertChild (childNode1);
    rootNode.insertChild (childNode2, 1);

    rootNode.removeChild (childNode2);

    Stdout (rootNode.formattedXMLText());
}
