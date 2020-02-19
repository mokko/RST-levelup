'''
Proof of concept version for ExcelTool

USAGE    

    t=ExcelTool (source_fn)
    t.index ('mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:sachbegriff)
        creates ./index.xlsx with sheet "sachbegriff" which has index.

Excel Format
    Row 1: headers
    Column A: Gewimmel/Begriffe/Ausdrücke
    Column B: Qualifier 
    Column C: Occurences (if qualifier is filled in it counts term and qualifier)

TODO: We assume that terms in excel are unique. I should check if that is the case.

load config
    data/EM-SM/vindex-config.json
    data/EM-SM/20200113/2-MPX/levelup.mpx
'''

import os
from os import path
import xml.etree.ElementTree as ET
from openpyxl import Workbook, load_workbook

#from cx_Freeze.samples.openpyxl.test_openpyxl import wb

class ExcelTool:
    def __init__ (self, source,outdir='.'):
        self.ns = {
            'npx': 'http://www.mpx.org/npx', #npx is no mpx
            'mpx': 'http://www.mpx.org/mpx', 
        }
        self.tree = ET.parse(source)
        self.new_file=0
        self.xls_fn=outdir+'/vindex.xlsx'
        self.wb=self._prepare_wb(self.xls_fn)


    def _read_conf (self, conf_fn):
        import json
        with open(conf_fn, encoding='utf-8') as json_data_file:
            data = json.load(json_data_file)
        return data


    def from_conf (conf_fn, source): #no self
        #print ('conf_fn: '+ conf_fn)
            
        t=ExcelTool (source,os.path.dirname(conf_fn))

        data=t._read_conf(conf_fn)

        for task in data['tasks']:
            for cmd in task: #sort of a Domain Specific Language DSL
                print (cmd+': '+str(task[cmd]))
                if cmd == 'index':
                    t.index(task[cmd])
                elif cmd == 'index_with_attribute':
                    t.index_with_attribute (task[cmd][0], task[cmd][1])
        return t

    
    def index_with_attribute (self, xpath, quali): 
        '''
        Based on xpath determine sheet name and write vocabulary index to that xls sheet 
        
        TODO: I would like to allow a qualifier that describes the term
        Indien (Land) where "Land" is the qualifier for the term "Indien".
        
        But that's not so easy. I would need to prepare for the fact that the date could have both
        Indien (Land) and Indien (Subkontinent), i.e. same value, but different qualifiers. 
        Then the test for identity (_term_exist -> _term_exists_with_qualifier) needs to be different
        
        Maybe a cheap first version would not do that.
        '''
        ws=self._prepare_ws(xpath) # get the right worksheet
        #print ('ws.title: '+ws.title)
        self._prepare_header(ws)
        self._col_to_zero(ws, 'C') # set occurrences to 0

        for term in self.tree.findall(xpath, self.ns):
            qu=self._get_attribute(term, quali)
            term_str=self._term2str (term) #if there is whitespace we don't want it 
            row=self._term_quali_exists(ws, term_str,qu)
            if row: 
                #print ('term exists already: '+str(row))
                cell='C'+str(row) # occurrences in col C!
                value=ws[cell].value
                ws[cell]=value+1
            else:
                print ('new term: %s(%s)' % (term_str, qu))
                self.insert_alphabetically(ws, term_str, qu)
            #print ('QUALI: '+ quali+': '+ str(qu))
        self.wb.save(self.xls_fn) 


    def index (self, xpath):
        '''
        Based on xpath determine sheet name and write vocabulary index to that xls sheet 
        '''
        ws=self._prepare_ws(xpath)
        #print ('ws.title: '+ws.title)
        #print ('XPATH'+xpath)
        self._prepare_header(ws)
        self._col_to_zero(ws, 'C') #drop occurrences every time we run a new index

        for term in self.tree.findall(xpath, self.ns):
            term_str=self._term2str (term) #if there is whitespace we don't want it 
            row=self._term_exists(ws, term_str)
            if row: 
                #print ('term exists already: '+str(row))
                cell='C'+str(row) # count occurrences
                value=ws[cell].value
                if value=='':
                    ws[cell]=1
                else:
                    ws[cell]=value+1
            else:
                print ('new term: '+ term_str)
                self.insert_alphabetically(ws, term_str)
        self.wb.save(self.xls_fn) 


    def _col_to_zero (self,ws,col):    
        '''
        Set all existing values of a respective column to 0. Only header (row=1) remains unchanged.
        
        USAGE: 
            self._col_to_zero (ws, 'B')
        '''
        c=1 # 1-based line counter 
        for each in ws[col]:
            if c != 1: #IGNORE HEADER
                #print (str(c)+': '+each.value)
                each.value=0 # None doesn't work
            c+=1
        return c


    def _del_col (self, ws, col):
        '''
        Delete all values in the respective column, column stays where it is. Also
        header (row=1) remains.
        
        USAGE:
            self._del_col (ws, 'B')
        '''
        c=1 # 1-based line counter 
        for each in ws[col]:
            if c != 1: #IGNORE HEADER
                #print (str(c)+': '+each.value)
                each.value='' # None doesn't work
            c+=1
        return c


    def _prepare_ws (self, xpath):
        '''Get existing sheet or make new one; sheet title is based on xpath expression''' 
        core=self._xpath2core(xpath) 

        try:
            ws = self.wb[core]
        except: 
            if self.new_file == 1:
                ws=self.wb.active
                ws.title=core
                self.new_file = None
                return ws
            else:
                return self.wb.create_sheet(core)
        else:
            return ws  #Sheet exists already, just return it


    def _prepare_header (self, ws):
        '''If Header columns are empty, fill them with default values'''
        from openpyxl.styles import Font
        columns={
            'A1': 'GEWIMMEL', 
            'B1': 'QUALI',
            'C1': 'HÄUFIGKEIT', 
            'D1': 'PREF (DE)', 
            'E1': 'PREF (EN)'
        }

        for key in columns:
            if ws[key].value is None:
                ws[key]=columns[key]
                c=ws[key]
                c.font = Font(bold=True)


    def _prepare_wb (self, xls_fn):
        '''Read existing xls or make new one, return values in self'''

        if path.isfile (xls_fn):
            print ('File exists ('+ xls_fn+')')
            return load_workbook(filename = xls_fn)
        else:
            print ('Excel File doesn\'t exist yet, making it ('+ xls_fn+')')
            self.new_file=1
            return Workbook()


    def _get_ws (self,xpath):
        '''Get existing worksheet based on xpath or die'''
        core=self._xpath2core(xpath) #extracts keyword from xpath for use as sheet.title
        ws = self.wb[core] # dies if sheet with title=core doesn't exist
        return ws

 
    def _term_quali_exists(self,ws, term,quali):
        '''
        Tests whether the combination of term/qualifier already exists. Usage in analogy to _term_exists.
        '''
        c=1 # 1-based line counter 
        for each in ws['A']:
            if c != 1: #IGNORE HEADER
                #print (str(c)+': '+each.value)
                xlsqu=ws['B'+str(c)].value # quali is in column B
                if each.value==term and xlsqu == quali:
                    #print ('xls: %s(%s) VS %s(%s)' % (each.value, xlsqu, term, quali))
                    return c #found
            c+=1
        return 0 #not found


    def _xpath2core (self,xpath):
        '''This transformation is insufficient for a lot of expressions eg. involving [@attribute], but it'll do for the moment.
        '''
        core=xpath.split('/')[-1]
        core=core.split(':')[1].replace('[','').replace(']','').replace(' ','').replace('=','').replace('\'','')
        if len(core) > 31:
            core=core[:24]+'...'
        #print ('xpath->core: ' + xpath + '->' + core)
        return core     


    def _term_exists (self, ws, needle_term):
        '''tests whether term is already in wb column A1
        ignores first row assuming it's a header and returns row of first occurrence
        
        row=self._term_exists(ws, 'Digitale Aufnahme')
        
        if row:
            print ('term exists already')
        else:
            print ('term new')
            
        if self._term_exists(ws, 'Digitale Aufnahme'):
            print ('term exists already')
        else:
            print ('term is new')
        '''

        c=1 # 1-based line counter 
        for each in ws['A']:
            if c != 1: #IGNORE HEADER
                #print (str(c)+': '+each.value)
                if each.value==needle_term:
                    return c #found
            c+=1
        return 0 #not found

    
    def _line_alphabetically (self, ws, needle_term):
        '''CAVEAT: Uppercase and lowercase in alphabetical order ignored'''
        c=1 # 1-based line counter 
        for xlsterm in ws['A']:
            if c != 1: #IGNORE HEADER
                #print (str(c)+': '+each.value)
                if  needle_term.lower() < xlsterm.value.lower():
                    return c #found
                    #print (each.value + ' is before ' + needle_term)
                #else:
                    #print (each.value + ' is NOT before ' + needle_term)
            c+=1
        return c


    def insert_alphabetically (self, ws, term, quali=None): 
        '''
        inserts term into column A of worksheet ws after the first existing term
        
        Should be private: _insert_alphabetically

        ex: if we have list A,B,C, we want to put Ba between B und C
        
        looping current terms from xls
        each time comparing new term vs xls term
        needle_term is after first term
        needle_term is after second term
        needle_term is BEFORE third term -> so return a 2
        '''
        line=self._line_alphabetically(ws, term)
        ws.insert_rows(line)
        ws['A'+str(line)]=term
        ws['B'+str(line)]=quali
        ws['C'+str(line)]=1
        #print ('...insert at line '+str(line))


    def apply_fix (self, conf_fn, out_fn):
        '''Reads config file, xml source and vocabulary index and applies control
        from the vocabulary index (xls) to the source data and saves the result under
        a new file name
        
        1. Read conf and process every task
        2. Read xls_fn and check if matching sheets exist
        3. Read xml source and parse it with xpath from config file
        4. Replace xml nodes where necessary
        5. save xml as out_fn
        
        During __init__ we parsed source_xml to self.tree and loaded the xls workbook
        to self.wb
        
        Let's not assume that we have read or written vindex file in the same run. 
        '''
        print ('*About to apply vocabulary control')
        data=self._read_conf(conf_fn)
        
        #primitive Domain Specific Language (DSL)
        for task in data['tasks']:
            for cmd in task:
                print (cmd+': '+str(task[cmd]))
                if cmd == 'index': 
                    #self._fix_index(task[cmd])
                    xpath=task[cmd]
                elif cmd == 'index_with_attribute':
                    print ('...index with attribute') 
                    xpath=task[cmd][0]
                    attribute=task[cmd][1]
                    #self._fix_index_with_attribute (task[cmd][0], task[cmd][1])
                ws=self._get_ws (xpath) #get right worksheet or die
                print ('**Working on sheet '+ ws.title)
                for term in self.tree.findall(xpath, self.ns):
                    term_str=self._term2str (term) #if there is whitespace we don't want it
                    if cmd == 'index': 
                        l=self._term_exists(ws, term_str)
                    elif cmd == 'index_with_attribute':
                        qu=self._get_attribute 
                        
                        l=self._term_quali_exists(ws, term_str,qu)
                    if l: 
                        pref_de=ws['D'+str(l)].value
                        #TODO what do I want?
                        if pref_de is not None:
                            pref_de=pref_de.strip() #strip what comes from xls
                            term.text=pref_de.strip() # modify xml
                        #print ("Term '%s' exists in xls line=%i" % (term_str,l))
                        #print ("Term '%s' -> pref %s" % (term_str,pref_de))

        print ('About to write xml to %s'%out_fn)
        ET.register_namespace('', 'http://www.mpx.org/mpx')
        self.tree.write(out_fn, encoding="UTF-8", xml_declaration=True)


    def _get_attribute (self, node, attribute):
        qu=node.get(attribute)
        if qu is not None:
            qu=qu.strip() #strip everything we get from M+
        return qu


    def _term2str (self, term_node):
        term_str=term_node.text
        if term_str is not None: #if there is whitespace we want to ignore it in the index
            term_str=term_str.strip()
        return term_str #returns stripped text or None 


if __name__ == '__main__': 
    t=ExcelTool ('data/WAF55/20190927/2-MPX/levelup.mpx', '.')
    t.index("./mpx:sammlungsobjekt/mpx:personenKörperschaften")
    
