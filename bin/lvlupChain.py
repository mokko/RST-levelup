'''
lvlupChain.py : expects input files in current directory and writes generally to its output to several directories

Expects several xls files that begin with mm, so or pk.

Runs thru the tool chain and only works on files if they are not yet present. Delete them if you
want to run that process again.

STEPS:
1. Convert xls files to stupid xml
2. join all stupid xml files together in one big file
3. levelup so we have proper mpx information
4. (optional) convert to shf output format (also copies standardbilder and freigegebene photos)
5. (optional) convert to lido
6. (optional) do the boris image test and write report in corresponding directory 

If you want levelup to make the shf export, you need to run it with

    levelup.py shf
'''

import os

conf={
    #rougly in the order they are used...
    'lib' : 'C:/Users/User/eclipse-workspace/RST-Lvlup/RST-levelup/lib',
    'saxon' : 'C:/Program Files/Saxonica/SaxonHE9.9N/bin/Transform.exe',

    #dirs
    'zerodir' : '0-IN',
    'onedir'  : '1-XML',

    #in and out files etc.
    'emptympx' : 'leer.mpx', #still necessary 
    'joinmpx': '1-XML/join.mpx',
    'lvlupmpx': '2-MPX/levelup.mpx',
    'fixmpx': '2-MPX/fix.mpx',
    'outlido' : '3-Lido/out.lido', 
    'lidohtml' : '3-Lido/lido.html', 
    'vindexconf': '../vindex.json',
    'vfixmpx': '2-MPX/vfix.mpx',
    'datenblatto': '3-datenblatt/o.html',


    #xsl    
    'joinColxsl': 'joinCol.xsl',
    'lvlupxsl': 'lupmpx2.xsl',
    'fixxsl': 'mpx-fix.xsl', 
    'shfxsl': 'shf.xsl', 
    'mpx2lido': 'mpx2lido.xsl',
    'lido2html': 'lido2html.xsl',
    'Datenblatt': 'datenblatt.xsl',

#new path    
    'shfnpx' : 'shf/shf.xml',
    'shfcsv' : 'shf/shf.csv',
}

if os.getlogin() == 'M-MM0002':
    conf['lib'] = 'C:/Users/M-MM0002/Documents/PY/RST-lvlup/lib'
    conf['saxon'] = 'C:/Users/M-MM0002/Documents/P_Datenexport/Saxon/SaxonHE9-8-0-15J/saxon9he.jar'
    conf['java'] = 'C:/Program Files (x86)/Common Files/Oracle/Java/javapath/java.exe'

elif os.getlogin() == 'LENOVO USER':
    conf['lib'] = 'C:/Users/LENOVO USER/eclipse-workspace/RST-levelup/lib'
    #c:\Program Files\Saxonica\SaxonHE9.9N

if __name__ == "__main__":
    
    import sys
    sys.path.append (conf['lib'])
    
    #It's more pythonic to just let python report file not found exception.
    from Xls2xml import Xls2xml
    from Saxon import Saxon
    from ResourceCp import ResourceCp
    from Npx2csv import Npx2csv
    
    print ('*Looking for input...')
    o=Xls2xml(conf) 
    o.mv2zero() # moves files to 0-IN

    print ('*First conversion...')
    o.transformAll() #input from 0-IN output to 1-XML  

    print ('*Joining...')
    s=Saxon(conf, conf['lib']) 
    if os.path.isdir(conf['onedir']): 
        s.join (conf['emptympx'], conf['joinColxsl'], conf['joinmpx'])

    print ('*Levelling up...')    
    if os.path.isfile(conf['joinmpx']): 
        s.dirTransform(conf['joinmpx'], conf['lvlupxsl'], conf['lvlupmpx']) #input from 1-XML writes to 2-MPX

    #s.dirTransform(conf['lvlupmpx'], conf['fixxsl'], conf['fixmpx'])
    #todo: use indexes produced by ExcelTool to cleanup the output
    
    if len(sys.argv) > 1:
        if sys.argv[1].lower() == 'shf':
            ''' 
            (1) copy Standardbilder based on levlup.mpx to subfolder Standardbilder mit Namen $objId.$erweiterung
            (2) alle freigegebenen Bilder in Unterverzeichnis Freigegeben mit Muster $mulId.$erweiterung
            '''
            print ('*Converting to SHF format...')
            if os.path.isfile(conf['lvlupmpx']):     
                s.dirTransform(conf['lvlupmpx'], conf['shfxsl'], conf['shfnpx'])
                n=Npx2csv (conf['shfnpx'], conf['shfcsv'])    
                c=ResourceCp (conf['lvlupmpx']) # init
                c.standardbilder('shf/Standardbilder')
                c.freigegeben('shf/Freigegeben')

        elif sys.argv[1].lower() == 'index':
            print ('*Vocabulary index...')
            if os.path.isfile(conf['vindexconf']):
                from ExcelTool import ExcelTool
                t=ExcelTool.from_conf (conf['vindexconf'],conf['lvlupmpx']) #make index if there is none
                t.apply_fix (conf['vindexconf'],conf['vfixmpx'])

        elif sys.argv[1].lower() == 'lido':
            print ('*Converting to LIDO...')
            if os.path.isfile(conf['lvlupmpx']): #soon input file will be vfixmpx     
                s.dirTransform(conf['lvlupmpx'], conf['mpx2lido'], conf['outlido'])
                s.dirTransform(conf['outlido'], conf['lido2html'], conf['lidohtml'])

        elif sys.argv[1].lower() == 'boris':
            print ('*Working on Boris Test...')
            if os.path.isfile(conf['lvlupmpx']):
                c=ResourceCp (conf['lvlupmpx']) 
                c.boris_test('boris_test')

        elif sys.argv[1].lower() == 'datenblatt':
            print ('*Converting to Deckblatt HTML ...')
            #if os.path.isfile(conf['lvlupmpx']):
            s.dirTransform(conf['lvlupmpx'], conf['Datenblatt'], conf['datenblatto'])
                #s.dirTransform(conf['outlido'], conf['lido2html'], conf['lidohtml'])
