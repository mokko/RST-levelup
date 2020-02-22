import os
from openpyxl import Workbook, load_workbook
from pathlib import Path

class TifId: 
    def __init__(self, lib_fn):
        if not lib_fn.endswith('.xlsx'):
            raise ValueError ('Supplied Excel file name does not end with xlsx!')
        self.lib_fn=lib_fn
        self._prepare_wb(lib_fn)


    '''Scan (recursively) for tif files in tif_dir and write results to excel library'''
    def scan_tif (self, tif_dir):
        print ('* About to scan %s' % tif_dir)
        ws = self.wb.worksheets[0]
        print (ws.title)
        
        for path in Path(tif_dir).rglob('*tif*'):
            #ws.append ([path]) I dont know how append works
            self._add_to_col(0, 'A', path)
        self._save_xsl()
        self._extract_base()
        self._save_xsl()


    '''Given a sheet with full path in col A, go thru that column and write the base filename in col B'''
    def _extract_base(self):
        print ('* Extract base')
        ws = self.wb.worksheets[0] #zero based!
        print (ws.title)

        max_cell='A%i' % ws.max_row
        cell_range = ws['A1':max_cell]

        for cell in cell_range:
            print (ws[cell].value)


    def _save_xsl (self):
        print ('* Saving excel library to %s' % self.lib_fn)
        self.wb.save(self.lib_fn)



    '''PRIVATE METHODS'''
    '''Put workbook at self.wb'''
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
            self.wb.create_sheet (title="jpgs")

    '''add value at first empty cell in given column'''
    def _add_to_col (self, sheet_no, column, value):
        ws = self.wb.worksheets[sheet_no]
        new_row=ws.max_row+1
        cell='%s%i' % (column, new_row)
        ws[cell]
        
    