''' 
Frontend for ExcelTool to create a vocabulary index as Excel file

USAGE:
    vindex.py vindex-conf.json

Writes output in same dir as source (default file name: vindex.xlsx)

source path relative to conf file or to executing program? Just dont change the
default behavior unless you sure. Probably the former.

Example config:
- JSON doesn't allow comments

{
    "source":"data/WAF55/20190927/2-MPX/levelup.mpx",     
    "out_fn":"vindex.xlsx",
    "tasks":[
        {"index":"./mpx:sammlungsobjekt/mpx:sachbegriff"},
        {"index_with_attribute": ["./mpx:sammlungsobjekt/mpx:geogrBezug","bezeichnung"]}, 
        {"index":"./mpx:sammlungsobjekt/mpx:geogrBezug[@bezeichnung = 'Ethnie']"},
        {"index":"./mpx:sammlungsobjekt/mpx:geogrBezug[@bezeichnung = 'Land']"}
    ]
}
'''
import sys
import os
if os.getlogin() == 'M-MM0002':
     lib = 'C:/Users/M-MM0002/Documents/PY/RST-lvlup/lib'

elif os.getlogin() == 'LENOVO USER':
    lib = 'C:/Users/LENOVO USER/eclipse-workspace/RST-levelup/lib'

sys.path.append (lib)
from ExcelTool import ExcelTool

if __name__ == "__main__":
    #sys.argv[1:]
    print ('ARGV ' + sys.argv[1])
    t=ExcelTool.from_conf (sys.argv[1])
