import SimpleXMLD.all;
import tango.io.Stdout;

void main ()
{
    SimpleXML root = SimpleXML.loadFile ("test.xml");
    
    foreach (SimpleXML node; root) {
        Stdout.format ("Lv1 Tag: {}", node.tag).newline;
        Stdout.format ("    Data:{}", node.data).newline;

        foreach (char [] key, char [] value; node.attributes) {
            Stdout.format ("    attr[{}]={}", key, value).newline;
        }
       Stdout.newline;
    }

    SimpleXML [] node = root["node"];
    for (int i = 0; i < node.length; i++) {
        Stdout (node[i].data).newline;
    }

    Stdout (root.formattedXMLText);
}
