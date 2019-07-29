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
    "joinpath": "1-XML/join.mpx",

    "twodir"  : "2-MPX",
    "threedir": "3-FIX",
}
#    "lib" : "C:/Users/M-MM0002/Documents/PY/RST-lvlup/lib",


if __name__ == "__main__":
    
    import sys
    
    #import os
    #TODO: It's more pythonic to just let python report file not found exception.
    #for each in ['lib']:
    #    if not os.path.exists(conf[each]):
    #        print ("Error: %s does not exist for %s" % (conf[each], each) )
    #        sys.exit(1)
    
    sys.path.append (conf['lib'])
    
    from Xls2xml import Xls2xml
    from XmlJoin import XmlJoin
    
    o=Xls2xml(conf)
    o=XmlJoin(conf)
