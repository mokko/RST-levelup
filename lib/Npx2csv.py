"""Converts npx to csv

npx is not mpx; it's simplified

conditions
-no xml attributes
-no repeated elements (Wiederholfelder)
-qualifier are written in field in pre or post position
x
For SHF export, they want data in csv, now two table

<npx>
    <sammlungsobjekt>
        <aspectA>bla</aspectA>
        <aspectB>blue<aspectB>
    

csv format
-columns in first row sorted alphabetically
-only distinct column names allowed
-attributes written inside the fields or consecutive order aspectBAttribute
"""

_verbose=1
def verbose (msg):
    if _verbose: 
        print (msg)
        
import xml.etree.ElementTree as ET
import os
#import os.path
from os import path
import csv

class Npx2csv:

    def __init__(self, infile):
        
        self.ns = {
            'npx': 'http://www.mpx.org/npx', #npx is no mpx
        }
        
        self.tree = ET.parse(infile)
        
        cmd={
            'shf/shf-so.csv': 'npx:sammlungsobjekt',
            'shf/shf-mm.csv': 'npx:multimediaobjekt'
        }
        
        for each in cmd:
            self.write_csv (each, cmd[each])

    def write_csv (self, outfile, xpath):
        if os.path.exists(outfile):
            print (f"Outfile exists already, nothing overwritten: {outfile}")
            return
        columns = set() # distinct list for columns for csv table

        #Loop1: identify attributes
        for so in self.tree.findall(f"./{xpath}", self.ns):
            for aspect in so.findall('*'):
                tag=aspect.tag.split('}')[1] 
                columns.add(tag)
        #verbose (sorted (columns))
        with open(outfile, mode='w', newline='', encoding='utf-8') as csvfile:
            out = csv.writer(csvfile, dialect='excel')
            out.writerow(sorted(columns)) # headers
            #print (sorted(columns))

            for so in self.tree.findall(f"./{xpath}", self.ns):
                row=[]
                for aspect in sorted(columns):
                    element=so.find('./npx:'+aspect, self.ns)
                    if (element is not None):
                        #print (aspect+':'+str(element.text)) 
                        row.append(element.text)
                    else:
                        row.append('')
                out.writerow(row) # headers
        verbose (f"csv written to {outfile}")

if __name__ == '__main__': 
    #import argparse
    #parser = argparse.ArgumentParser()
    #parser.add_argument('-i', '--input', required=True)
    #args = parser.parse_args()
   
    Npx2csv('shf/shf.xml')
