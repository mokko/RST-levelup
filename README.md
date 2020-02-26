# RST-levelup
Tool chain to transform exports

transforms excel reports from M+ to mpx. 

This is a python rewrite of an earlier version of this toolchain that was written in perl. (I still miss the wonderful perl community.)

USAGE
>>cd AmerikaSM/20190726  
>>path/to/lvlupChain.py

Some functionality is not always required and needs a parameter, e.g.
>>path/to/lvlupChain.py index

For details see the script in bin directory.

The script creates several subdirectories which document what's going on under the hood: e.g.

- 0-IN: has original excel files
- 1-XML: has excel tables simply transformed to xml. I call this format stupid xml because of several shortcomings, mainly it's in a matrix form where  entries can be  multiplied
- 2-MPX: single entry form (i.e. de-multiplied, not as matrix) using xsl

Input: lvlup.py expects one of any number of documents: records in 
- so*.xml become sammlungsobjekt records,
- mm*.xml become multimediaobjekt records, 
- pk*.xml become personenKörperschaften reocrds

To retrigger the process, delete the corresponding files, e.g. if you want to retrigger the initial conversion to xml,
delete the output files in 1-XML. Almost nothing ever gets overwritten, you have to manually delete stuff and execute again to produce new stuff.
