import os
from Saxon import Saxon
from Generic import Generic

class Fix (Generic):
   
    def __init__ (self, conf): 
        self.mkdir (conf['twodir'])
        
        if os.path.isfile(conf['fixmpx']):
            print ("%s exists already, no overwrite" % conf['lvlupmpx'])
        else:
            sn=Saxon(conf)
            sn.transform(conf['lvlupmpx'], conf['fixxsl'], conf['fixmpx'])


if __name__ == "__main__":
    conf={
        "twodir"  : "2-MPX",
        "saxon" : "C:/Program Files/Saxonica/SaxonHE9.9N/bin/Transform.exe",
        "lvlupmpx": "2-MPX/levelup.mpx", #source
        "fixxsl": "lib/mpx-fix.xsl", #xsl
        "fixmpx": "2-MPX/fix.mpx", #output
    }
    o=Fix(conf)