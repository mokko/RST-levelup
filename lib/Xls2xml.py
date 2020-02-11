# -- coding: utf-8 --
from datetime import datetime, timezone
import glob
import os
import shutil
import re 
import sys
import xlrd
import xlrd.sheet

from xlrd.sheet import ctype_text
import xml.etree.ElementTree as ET #not yet working with lxml
from Generic import Generic

verbose = 1

'''
Mainly convert export data from xls into simple generic xml. The xml should be formally correct xml, but
it may contain false multiples and other quirks. This object expects certain filenames as input files. Those
are defined in the configuration.

Input comes from current working directory; output is written to current working directory's subdirectories 
based on configuration.

NOTE
- Empty tags are not written. Hence it is not necessarily possible to convert from the xml back to the xls.
- mulId, objId and kueId are written as index in record/@attrib form and then omitted from result as features.
- record tag (multimediaobjekt, sammlungsobjekt, personKörperschaft) is written depending in input file (so.xsl,pk.xsl, mm.xsl)
- add exportdatum is added to record tag; date when script was run is provided. Note that the older perl version provided
  the modification date of source file (which is typically older than the run date). 
- no namespaces. mpx namespace will be added later (using xslt).
- tags/features have lowercased initial.
- tags/features are sorted alphabetically
- records without index are not included
- records are sorted 
    1. alphabetically (first multimediaobjekt, then personKörperschaft, then sammlungsobjekt)
    2. by ascending index
    3. features are sorted alphabetically 

SYNOPSIS

    o=Xls2xml(conf)
    o.mv2Zero()
    o.transformAll()

XML Format / Nomenclature

RECORDSs
There are three types of records:
multimediaobjekt, personKörperschaft, sammlungsobjekt

Records describe entities (medeia, people and organisations, objects).    
    
INDEX
@mulId functions as index for multimediaobjekt
@kueId functions as index for personKörperschaft
@objId functions as index for sammlungsobjekt

Records without index are not included in export.

FEATURES
Subelements of the records are called features.

Features are all spelled with lowercase camel spelling: e.g.
    camelIsTheWayToGo.

Features are sorted alphabetically.

QUALIFIERS 
Qualifiers are fields that describe a feature (rather an entity). This script writes "stupid" mpx where qualifiers
are written next to the feature they belong to. 

<geoBezug>Egpyt</geoBezug>
<geoBezugArt>country</geoBezugArt>

LEVELLING UP OR CLEAN FORMAT
Another transformation, called levelup, will produce two significant changes:
a. Qualifiers are written as xml attributes:
    <geoBezug art="country">Egypt</geoBezug>

b. repeated values (Wiederholfelder) will be written in a single record:

    Dirty or stupid version:
        <sammlungsobject objId="1">
            <geoBezug>Egpyt</geoBezug>
            <geoBezugArt>country</geoBezugArt>
        </sammlungsobjekt>
        
        <sammlungsobject objId="1">
            <geoBezug>Cairo</geoBezug>
            <geoBezugArt>city</geoBezugArt>
        </sammlungsobjekt>
    
    Level 2 or clean version:
        <sammlungsobject objId="1">
            <geoBezug art="country">Egypt</geoBezug>
            <geoBezug art="country">Egypt</geoBezug>
        </sammlungsobject>

'''

