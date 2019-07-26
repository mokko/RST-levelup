'''
1. xls2xml
 1.1 mkdir 1-XML und 0-IN if not exists already
 1.2 move existing input files to 0-IN
 1.3 py-transform to dirty xml in 1-XML if target does not exist already. 
     If you want to repeat conversion, delete corresponding files in 1-IN
 1.4 Log success/failure in logfile; not necessary at first
'''

import os
import shutil
import xlrd
import xlrd.sheet
from xlrd.sheet import ctype_text
import xml.etree.ElementTree as ET
from xml.sax.saxutils import escape

verbose = 1


class Xls2xml:
    def __init__ (self, conf): 
        self.mv2zero(conf)
        self.transformAll(conf)
        #print (conf)
        
    def mv2zero (self, conf):    
        if not os.path.isdir(conf['zerodir']): 
            os.mkdir( '0-In') # no chmod
        
        for infile in conf['infiles']:
            #print (infile)
            if os.path.isfile(infile):
                shutil.move(infile, conf['zerodir'])
    
    def transformAll (self,conf):
        if not os.path.isdir(conf['onedir']): 
            os.mkdir( conf['onedir']) # no chmod

        for infile in conf['infiles']:
            path=conf['zerodir']+'/'+infile
            #print ('Looking for %s' % infile)
            if os.path.isfile(path):
                self.perFile(conf,infile) 

    def perFile(self, conf,infile):
        inpath=conf['zerodir']+'/'+infile
        
        wb = xlrd.open_workbook(filename=inpath, on_demand=True)
        sheet= wb.sheet_by_index(0)
                       
        root = ET.Element("MuseumPlusExport")
        tree = ET.ElementTree(root)
        
        for r in range(1, sheet.nrows):
            doc = ET.SubElement(root, "multimediaObjekt")

            for c in range(sheet.ncols):
                cell = sheet.cell(r, c) 
                cellTypeStr = ctype_text.get(cell.ctype, 'unknown type')
                
                #not sure if I always want to turn floats into ints
                val=cell.value
                if cellTypeStr == "number":
                    val=int(float(val))
        
                elif cellTypeStr == "xldate":
                    val=xlrd.xldate.xldate_as_datetime(val, 0)
                    #print ("XLDATE %s" % (val))
                #verbose ('%s (%s)>%s' % (columns[c], cellTypeStr,val))
                if cellTypeStr != "empty":            
                    #ET.SubElement(doc, columns[c], name=cellTypeStr).text=str(val)
                    #N.B. escape & 
                    #print (sheet.cell(0,c))
                    ET.SubElement(doc, sheet.cell(0,c)).text=escape(str(cell))

        #self.indent(root)

        outfile=conf['onedir']+'/'+infile[:-4] + '.xml'
        print ('%s->%s' % (inpath, outfile))
        tree.write(outfile, encoding='UTF-8', xml_declaration=True)
                
                
    def indent(elem, level=0):
        i = "\n" + level*"  "
        if len(elem):
            if not elem.text or not elem.text.strip():
                elem.text = i + "  "
            if not elem.tail or not elem.tail.strip():
                elem.tail = i
            for elem in elem:
                indent(elem, level+1)
            if not elem.tail or not elem.tail.strip():
                elem.tail = i
        else:
            if level and (not elem.tail or not elem.tail.strip()):
                elem.tail = i

