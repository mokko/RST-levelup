"""
USAGE

    #traditional constructor
    t=ExcelTool (source_fn)
    t.index ('mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:sachbegriff)
        creates or updates ./index.xlsx with sheet "sachbegriff" 

    #alternative Constructor
    t=ExcelTool.from_conf (conf_fn,source_fn) # runs the commands in the conf_fn
    t.apply_fix (conf_fn, out_fn)

Excel Format
    Row 1: headers
    Column A: Gewimmel/Begriffe/Ausdrücke
    Column B: Qualifier 
    Column C: Occurences (if qualifier is filled in it counts term and qualifier)


TODO: We assume that terms in excel are unique. I should check if that is the case.

preferred location in dir root dir for the data set: 
    data/EM-SM/vindex-config.json
    data/EM-SM/20200113/2-MPX/levelup.mpx
"""

import os
from os import path
import xml.etree.ElementTree as ET
#from lxml import etree #has getParent()
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
        self.xls_fn=os.path.join (outdir,'vindex.xlsx')
        self.wb=self._prepare_wb(self.xls_fn)


    def apply_fix (self, conf_fn, out_fn):
        """Replace syns with prefs in out_fn
        
        1. Read conf and process every task
        2. Read xls_fn and use matching sheet
        3. Read xml source and parse it with xpath from conf
        4. Replace xml elements where necessary
        5. save xml as out_fn"""

        print ('*About to apply vocabulary control')
        
        #primitive Domain Specific Language (DSL)
        for task,cmd in self._itertasks(conf_fn):
            print (f"{cmd}: {task[cmd]}")
            if cmd == 'index': 
                #self._fix_index(task[cmd])
                xpath = task[cmd]
            elif cmd == 'index_with_attribute':
                print ('...index with attribute') 
                xpath = task[cmd][0]
                attribute = task[cmd][1]
            ws=self._get_ws (xpath) #get right worksheet or die
            print (f'**Working on sheet {ws.title}')

            for term, verant in self._iterterms(xpath):
                term_str=self._term2str (term) #if there is whitespace we don't want it
                if cmd == 'index': 
                    l = self._term_exists(ws, term_str)
                elif cmd == 'index_with_attribute':
                    quali = self._get_attribute 
                    l = self._term_quali_exists(ws, term_str,quali)
                if l: 
                    pref_de=ws[f'E{l}'].value
                    if pref_de is not None:
                        term.text=pref_de.strip() # modify xml
                    #print ("Term '%s' exists in xls line=%i" % (term_str,l))
                    #print ("Term '%s' -> pref %s" % (term_str,pref_de))

        print ('About to write xml to %s'%out_fn)
        ET.register_namespace('', 'http://www.mpx.org/mpx')
        self.tree.write(out_fn, encoding="UTF-8", xml_declaration=True)

    def from_conf (conf_fn, source): #no self
        """Constructor that runs commands from conf_fn"""
        
        #print (f'conf_fn: {conf_fn}')

        t=ExcelTool (source,os.path.dirname(conf_fn))

        for task,cmd in t._itertasks(conf_fn): #sort of a Domain Specific Language DSL
            print (f"{cmd}: {task[cmd]}")
            if cmd == 'index':
                t.index(task[cmd])
            elif cmd == 'index_with_attribute':
                t.index_with_attribute (task[cmd][0], task[cmd][1])
        return t


    def index (self, xpath):
        """Write vocabulary index to the right xls sheet.

        Sheet depends on xpath expression."""

        ws=self._prepare_ws(xpath)
        #print ('ws.title: '+ws.title)
        #print ('XPATH'+xpath)
        self._prepare_header(ws)
        self._col_to_zero(ws, 'D') #drop all frequencies when we run a new index
        for term, verant in self._iterterms(xpath):
            term_str=self._term2str (term) #if there is whitespace we don't want it 
            row=self._term_exists(ws, term_str)
            if row: 
                #print ('term exists already: '+str(row))
                cell=f"D{row}" # frequency in column D 
                value=ws[cell].value
                if value=='':
                    ws[cell]=1
                else:
                    ws[cell]=value+1
            else:
                print (f"new term: {term_str}")
                self.insert_alphabetically(ws, term_str, verant)
        self.wb.save(self.xls_fn) 


    def index_with_attribute (self, xpath, quali): 
        """Write vocabulary index with qualifier to the right xls sheet
        
        Treats terms with different qualifiers as two different terms, e.g. 
        lists both Indien (Land) and Indien ()."""

        ws=self._prepare_ws(xpath) # get the right worksheet
        #print ('ws.title: '+ws.title)
        self._prepare_header(ws)
        self._col_to_zero(ws, 'D') # set occurrences to 0
        for term, verant in self._iterterms(xpath):
            qu=self._get_attribute(term, quali)
            term_str=self._term2str (term) #if there is whitespace we don't want it 
            row=self._term_quali_exists(ws, term_str,qu)
            #etree doesn't allow way to access parent like this ../mpx:verantwortlich
            #print (f"**quali: {qu}")
            if row:
                #print ('term exists already: '+str(row))
                cell=f'D{row}' # frequency now in D!
                value=ws[cell].value
                ws[cell]=value+1
            else:
                print (f'new term: {term_str}({qu})')
                self.insert_alphabetically(ws, term_str, verant, qu)
            #print ('QUALI: '+ quali+': '+ str(qu))
        self.wb.save(self.xls_fn) 


    def insert_alphabetically (self, ws, term, verant, quali=None): 
        """inserts new term into column A alphabeticallyof worksheet ws after the first existing term
        
        Should be private: _insert_alphabetically

        ex: if we have list A,B,C, we want to put B between B und C

        looping current terms from xls
        each time comparing new term vs xls term
        needle_term is after first term
        needle_term is after second term
        needle_term is BEFORE third term -> so return a 2"""

        line=self._line_alphabetically(ws, term)
        ws.insert_rows(line)
        ws[f'A{line}']=term
        ws[f'B{line}']=quali
        ws[f'C{line}']=verant
        ws[f'D{line}']=1 #this is a new term
        #print ('...insert at line '+str(line))


