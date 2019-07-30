import os
from Saxon import Saxon
from Generic import Generic


class Levelup (Generic):
    def __init__ (self, conf): 
        self.mkdir (conf['twodir'])
        if os.path.isfile(conf['lvlupmpx']):
            print ("%s exists already, no overwrite" % conf['lvlupmpx'])
        else:
            sn=Saxon(conf)
            sn.transform(conf['joinmpx'], conf['lvlupxsl'], conf['lvlupmpx'])


if __name__ == "__main__":
    conf={
        "twodir"  : "2-MPX",
        "saxon" : "C:/Program Files/Saxonica/SaxonHE9.9N/bin/Transform.exe",
        "joinmpx": "1-XML/join.mpx",
        "lvlupxsl": "lib/lupmpx.xsl",
        "lvlupmpx": "2-MPX/levelup.mpx",
    }
    o=Levelup(conf)
