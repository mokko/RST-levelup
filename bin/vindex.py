''' 
Frontend for ExcelTool to create a vocabulary index as Excel file

USAGE:
    vindex.py --conf path/to/vindex.json --input 20200116/2-MPX/levelup.mpx 
    #creates output file, e.g. vindex.xlsx in same dir as json config file

(1) create an "updatable" vocabulary index in Excel

For our purposes, a vocabulary index is 
a) a list of distinct values
b) typically in alphabetical order (but not necessarily 100% alphabetical)
c) it shows the number of occurrences of the values
d) the data typically comes from an individual field, but I'd like to allow any xpath expression as source, such as:
     ./sammlungsobjekt/maßangaben[@typ ='Ausgabe']

What does "updatable" mean?
The index is written to an excel file, a user can edit this file, and the next run is supposed to update the index 
without overwriting or otherwise destroying the user input.

Given  directory structure: 
    EM-SM/20200111/2-MPX/levelup.mpx
    EM-SM/20200116/2-MPX/levelup.mpx

The voc-index is supposed to be persistent over multiple exports. In the case above there is one from
January 11 and another from January 16. So a good place for the vocabulary index file is
    EM-SM/vindex.xslx

Path situation:
Configuration for the ExcelTool lies in a json file. It lies in the same directory as the result:
    EM-SM/vindex.json
    
At the moment I use mpx for input, later I want to use LIDO for input.

Thinking out loud:    
Output goes into the same directory the config file. How do we determine the source? We can parse all
subdirectories automatically. But we probably only want to work on the latest one. Or we can specify the 
newest file manually. Let's start with a manual version. It might be enough. We can make it go automatically
later.

Example config:
- JSON doesn't allow comments

{
    "source":"data/WAF55/20190927/2-MPX/levelup.mpx", #TODO     
    "out_fn":"vindex.xlsx",
    "tasks":[
        {"index":"./mpx:sammlungsobjekt/mpx:sachbegriff"},
        {"index_with_attribute": ["./mpx:sammlungsobjekt/mpx:geogrBezug","bezeichnung"]}, 
        {"index":"./mpx:sammlungsobjekt/mpx:geogrBezug[@bezeichnung = 'Ethnie']"},
        {"index":"./mpx:sammlungsobjekt/mpx:geogrBezug[@bezeichnung = 'Land']"}
    ]
}
'''
import sys, os
if os.getlogin() == 'M-MM0002':
    sys.path.append ('C:/Users/M-MM0002/Documents/PY/RST-lvlup/lib')

elif os.getlogin() == 'User':
    sys.path.append ('C:/Users/User/eclipse-workspace/RST-Lvlup/RST-levelup/lib')

else:
    print ('Never get here:' + os.getlogin())

from ExcelTool import ExcelTool

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('-c', '--conf', required=True)
    parser.add_argument('-i', '--input', required=True)
    args = parser.parse_args()
            
    #print ('ARGV ' + sys.argv[1])
    t=ExcelTool.from_conf (args.conf,args.input)
