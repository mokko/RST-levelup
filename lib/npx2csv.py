'''
npx is not mpx; it's simplified

conditions
-no xml attributes
-no repeated elements (Wiederholfelder) 

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

VERBOSE=1
import xml.etree.ElementTree as ET
import os

class Npx2Csv:

    def __init__(self, infile):
        
        outfile=os.path.splitext(args.input)[0]+'.csv'
        print ('npx2csv: outfile %s' % outfile)
        
        tree = ET.parse(infile)
        columns=set() # distinct list for columns for csv table
    
        for elem in tree.iter('{http://www.mpx.org/npx}sammlungsobjekt'):
    
            for each in 'objId', 'exportdatum':
                #record[each]=elem.attrib[each]
                columns.add(each)
    
            for aspect in elem.findall('*'):
                aspectNoNS=aspect.tag.split("}")[1]
                columns.add(aspectNoNS)
    
                for param in aspect.attrib:
                    paramNotation=aspectNoNS+param[0].upper()+param[1:]
                    columns.add(paramNotation)
    
        print (sorted(columns))

        for elem in tree.iter('{http://www.mpx.org/npx}sammlungsobjekt'):
            print ('_____________________________')
            for col in sorted(columns):
                #for aspect in elem.find(col):
                print (col)  
                    
    def writeCsv (self,outfile):
        ''' Writes table to file in csv format:
            self.writeCSV (outfile)
        
        Values with commas are quoted. Output is UTF-8 
        '''
        import csv
        self._outTest(outfile)
    
        with open(outfile, mode='w', newline='', encoding='utf-8') as csvfile:
            out = csv.writer(csvfile, dialect='excel')
            for r in range(0, self.nrows()):
                row=self.table[r]               
                out.writerow(row)
    
        self.verbose ('csv written to %s' % outfile)



if __name__ == '__main__': 
    
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input', required=True)
    args = parser.parse_args()
   
    obj=Npx2Csv(args.input)     
