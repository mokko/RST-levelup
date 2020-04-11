import glob
import os 
import sys
#import argparse
from lxml import etree

lib=os.path.realpath(os.path.join(__file__,'../../lib'))
sys.path.append (lib)
from Saxon import Saxon

if os.getlogin() == 'User':
    saxon= "C:/Program Files/Saxonica/SaxonHE9.9N/bin/Transform.exe",
elif os.getlogin() == 'mauri':
    saxon= "C:/Program Files/Saxonica/SaxonHE9.9N/bin/Transform.exe",

#print(f"lib:{lib}")

def transform (saxon):
    print("*TRANSFORMING TO LIDO")
    s=Saxon(saxon) #lib is where my xsl files are, so a short cut
    xsl_fn=os.path.join (lib, "mpx2lido.xsl")
    #seem to need asyncio to see progressing output as usual and capturing it
    #s.dirTransform("2-MPX/vfix.mpx", xsl_fn, "3-lido/o.lido", "3-lido/report.log")
    s.dirTransform("2-MPX/vfix.mpx", xsl_fn, "3-lido/o.lido") 

def validate (lib):
    print("VALIDATING LIDO")
    lido_xsd=os.path.join(lib, 'lido-v1.0.xsd')

    schema_doc = etree.parse(lido_xsd)
    schema = etree.XMLSchema(schema_doc)

    print("GLOBBING")
    for path in glob.iglob("3-lido/*.lido", recursive=True):
        print(f"*Validating {path}")
        doc = etree.parse(path)
        schema.assert_(doc)
    print ("*ok")


if __name__ == "__main__":
    transform(saxon)
    validate(lib)
       