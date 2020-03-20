"""Creates, updates and uses vocabulary indexes in an Excel file.

Extracts terms from mpx (source), needs configuration from a json file to know
what fields to work on. It creates or updates an XLS file.

It can also write cleaned up version of the source mpx, where syns are replaced
with prefs.

For our purposes, a vocabulary index is an alphabetical list of terms with 
their frequency in the source data. The terms are regarded as synonyms and 
associated with preferred terms. Preferred terms can be replace synonyms
in the data as a way of cleaning up the data.

Excel Format
    Row 1: headers
    Column A: Gewimmel/Begriffe/Ausdrücke
    Column B: Qualifier 
    Column C: Occurences (if qualifier exists in it counts term and qualifier)

TODO: We assume that terms in excel are unique. They are unique when we first
write them, but user could create non-unique terms. I could check if uniqueness
is still given.

This class is agnostic as to where you locate conf_fn, but I recommend
    data/EM-SM/vindex-config.json
    data/EM-SM/20200113/2-MPX/levelup.mpx

USAGE
    #low level constructor
    t=ExcelTool (source_fn)
    t.index ('mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:sachbegriff)
        creates or updates ./index.xlsx with sheet "sachbegriff" 

    #high level constructor (using commands from conf file)
    t=ExcelTool.from_conf (conf_fn,source_fn) # runs the commands in the conf_fn
    t.apply_fix (conf_fn, out_fn) # writes cleanup version to out_fn
"""

import os
#from os import path
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
                xpath = task[cmd]
            elif cmd == 'index_with_attribute':
                xpath = task[cmd][0]
                attribute = task[cmd][1]
            ws=self._get_ws (xpath) #get right worksheet or die
            print (f'**Working on sheet {ws.title}')

            for term, verant in self._iterterms(xpath):
                term_str=self._term2str (term) #strip whitespace
                if cmd == 'index': 
                    l = self._term_exists(ws, term_str, verant)
                elif cmd == 'index_with_attribute':
                    quali = self._get_attribute (term, attribute) 
                    l = self._term_quali_exists(ws, term_str,quali, verant)
                if l: 
                    pref_de=ws[f'E{l}'].value
                    if pref_de is not None:
                        term.text=pref_de.strip() # modify xml
                    #print ("Term '%s' exists in xls line=%i" % (term_str,l))
                    #print ("Term '%s' -> pref %s" % (term_str,pref_de))

        print (f"About to write xml to {out_fn}")
        ET.register_namespace('', 'http://www.mpx.org/mpx') #why? default ns?
        self.tree.write(out_fn, encoding="UTF-8", xml_declaration=True)


    def from_conf (conf_fn, source): #no self
        """Constructor that executes commands from conf_fn"""

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
            row=self._term_exists(ws, term_str, verant)
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
            qu_value=self._get_attribute(term, quali)
            term_str=self._term2str (term) #if there is whitespace we don't want it 
            row=self._term_quali_exists(ws, term_str,qu_value, verant)
            #etree doesn't allow way to access parent like this ../mpx:verantwortlich
            if row:
                #print ('term exists already: '+str(row))
                cell=f'D{row}' # frequency now in D!
                value=ws[cell].value
                ws[cell]=value+1
            else:
                print (f'new term: {term_str}({qu_value})')
                self.insert_alphabetically(ws, term_str, verant, qu_value)
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
        """Finds all xpaths nodes and their verantwortlich. 
        
        Returns iterable."""
        
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
            c += 1
        return c


    def _prepare_ws (self, xpath):
        """Get existing sheet or make new one. 
        
        Sheet title is based on xpath expression"""

        core = self._xpath2core(xpath) 

        try:
            ws = self.wb[core]
        except: 
            if self.new_file == 1:
                ws = self.wb.active
                ws.title = core
                self.new_file = None
                return ws
            else:
                return self.wb.create_sheet(core)
        else:
            return ws  #Sheet exists already, just return it


    def _prepare_header (self, ws):
        '''If Header columns are empty, fill them with default values'''
        from openpyxl.styles import Font
        columns = {
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
                ws[key] = columns[key]
                c = ws[key]
                c.font = Font(bold=True)


    def _prepare_wb (self, xls_fn):
        """Read existing xls or make new one.
        
        Returns workbook."""

        if os.path.isfile (xls_fn):
            print (f'Excel vocabulary exists ({xls_fn})')
            return load_workbook(filename = xls_fn)
        else:
            print (f"Excel File doesn't exist yet, making it ({xls_fn}")
            self.new_file=1
            return Workbook()


    def _read_conf (self, conf_fn):
        import json
        with open(conf_fn, encoding='utf-8') as json_data_file:
            data = json.load(json_data_file)
        return data


    def _term_exists (self, ws, term, verant):
        """Tests if the combination of term and verantwortlich exists already.

        Should we include Verantwortlichkeit in identity check?

        Ignores first row assuming it's a header. Returns row of first 
        occurrence."""

        lno=1 # 1-based line counter 
        for each in ws['A']:
            if lno > 1: #IGNORE HEADER
                if each.value == term and ws[f'C{lno}'].value == verant:
                    #print(f"{each.value} ({verant}) == {term} ({ws[f'C{lno}'].value})")
                    return lno #found
            lno+=1
        return 0 #term not found


    def _term_quali_exists(self,ws, term,quali, verant):
        """Tests if the combination of term/qualifier/verantwortlich exists.

        Returns 0 if combination not found. Otherwise, returns line number 
        of first occurrence. 

        SEE ALSO: _term_exists

        If user deletes verantwortlich anywhere in Excel file, program will 
        die."""

        lno=1 # 1-based line counter 
        for each in ws['A']:
            if lno != 1: #IGNORE HEADER
                #print (f"{c}: {each.value}")
                if (each.value == term 
                    and ws[f'B{lno}'].value == quali 
                    and ws[f'C{lno}'].value == verant) :
                    return lno #found
            lno+=1
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
        value=node.get(attribute)
        if value is not None:
            return value.strip() #strip everything we get from M+


    def _term2str (self, term_node):
        term_str=term_node.text
        if term_str is not None: #if there is whitespace we want to ignore it in the index
            term_str=term_str.strip()
        return term_str #returns stripped text or None 


if __name__ == '__main__': 
    t=ExcelTool ('data/AKu-StuSam/20200226/2-MPX/levelup.mpx', '.')
    #t.index("./mpx:sammlungsobjekt/mpx:personenKörperschaften")
