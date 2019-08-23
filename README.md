# RST-levelup
Tool chain to transform exports

transforms excel reports from M+ to an mpx. Update of an earlier version of this toolchain written in perl.

USAGE
>>cd AmerikaSM/20190726
>>lvlup.py

The script creates several subdirectories which document whats going on under the hood

0-IN: has original excel files
1-XML: has excel tables simply transformed to xml. I call this format stupid xml because of several shortcomings
2-MPX: de-multiplied using xsl 
3-FIX: various fixes using xsl. Contains end result produced by lvlup.py. 

Input: lvlup.py expects one of any number of documents: records in 
-so*.xml become sammlungsobjekt records,
-mm*.xml become multimediaobjekt records, 
-pk*.xml become personenKörperschaften reocrds

To retrigger the process, delete the corresponding files, e.g. if you want to retrigger the initial conversion to xml,
delete the output files in 1-XML.