#
#    PRIVATE STUFF
#


    def _col_to_zero (self,ws,col):
        """Set all values of a specific column to 0. 
        
        Only header (row=1) remains unchanged.
        
        USAGE: 
            self._col_to_zero (ws, 'B')"""

        c=1 # 1-based line counter 
        for each in ws[col]:
            if c != 1: #IGNORE HEADER
                #print (str(c)+': '+each.value)
                each.value=0 # None doesn't work
            c+=1
        return c


    def _del_col (self, ws, col):
        """ Delete all values in a specific column. 
        
        Header (row=1) remains as is.
        
        USAGE:
            self._del_col (ws, 'B')"""

        c=1 # 1-based line counter 
        for each in ws[col]:
            if c != 1: #IGNORE HEADER
                #print (str(c)+': '+each.value)
                each.value='' # None doesn't work
            c+=1
        return c


    def _get_ws (self,xpath):
        """Get existing worksheet based on xpath or die"""

        core=self._xpath2core(xpath) #extracts keyword from xpath for use as sheet.title
        return self.wb[core] # dies if sheet with title=core doesn't exist


    def _itertasks(self, conf_fn):
        data = self._read_conf(conf_fn)
        for task in data['tasks']:
            for cmd in task:
                yield task,cmd


    def _iterterms (self, xpath):
        xp_parent,xp_child = self._xpath_split(xpath)

        for so in self.tree.findall(xp_parent, self.ns):
            verant = so.find('mpx:verantwortlich', self.ns).text #assuming that it exists always 
            term = so.find(xp_child, self.ns)
            if term is not None:
                yield term, verant #should be a tuple


    def _line_alphabetically (self, ws, needle_term):
        """Uppercase and lowercase in alphabetical order ignored"""

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


    def _prepare_ws (self, xpath):
        """Get existing sheet or make new one. 
        
        Sheet title is based on xpath expression"""

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
            'B1': 'QUALI', #create this column even if not used
            'C1': 'VERANTWORTLICHKEIT', 
            'D1': 'HÄUFIGKEIT', 
            'E1': 'PREF (DE)', 
            'F1': 'PREF (EN)',
            'G1': 'NOTIZEN'
        }

        for key in columns:
            if ws[key].value is None:
                ws[key]=columns[key]
                c=ws[key]
                c.font = Font(bold=True)


    def _prepare_wb (self, xls_fn):
        """Read existing xls or make new one.
        
        'Return' values in self"""

        if path.isfile (xls_fn):
            print ('File exists ('+ xls_fn+')')
            return load_workbook(filename = xls_fn)
        else:
            print ('Excel File doesn\'t exist yet, making it ('+ xls_fn+')')
            self.new_file=1
            return Workbook()


    def _read_conf (self, conf_fn):
        import json
        with open(conf_fn, encoding='utf-8') as json_data_file:
            data = json.load(json_data_file)
        return data


    def _term_exists (self, ws, term):
        """Tests whether term is already in column A of the sheet.

        Ignores first row assuming it's a header. Returns row of first 
        occurrence."""

        c=1 # 1-based line counter 
        for each in ws['A']:
            if c != 1: #IGNORE HEADER
                #print (f"{c}: {each.value}")
                if each.value==term:
                    return c #found
            c+=1
        return 0 #not found


    def _term_quali_exists(self,ws, term,quali):
        '''
        Tests whether the combination of term/qualifier already exists. Usage in analogy to _term_exists.
        '''
        c=1 # 1-based line counter 
        for each in ws['A']:
            if c != 1: #IGNORE HEADER
                #print (f"{c}: {each.value}")
                xlsqu=ws[f'B{c}'].value # quali is in column B
                if each.value==term and xlsqu == quali:
                    #print ('xls: %s(%s) VS %s(%s)' % (each.value, xlsqu, term, quali))
                    return c #found
            c+=1
        return 0 #not found


    def _xpath_split(self, xpath):
        all=xpath.split('/')
        parent='/'.join(all[:-1])
        child='./'+all[-1]
        #print (f"parent {parent}")
        #print (f"child {child}")
        return parent, child


    def _xpath2core (self,xpath):
        """Take xpath and return a string suitable that works as a sheet title.
        
        This algorithm is pretty stupid, but it'll do for the moment."""

        core=xpath.split('/')[-1]
        core=core.split(':')[1].replace('[','').replace(']','').replace(' ','').replace('=','').replace('\'','')
        if len(core) > 31:
            core=core[:24]+'...'
        #print (f'xpath->core: {xpath} -> {core}')
        return core


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
    t=ExcelTool ('data/AKu-StuSam/20200226/2-MPX/levelup.mpx', '.')
    #t.index("./mpx:sammlungsobjekt/mpx:personenKörperschaften")
    
