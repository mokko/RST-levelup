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
        lock_fn="3-lido/lido.lock"
        if os.path.exists(lock_fn):
            print ("Lock file exists, no overwrite") 
        else:
            self._write_lock(lock_fn)
            s=Saxon(self.saxon) #lib is where my xsl files are, so a short cut
            xsl_fn=os.path.join (self.lib, "mpx2lido.xsl")
            #seem to need asyncio to see progressing output as usual and capturing it
            #s.dirTransform("2-MPX/vfix.mpx", xsl_fn, "3-lido/o.lido", "3-lido/report.log")
            s.dirTransform("2-MPX/vfix.mpx", xsl_fn, "3-lido/o.lido")
    
    def validate (self, id=None):
        """validate all lido files"""

        print("VALIDATING LIDO")
        if not hasattr(self, "lido_xsd"):
            self.lido_xsd=os.path.join(self.lib, 'lido-v1.0.xsd')
    
        schema_doc = etree.parse(self.lido_xsd)
        schema = etree.XMLSchema(schema_doc)

        if id is not None:
            path=f"3-lido/{id}.lido"
            self._validate(schema, path)
        else:
            print("GLOBBING")
            for path in glob.iglob("3-lido/*.lido", recursive=True):
                self._validate(schema, path)
        print ("*ok")
    
    def _validate (self, schema, path):
        print(f"*Validating {path}")
        doc = etree.parse(path)
        schema.assert_(doc)
        
    def html (self, id=None):
        """write html version of all lido files"""

        print(f"LIDO INTO HTML {id}")

        if id:
            path = f"3-lido/{id}.lido"
            self._mk_html(path)
        else:
            for path in glob.iglob("3-lido/*.lido", recursive=True):
                self._mk_html(path)

    def datenblatt (self, id=None): 
        print(f"LIDO INTO DATENBLATT {id}")
        if id:
            path = f"3-lido/{id}.lido"  
            self._mk_datenblatt(path, True)
        else:
            for path in glob.iglob("3-lido/*.lido", recursive=True):
                self._mk_datenblatt(path)

    def all (self):
        lm.transform()
        lm.validate()
        lm.html()
        lm.datenblatt()

    def daemon (self):
        print ("Going into never-ending daemon mode")
        while (1>0):
            lm.all()

#private stuff

    def _mk_datenblatt (self, path, overwrite=False):
        s=Saxon(self.saxon) 
        xsl_fn=os.path.join (self.lib, "lido2datenblatt.xsl")
        base=os.path.basename(path)
        out=f"3-lido/{base}.blatt.html"
        if overwrite is True and os.path.exists(out):
            os.unlink(out)
        s.dirTransform(path, xsl_fn, out)

    def _mk_html(self, path,overwrite=False):
        """
        current problems: 
        - this step is not in numeric objId, but rather in string order 
        objId/12345789
        - it's pretty slow to transform individual liko files like this, since
        I fire up separate a saxon process for every lido file
        """
        s=Saxon(self.saxon) 
        xsl_fn = os.path.join (self.lib, "lido2html.xsl")
        base = os.path.basename(path)
        new = f"{base}.html"
        if not os.path.exists(new) or overwrite is True:
            s.dirTransform(path, xsl_fn, new) 

    def _write_lock (self, path):
        f = open(path, "w")
        f.write("")
        f.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='mpx2lido gismo')
    parser.add_argument('-d', '--datenblatt', action='store_true')
    parser.add_argument('-D', '--daemon', action='store_true')
    parser.add_argument('-H', '--html', action='store_true')
    parser.add_argument('-m', '--make', action='store_true')
    parser.add_argument('-v', '--validate', action='store_true')
    parser.add_argument('-i', '--id', default=None)

    args = parser.parse_args()
    lm=LidoMaker(lib, saxon)

    if args.datenblatt:
        lm.datenblatt(args.id)
    elif args.daemon:
        lm.daemon()
    elif args.html:
        lm.html(args.id)
    elif args.make:
        lm.transform()
    elif args.validate:
        lm.validate(args.id)
    else: 
        print ("Doing all steps")
        lm.all()
