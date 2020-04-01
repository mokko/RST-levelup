""" Commandline Frontend for ExcelTool. 

Creates an "updatable" vocabulary index as Excel file

USAGE
    vindex.py --conf path/to/vindex.json --input 20200116/2-MPX/levelup.mpx 

For our purposes, a vocabulary index is 
a) a list of distinct values/terms
b) typically in alphabetical order (but user could change order)
c) it shows the frequency of values/terms
d) the data typically comes from an individual field:
    ./mpx:sammlungsobjekt/mpx:maßangaben

What does "updatable" mean?
The index is written to an excel file, a user can edit this file, and the next 
run is supposed to update the index without overwriting or otherwise 
destroying the user input.

Excel Tool works with multiple files
(1) Data source is an mpx file
(2) A json configuration file that describes mpx elements and attributes to 
    make indexes for
(3) One kind of output is the voc-index in XLS
(4) Another kind of output is translation table in XLS
(5) Another kind of output is rewritten mpx source file where terms have been 
    replaced according to pref terms in voc-index. The rewritten version is 
    called "the fix" or rather a fixed mpx.

ExcelTool doesn't handle applying the translations from the Excel sheet. I plan
to apply those to LIDO directly since I don't want to overload the mpx format 
with translations.    

RECOMMENDED PATHS
Given  directory structure: 
    data/EM-SM/20200111/2-MPX/levelup.mpx #specific export
    data/EM-SM/20200116/2-MPX/levelup.mpx #specific export
    data/EM-SM/vindex.xslx                #for multiple exports of the same object set
    data/vindex-conf.json                 #for multiple object sets

The voc-index is supposed to be persistent over multiple exports. In the case 
above there is one from January 11 and another from January 16. So a good place
for the vocabulary index file is in project root (as shown above).

XAMPLE CONF    
{
    "tasks":[
        {"index":"./mpx:sammlungsobjekt/mpx:sachbegriff"},
        {"index_with_attribute": ["./mpx:sammlungsobjekt/mpx:geogrBezug","bezeichnung"]}, 
        {"attribute_index":["./mpx:sammlungsobjekt/mpx:geogrBezug/@bezeichnung" "verantwortlich"]}
    ]
}
"""
import sys 
import os
sys.path.append (os.path.join(__file__,'../../lib'))
from ExcelTool import ExcelTool

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('-c', '--conf', required=True)
    parser.add_argument('-i', '--input', required=True)
    parser.add_argument('-x', '--xlsdir', required=False)
    args = parser.parse_args()
    t=ExcelTool.from_conf (args.conf,args.input, args.xlsdir)
