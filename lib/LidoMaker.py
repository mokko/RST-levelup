import argparse
import glob
from lxml import etree
import os 
import sys

lib=os.path.realpath(os.path.join(__file__,'../../lib'))
sys.path.append (lib)
from Saxon import Saxon

if os.getlogin() == 'User':
    saxon= "C:/Program Files/Saxonica/SaxonHE9.9N/bin/Transform.exe",
elif os.getlogin() == 'mauri':
    saxon= "C:/Program Files/Saxonica/SaxonHE9.9N/bin/Transform.exe",

#print(f"lib:{lib}")
class LidoMaker:
    def __init__ (self, lib, saxon):
        self.lib=lib
        self.saxon=saxon

    def transform (self):
        """from mpx to lido"""
    
        print("TRANSFORMING TO LIDO")
        s=Saxon(self.saxon) #lib is where my xsl files are, so a short cut
        xsl_fn=os.path.join (self.lib, "mpx2lido.xsl")
        #seem to need asyncio to see progressing output as usual and capturing it
        #s.dirTransform("2-MPX/vfix.mpx", xsl_fn, "3-lido/o.lido", "3-lido/report.log")
        s.dirTransform("2-MPX/vfix.mpx", xsl_fn, "3-lido/o.lido") 
    
    def validate (self):
        """validate all lido files"""
        print("VALIDATING LIDO")
        lido_xsd=os.path.join(self.lib, 'lido-v1.0.xsd')
    
        schema_doc = etree.parse(lido_xsd)
        schema = etree.XMLSchema(schema_doc)
    
        print("GLOBBING")
        for path in glob.iglob("3-lido/*.lido", recursive=True):
            print(f"*Validating {path}")
            doc = etree.parse(path)
            schema.assert_(doc)
        print ("*ok")
    
    def html (self):
        """write html version of all lido files"""
        print("REWRITING LIDO FILES IN HTML TABLE")
        s=Saxon(self.saxon) 
        xsl_fn=os.path.join (self.lib, "lido2html.xsl")
    
        for path in glob.iglob("3-lido/*.lido", recursive=True):
            base=os.path.basename(path)
            new=f"{base}.html"
            print (new)
            #s.dirTransform(path, xsl_fn, new)
    
    def datenblatt (self): 
        print("REWRITING LIDO FILES AS DATENBLATT")
        s=Saxon(self.saxon) 
        xsl_fn=os.path.join (self.lib, "lido2datenblatt.xsl")
        for path in glob.iglob("3-lido/*.lido", recursive=True):
            base=os.path.basename(path)
            out=f"3-lido/{base}.blatt.html"
            s.dirTransform(path, xsl_fn, out)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--datenblatt', action='store_true')
    parser.add_argument('-H', '--html', action='store_true')
    parser.add_argument('-m', '--make', action='store_true')
    parser.add_argument('-v', '--validate', action='store_true')

    args = parser.parse_args()
    lm=LidoMaker(lib, saxon)

    if args.datenblatt is True:
        lm.datenblatt()
    elif args.html is True:
        lm.html()
    elif args.make is True:
        lm.transform()
    elif args.validate is True:
        lm.validate()
    else: #all
        lm.transform()
        lm.validate()
        lm.html()
        lm.datenblatt()
       