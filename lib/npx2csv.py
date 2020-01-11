'''
npx is not mpx; it's simplified

conditions
-no xml attributes
-no repeated elements (Wiederholfelder)

root/objects/aspects 

For SHF export, they want data in csv, i.e. dumbed down to one table

Right now it seems more efficient to write a separate little tool than to integrate this functionality
into tableData.

<npx>
    <sammlungsobjekt>
        <aspectA>bla</aspectA>
        <aspectB>blue<aspectB>
    

csv format
-columns in first row sorted alphabetically
-only distinct cnames allowed
-attributes in the format aspectBAttribute
-Wiederholfelder in colonList form, should already be part of source format
'''

_verbose=1
def verbose (msg):
    if _verbose: 
        print (msg)
        
import xml.etree.ElementTree as ET
import os
import csv

class Npx2csv:

    def __init__(self, infile, outfile):
        
        self.ns = {
            'npx': 'http://www.mpx.org/npx', #npx is no mpx
        }
        
        verbose ('Npx2csv: outfile %s' % outfile)
        
        self.tree = ET.parse(infile)
        columns=set() # distinct list for columns for csv table

        #Loop1: identify attributes
        for so in self.tree.findall("./npx:sammlungsobjekt", self.ns):
            for aspect in so.findall('*'):
                tag=aspect.tag.split('}')[1] 
                columns.add(tag)
    
        #lookup dialect in table tool
        with open(outfile, mode='w', newline='', encoding='utf-8') as csvfile:
            out = csv.writer(csvfile, dialect='excel')
            out.writerow(sorted(columns)) # headers
        #print (sorted(columns))

            for so in self.tree.findall('./npx:sammlungsobjekt', self.ns):
                #print (so)
                row=[]
                for aspect in sorted(columns):
                    element=so.find('./npx:'+aspect, self.ns)
                    if (element is not None):
                        print (aspect+':'+str(element.text)) 
                        row.append(element.text)
                    else:
                        row.append('')
                out.writerow(row) # headers
                    
    
        verbose ('csv written to %s' % outfile)



if __name__ == '__main__': 
    
    #import argparse
    #parser = argparse.ArgumentParser()
    #parser.add_argument('-i', '--input', required=True)
    #args = parser.parse_args()
   
    Npx2csv('data/WAF55/20190927/2-MPX/shf.xml', 'data/WAF55/20190927/2-MPX/shf.csv')     
