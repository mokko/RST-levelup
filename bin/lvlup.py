conf={
    #rougly in the order they are used...
#    "lib" : "C:/Users/M-MM0002/Documents/PY/RST-lvlup/lib",
    "lib" : "C:/Users/User/eclipse-workspace/RST-Lvlup/RST-levelup/lib",
    "infiles" : ['so.xls', 'mm.xls', 'pk.xls'],
    "zerodir" : "0-IN",

    "onedir"  : "1-XML",
    "saxon" : "C:/Program Files/Saxonica/SaxonHE9.9N/bin/Transform.exe",
    "joinxsl": "lib/join.xsl",
    'jointemp': '1-XML/temp.mpx',
    "joinmpx": "1-XML/join.mpx",

    "twodir"  : "2-MPX",
    "lvlupxsl": "lib/lupmpx.xsl",
    "lvlupmpx": "2-MPX/levelup.mpx",
    "fixxsl": "lib/mpx-fix.xsl", 
    "fixmpx": "2-MPX/fix.mpx", 

}
#    "lib" : "C:/Users/M-MM0002/Documents/PY/RST-lvlup/lib",


if __name__ == "__main__":
    
    import sys
    sys.path.append (conf['lib'])
    
    #It's more pythonic to just let python report file not found exception.
    
    
    from Xls2xml import Xls2xml
    from XmlJoin import XmlJoin
    from Levelup import Levelup
    from Fix import Fix
    
    o=Xls2xml(conf) # zerodir/so.xls-> onedir/so.xml
    o.mv2zero()
    o.transformAll()  
    o=XmlJoin(conf) # onedir/join.mpx
    o=Levelup(conf) # twodir/levelup.mpx
    o=Fix(conf)     # twodir/fix.mpx

