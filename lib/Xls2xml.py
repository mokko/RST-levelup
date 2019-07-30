# -- coding: utf-8 --
import os
import shutil
import xlrd
import xlrd.sheet
import datetime
from xlrd.sheet import ctype_text
import xml.etree.ElementTree as ET
from xml.sax.saxutils import escape
from Generic import Generic

verbose = 1

'''
Mainly convert export data from xls into simple generic xml. The xml should be formally correct xml, but
it may contain false multiples and other quirks. This object expects certain filenames as input files. Those
are defined in the configuration.

Input comes from current working directory; output is written to current working directory's subdirectories 
based on configuration.

Results never get overwritten


NOTE
- Empty tags are not written. Hence it is not necessarily possible to convert from the xml back to the xls.
- mulId, objId and kueId are written as index in record/@attrib form and then omitted from result.
- record tag (multimediaobjekt, sammlungsobjekt, personKörperschaft) is written depending in input file
- add exportdatum to record tag
- no namespaces

You probably only need this:
    o=Xls2xml(conf)
'''

class Xls2xml (Generic):
    def __init__ (self, conf): 
        self.mv2zero(conf)
        self.transformAll(conf)
        #print (conf)


    def mv2zero (self, conf):    
        self.mkdir (conf['zerodir'])
        
        for infile in conf['infiles']:
            #print (infile)
            if os.path.isfile(infile):
                print ('moving %s to %s' % (infile, conf['zerodir']))
                shutil.move(infile, conf['zerodir'])


    def transformAll (self,conf):
        self.mkdir (conf['onedir'])

        for infile in conf['infiles']:
            path=conf['zerodir']+'/'+infile
            #print ('Looking for %s' % infile)
 
            outfile=conf['onedir']+'/'+infile[:-4] + '.xml'

            if os.path.isfile(outfile):
                print ("%s exists already, no overwrite" % outfile)
            else:
                if os.path.isfile(path):
                    self.transPerFile(conf,infile, outfile) 
                        


    '''Called on a per file basis from transformAll'''
    def transPerFile(self, conf,infile, outfile):
        inpath=conf['zerodir']+'/'+infile
        
        wb = xlrd.open_workbook(filename=inpath, on_demand=True)
        sheet= wb.sheet_by_index(0)
                       
        root = ET.Element("MuseumPlusExport", attrib={'version':'2.0', 'level':'dirty', }) 
        tree = ET.ElementTree(root)

        columns =[sheet.cell(0, c).value for c in range(sheet.ncols)]
        
        for r in range(1, sheet.nrows): #leave out column headers
            if infile == "so.xls":
                tag="sammlungsobjekt"
                attrib='objId'

            elif infile == "pk.xls":
                tag="personK�rperschaft"
                attrib='kueId'

            elif infile == "mm.xls":
                tag="multimediaobjekt"
                attrib='mulId'

            index=sheet.cell (r,columns.index(attrib)).value
            if index:
                index=str(int(index))

            now=datetime.datetime.now().isoformat() #pytz.timezone('Europe/Berlin')
            doc = ET.SubElement(root, tag, attrib={attrib:index, 'exportdatum':now}) 

            print ("INDEX: %s" % index) #should this become verbose?
                
            for c in range(sheet.ncols):
                cell = sheet.cell(r, c) 
                cellTypeStr = ctype_text.get(cell.ctype, 'unknown type')
                tag=sheet.cell(0,c).value
                val=str()

                #type conversions
                if cellTypeStr == "number":
                    #val=int(float(cell.value)) 
                    val=int(cell.value)
                    #print ("number:%s" % val)
                    
                elif cellTypeStr == "xldate":
                    val=xlrd.xldate.xldate_as_datetime(cell.value, 0)
                    #print ("XLDATE %s" % (val))
            
                elif cellTypeStr == "text":
                    val=escape(cell.value)
                    #print ("---------TypeError %s" % cellTypeStr)
                if cellTypeStr != "empty": #write non-empty elements
                    #print ("%s:%s" % (attrib, tag))
                    if tag != attrib:
                    #print ( '%s: %s (%s)' % (tag, val, cellTypeStr))
                        ET.SubElement(doc, tag).text=str(val)

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