class Xls2xml (Generic):
    def __init__ (self, conf): 
        self.conf=conf


    def mv2zero (self):    
        for infile in glob.glob ('*.xls'):
            self.mkdir (self.conf['zerodir']) # only mkdir if a file exists
            #print (infile)
            if os.path.isfile(infile):
                print ('moving %s to %s' % (infile, self.conf['zerodir']))
                #TODO: error messages
                shutil.move(infile, self.conf['zerodir']) # is it possible to overwrite a file like this?


    def transformAll (self):
        for infile in glob.glob (self.conf['zerodir']+'/*.xls'):
            self.mkdir (self.conf['onedir']) #mkdir only if input file exists
            print ('Looking for %s' % infile)
            outfile=self.conf['onedir']+'/'+os.path.basename(infile[:-4] + '.xml')
            #print ('outfile %s' % outfile)

            if os.path.isfile(outfile):
                print ("%s exists already, no overwrite" % outfile)
            else:
                if os.path.isfile(infile):
                    self.transPerFile(infile, outfile) 


    '''Called on a per file basis from transformAll'''
    def transPerFile(self, infile, outfile):
        self.mtime=os.path.getmtime(infile)
        wb = xlrd.open_workbook(filename=infile, on_demand=True)
        sheet= wb.sheet_by_index(0)
                       
        root = ET.Element("museumPlusExport", attrib={'version':'2.0', 'level':'dirty', }) 
        tree = ET.ElementTree(root)

        columns =[sheet.cell(0, c).value for c in range(sheet.ncols)]

        base=os.path.basename(infile)

        #print ("%s -> %s" % (infile, tag))
        #invalid xml characters: will be stripped
        remove_re = re.compile(u'[\x00-\x08\x0B-\x0C\x0E-\x1F\x7F]')

        for r in range(1, sheet.nrows): #leave out column headers
            if re.match('so',base, re.I):
                tag="sammlungsobjekt"
                attrib='objId'
    
            elif re.match('pk',base, re.I):
                tag="personKörperschaft"
                attrib='kueId'
    
            elif re.match('mm',base, re.I):
                tag="multimediaobjekt"
                attrib='mulId'
 
            elif re.match('aus',base, re.I):
                tag="ausstellung"
                attrib='ausId'
            else:
                print ("Error: Unknown file %s" % infile)
                sys.exit(1)

            index=sheet.cell (r,columns.index(attrib)).value
            if index:
                    index=str(int(index))

            if index != '': # Dont include rows without meaningful index
                t=datetime.fromtimestamp(self.mtime, timezone.utc)
                doc = ET.SubElement(root, tag, attrib={attrib:index, 'exportdatum':str(t)}) 
                print ("INDEX: %s" % index) #should this become verbose?

                row_dict={}

                for c in range(sheet.ncols):
                    cell = sheet.cell(r, c) 
                    cellTypeStr = ctype_text.get(cell.ctype, 'unknown type')
                    tag=sheet.cell(0,c).value
                    tag=tag[0].lower() + tag[1:] #I want lowercase initial for all element names
                    
                    tag=re.sub(r'\W|&|<|>|:','',tag) # xml spec: strip illegal chars for elements
                    if re.search(r'\A[0-9]', tag):
                        raise ValueError("XML spec doesn't allow elements to begin with numbers")
                    #type conversions
                    if cellTypeStr == "number":
                        #val=int(float(cell.value)) 
                        val=int(cell.value)
                        #print ("number:%s" % val)
                        
                    elif cellTypeStr == "xldate":
                        val=xlrd.xldate.xldate_as_datetime(cell.value, 0)
                        #print ("XLDATE %s" % (val))
                
                    elif cellTypeStr == "text":
                        #val=escape() leads to double escape
                        val=remove_re.sub('', cell.value) #rm illegal xml char
                        #print ("---------TypeError %s" % cellTypeStr)

                    if cellTypeStr != "empty": #write non-empty elements
                        #print ("%s:%s" % (attrib, tag))
                        val=str(val).strip() #rm leading and trailing whitespace; turn into str
                        if tag != attrib and val !='':
                            #print ( '%s: %s (%s)' % (tag, val, cellTypeStr))
                            row_dict[tag]=val
                    
                for tag in sorted(row_dict.keys()):    
                    ET.SubElement(doc, tag).text=row_dict[tag]

        self.indent(root)

        #print ('%s->%s' % (inpath, outfile))
        tree.write(outfile, encoding='UTF-8', xml_declaration=True)


    def indent(self, elem, level=0):
        i = "\n" + level*"  "
        if len(elem):
            if not elem.text or not elem.text.strip():
                elem.text = i + "  "
            if not elem.tail or not elem.tail.strip():
                elem.tail = i
            for elem in elem:
                self.indent(elem, level+1)
            if not elem.tail or not elem.tail.strip():
                elem.tail = i
        else:
            if level and (not elem.tail or not elem.tail.strip()):
                elem.tail = i               


if __name__ == "__main__":
    conf={
        "lib" : "C:/Users/User/eclipse-workspace/RST-Lvlup/RST-levelup/lib",
        "infiles" : ['so.xls', 'mm.xls', 'pk.xls'],
        "zerodir" : "0-IN",
        "onedir"  : "1-XML",
    }
    o=Xls2xml(conf)
    o.mv2zero()
    o.transformAll()
        
