'''
lvlupChain.py : expects input files in current directory and writes to same directory 
'''
import os

conf={
    #rougly in the order they are used...
    'lib' : 'C:/Users/User/eclipse-workspace/RST-Lvlup/RST-levelup/lib',
    'saxon' : 'C:/Program Files/Saxonica/SaxonHE9.9N/bin/Transform.exe',

    'zerodir' : '0-IN',
    'onedir'  : '1-XML',

    'joinmpx': '1-XML/join.mpx',
    'lvlupmpx': '2-MPX/levelup.mpx',
    'fixmpx': '2-MPX/fix.mpx',

    'joinColxsl': 'joinCol.xsl',
    'lvlupxsl': 'lupmpx2.xsl',
    'fixxsl': 'mpx-fix.xsl', 
    
    'emptympx' : 'leer.mpx', #deprecated?
    'mpx2lido': 'mpx2lido.xsl',
    'outlido' : '3-Lido/out.lido', 
}

if os.getlogin() == 'M-MM0002':
    conf['lib'] = 'C:/Users/M-MM0002/Documents/PY/RST-lvlup/lib'
    conf['saxon'] = 'C:/Users/M-MM0002/Documents/P_Datenexport/Saxon/SaxonHE9-8-0-15J/saxon9he.jar'



if __name__ == "__main__":
    
    import sys
    sys.path.append (conf['lib'])
    
    #It's more pythonic to just let python report file not found exception.

    
    
    
    from Xls2xml import Xls2xml
    from Saxon import Saxon
    
    o=Xls2xml(conf) # zerodir/so.xls-> onedir/so.xml
    o.mv2zero()
    o.transformAll()  
    #saxon, source, xsl, outpath
    s=Saxon(conf['saxon'], conf['lib'])
    s.join (conf['emptympx'], conf['joinColxsl'], conf['joinmpx'])
    s.dirTransform(conf['joinmpx'], conf['lvlupxsl'], conf['lvlupmpx'])
    s.dirTransform(conf['lvlupmpx'], conf['fixxsl'], conf['fixmpx'])
    s.dirTransform(conf['fixmpx'], conf['mpx2lido'], conf['outlido'])
    
    
 
