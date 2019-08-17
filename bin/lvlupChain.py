conf={
    #rougly in the order they are used...
#    "lib" : 'C:/Users/M-MM0002/Documents/PY/RST-lvlup/lib',
    'lib' : 'C:/Users/User/eclipse-workspace/RST-Lvlup/RST-levelup/lib',
    'saxon' : 'C:/Program Files/Saxonica/SaxonHE9.9N/bin/Transform.exe',

    'infiles' : ['so.xls', 'mm.xls', 'pk.xls'],

    'zerodir' : '0-IN',
    'onedir'  : '1-XML',

    'joinmpx': '1-XML/join.mpx',
    'lvlupmpx': '2-MPX/levelup.mpx',
    'fixmpx': '2-MPX/fix.mpx',

    'joinColXsl': 'lib/joinCol.xsl',
    'lvlupxsl': 'lib/lupmpx2.xsl',
    'fixxsl': 'lib/mpx-fix.xsl', 
    
    'leermpx' : 'lib/leer.mpx',
    'mpx2lido': 'lib/mpx2lido.xsl',
    'outlido' : '3-Lido/out.lido', 
}


if __name__ == "__main__":
    
    import sys
    sys.path.append (conf['lib'])
    
    #It's more pythonic to just let python report file not found exception.
    
    
    from Xls2xml import Xls2xml
    from DirTransform import DirTransform
    
    o=Xls2xml(conf) # zerodir/so.xls-> onedir/so.xml
    o.mv2zero()
    o.transformAll()  
    #saxon, source, xsl, outpath
    o=DirTransform(conf['saxon'], conf['leermpx'], conf['joinColXsl'], conf['joinmpx'])    #join
    o=DirTransform(conf['saxon'], conf['joinmpx'], conf['lvlupxsl'], conf['lvlupmpx'])
    o=DirTransform(conf['saxon'], conf['lvlupmpx'], conf['fixxsl'], conf['fixmpx'])
    o=DirTransform(conf['saxon'], conf['fixmpx'], conf['mpx2lido'], conf['outlido'])
    
    
 
