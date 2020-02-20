conf={
    "zerodir" : "0-IN",
    "onedir"  : "1-XML",
    "twodir"  : "2-MPX",
    "threedir": "3-FIX",
    "infiles" : ['so.xls', 'mm.xls', 'pk.xls'],
    "lib" : "C:/Users/M-MM0002/Documents/PY/RST-lvlup/lib",
    "java" : "path/to/java.exe",
    "saxon" : "path/to/saxon",
}
#    "lib" : "C:/Users/M-MM0002/Documents/PY/RST-lvlup/lib",
#    "lib" : "C:/Users/User/eclipse-workspace/RST-Lvlup/RST-levelup/lib",


if __name__ == "__main__":
    
    import os
    import sys
    
    #TODO: test conf

    for each in ['lib']:
        if not os.path.exists(conf[each]):
            print ("Error: %s does not exist for %s" % (conf[each], each) )
            sys.exit(1)
    
    sys.path.append (conf['lib'])
    
    from Xls2xml import Xls2xml
    
    o=Xls2xml(conf)

