''' 
(1) Examine tifs on hard disk
(2) compare with mpx
(3) write info in xls for manual proof reading and as persistent storage
'''

import os
from openpyxl import Workbook, load_workbook
from pathlib import Path

class TifId: 
    def __init__(self, lib_fn):
        if not lib_fn.endswith('.xlsx'):
            raise ValueError ('Supplied Excel file name does not end on xlsx!')
        self.lib_fn=lib_fn
        self._prepare_wb(lib_fn)


    def scan_tif (self, tif_dir):
        '''Scan (recursively) for tif files in tif_dir and write results to excel library'''
        print ('* About to scan %s' % tif_dir)
        ws = self.wb.worksheets[0]
        #print (ws.title)
        
        for path in Path(tif_dir).rglob('*tif*'):
            self._add_to_col(0, 'A', os.path.abspath(path))
            print(path)
        self._save_xsl()
        #self._extract_base()
        #self._save_xsl()

    def process (self):
        self._extract_identNr()
        self._xmp()
        self._save_xsl()
        self._mpx()
        self._save_xsl()



    '''PRIVATE METHODS'''
    '''Given a sheet with full path in col A, go thru that column and write the base filename in col B'''

    def _add_to_col (self, sheet_no, column, value):
        '''add value at first empty cell in given column'''
        ws = self.wb.worksheets[sheet_no]
        new_row=ws.max_row+1
        cell='%s%i' % (column, new_row)
        ws[cell]=str(value)


    def _extract_EM (self, path):
        base=os.path.basename(path)
        trunk,ext=os.path.splitext(base)
        ls=trunk.split()[:3]
        new=(' ').join(ls) # but actually has 4 parts TODO
        #print ('%s->%s' % (path, new))
        return new


    def _extract_identNr(self):
        print ('* Extract base')
        ws = self.wb.worksheets[0] #zero based!
        #print ('sheet title: %s' % ws.title)

        if ws.max_row > 1: # not with empty xlsx
            for col in ws.iter_cols(min_row=2, max_col=1, max_row=ws.max_row):
                for cell in col:
                    identNr=self._extract_EM(cell.value)
                    #print ('%i:%s' % (cell.row, identNr))
                    new_cell='B%i' % cell.row
                    if ws[new_cell].value is None:
                        #print ('Empty cell')
                        ws[new_cell]=identNr


    def mpx (self):
        '''Loop up objId by identNr in a mpx file'''


    def _prepare_wb (self, xls_fn):
        if os.path.isfile (xls_fn):
            #print ('File exists ('+ xls_fn+')')
            self.wb=load_workbook(filename = xls_fn)
        else:
            print ("Excel library file doesn't exist yet, making it ")
            #raise ("Excel file not found: %s" % xls_fn)
            self.wb=Workbook()
            ws1 = self.wb.active
            ws1.title = "tifs"
            ws1['A1'] = 'Pfad'
            ws1['B1'] = 'Signatur aus Pfad'
            ws1['C1'] = 'IdentNr aus MPX'
            ws1['D1'] = 'objId aus MPX'
            ws1['E1'] = 'Fotograf aus Tif'
            ws1['F1'] = '(C) aus Tif'
            self.wb.create_sheet (title="jpgs")


    def _save_xsl (self):
        print ('* Saving excel library to %s' % self.lib_fn)
        self.wb.save(self.lib_fn)


    def _xmp (self):
        import exifread
        print ('* Extract from tiff (xmp)')
        ws = self.wb.worksheets[0] #zero based!
    
        if ws.max_row > 1: # not with empty xlsx
            for col in ws.iter_cols(min_row=2, max_col=1, max_row=ws.max_row):
                for cell in col:
                    print (cell.value)
                    f = open(cell.value, 'rb')
                    tags = exifread.process_file(f)
                    E_cell='E%i' % cell.row
                    F_cell='F%i' % cell.row
                    if ws[E_cell].value is None:
                        ws[E_cell]=str(tags['Image Artist'])
                    if ws[F_cell].value is None:
                        ws[F_cell]=str(tags['Image Copyright'])
