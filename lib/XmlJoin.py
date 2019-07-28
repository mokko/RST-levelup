'''
if $onedir/join.mpx doesn't exist, join all *.xml in $onedir and save the result in $onedir/join.mpx

creates temp file in $lib (B.xml, temp.mpx). If $joinpath is created that signals that join process is
complete.
'''

import os
import glob
from Saxon import Saxon
from shutil import copyfile, move


class XmlJoin:
    def __init__ (self, conf):
        dirlist=glob.glob(conf['onedir']+'/*.xml')
        if not os.path.isfile(conf['joinpath']):
            if len(dirlist) > 1:
                copyfile(dirlist[0], conf['jointemp']) # unconventional target for temp file
                dirlist.pop(0)
                #print (dirlist)
                while (len(dirlist) > 0): # 2 or bigger
                    print (dirlist)
                    copyfile(dirlist[-1], conf['lib']+'/B.xml') 
                    sn=Saxon(conf)
                    sn.transform (conf['jointemp'], conf['joinxsl'], conf['jointemp'])
                    dirlist.pop(-1)
                #after everything is joined move result to target 
                move (conf['jointemp'], conf['joinpath'])
            else:
                print ('Not enough *.xml files in %s to join anything' % conf['onedir'])
        else:
            print ('%s exists already, no joining anything' % conf['joinpath'])
        
            
if __name__ == "__main__":
    conf={
        "lib" : "C:/Users/User/eclipse-workspace/RST-Lvlup/RST-levelup/lib", # "C:/Users/M-MM0002/Documents/PY/RST-lvlup/lib",
        "onedir"  : "1-XML",
        "joinpath": "1-XML/join.mpx",
        "saxonpath" : "C:/Program Files/Saxonica/SaxonHE9.9N/bin/Transform.exe",
        "joinxsl": "lib/join.xsl",
        "jointemp": "1-XML/temp.mpx",
    }
    o=XmlJoin(conf)
        