""" make and process mpx.

expects input files in current directory and generally writes its output to 
several sub-directories

This Python thingy works much like a shell script: It starts processes, 
frequently writes stuff to files and processes one thing after the next.

Expects several so*.xls, mm*.xls or pk*.xls in current working directory.

Outputs: 2-MPX/vfix.mpx and mpxvoc.xml, 
optional: shf.csv

Runs thru the tool chain and only works on files if they are not yet present. 
Delete them if you want to run that process again.

STEPS:
1. Convert xls files to stupid xml
2. join all stupid xml files together in one big file
3. levelup that file so we have proper mpx 
4. ExcelTool--> vindex and translate.xlsx are updated
5. ExcelTool--> vfix.mpx written
6. copies resources (for deckblatt, lido, shf)
7. (optional) carry out boris image test and write report in corresponding 
   directory --> boris
8. (optional) shf.csv -->shf
9. (optional) make a rst deckblatt HTML representation out of the mpx file --> datenblatt 

Optional function via command line parameter:
    lvlupChain.py --short #not all steps
    lvlupChain.py cmd shf
    lvlupChain.py cmd datenblatt # from mpx
    lvlupChain.py cmd boris
"""

import argparse
import os
import sys
import subprocess #more imports below
from glob import glob
from shutil import copyfile

conf={
    #rougly in the order they are used...
    'saxon' : 'C:/Program Files/Saxonica/SaxonHE9.9N/bin/Transform.exe',

    #dirs
    'zerodir' : '0-IN',
    'onedir'  : '1-XML',
    'tifdir': '../tif',

    #in and out files etc.
    'emptympx' : 'leer.mpx', #still necessary 
    'joinmpx': '1-XML/join.mpx',
    'lvlupmpx': '2-MPX/levelup.mpx',
    'fixmpx': '2-MPX/fix.mpx',
    'vindexconf': '../../../data2/generalvindex.json',
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
    'splitLido': 'splitLido.xsl',
    'lido2datenblatt': 'lido2datenblatt.xsl',

    #new path    
    'shfnpx' : 'shf/shf.xml',
    #'shfcsv' : 'shf/shf.csv', #baked into Npx2xcsv
}

conf['t']=os.path.realpath(os.path.join(__file__,'../../test'))
conf['lib']=os.path.realpath(os.path.join(__file__,'../../lib'))
#conf['tshf']=os.path.join(conf['t'],'test_shf.py')

if os.getlogin() == 'M-MM0002':
    conf['saxon'] = 'C:/Users/M-MM0002/Documents/P_Datenexport/Saxon/SaxonHE9-8-0-15J/saxon9he.jar'
    conf['java'] = 'C:/Program Files (x86)/Common Files/Oracle/Java/javapath/java.exe'
    #elif os.getlogin() == 'LENOVO USER':
    #c:\Program Files\Saxonica\SaxonHE9.9N
elif os.getlogin() == 'mauri':
    saxon= "C:/Program Files/Saxonica/SaxonHE9.9N/bin/Transform.exe",

def cp_data2 ():
    print (f"*Copying data for github")
    files = glob('../**/*.xlsx', recursive=True)
    for src in files:
        src=os.path.realpath(src)
        dst=src.replace("data", "data2", 1)
        if "bak\\" not in src.lower():
            #print (f"   {src} ")
            try:
                copyfile(src, dst)
            except Exception as e:
                print (e)

def mk_mpx (conf):
    print ('*Looking for input...')
    o = Xls2xml(conf) 
    o.mv2zero() # moves files to 0-IN

    print ('*First conversion...')
    o.transformAll() #input from 0-IN output to 1-XML  

    print ('*Joining...')
    s = Saxon(conf, conf['lib'])
    if os.path.isdir(conf['onedir']): 
        s.join (conf['emptympx'], conf['joinColxsl'], conf['joinmpx'])

    print ('*Leveling up...')
    if os.path.isfile(conf['joinmpx']): 
        s.dirTransform(conf['joinmpx'], conf['lvlupxsl'], conf['lvlupmpx']) 

    test_mpx.main(conf['lvlupmpx'])

def cp_resources (conf):
    rc = ResourceCp (conf['lvlupmpx'])
    rc.standardbilder('..\pix', 'mulId.dateiname')
    rc.freigegebene('..\pix', 'mulId.dateiname')

def run_ExcelTool(conf):
    print ('*Updating vindex...')
    if os.path.isfile(conf['vindexconf']): #make/update vindex 
        t = ExcelTool.from_conf (conf['vindexconf'],conf['lvlupmpx'], '..') 
    else: 
        raise ValueError (f"Error: vindexconf not found! {conf['vindexconf']}")

    if not os.path.exists(conf['vfixmpx']):
        print ("*APPLYING FIX")
        t.apply_fix (conf['vindexconf'],conf['vfixmpx'])
        #writes individual translate.xlsx files
    t = ExcelTool.translate_from_conf (conf['vindexconf'],conf['vfixmpx'], '..')

if __name__ == "__main__":
    
    #print ("lib: %s" % conf['lib'])
    sys.path.append (conf['lib'])
    sys.path.append (conf['t'])
    
    from Xls2xml import Xls2xml
    from Saxon import Saxon
    from ResourceCp import ResourceCp
    from Npx2csv import Npx2csv
    from ExcelTool import ExcelTool
    from Tif_finder import Tif_finder
    from vok2vok import vok2vok
    import test_shf as tshf
    import test_mpx

    parser = argparse.ArgumentParser(description='lvlupChain: batch process mpx')
    parser.add_argument('-s', '--short', action='store_true')
    parser.add_argument('-c', '--cmd')
    args = parser.parse_args()

    mk_mpx(conf)
    if not args.short:
        cp_resources (conf)
        run_ExcelTool(conf)
        cp_data2() # save xlsx to github 
        print ("*VOK2VOK") #assembles individual dictionaries into one
        vok2vok ('../..', '../../../data2/mpxvoc.xml') # work on data dir

    if args.cmd == 'shf':
        print ('*Converting to SHF csv format...')
        if os.path.isfile(conf['vfixmpx']):
            s = Saxon(conf, conf['lib'])
            s.dirTransform(conf['vfixmpx'], conf['shfxsl'], conf['shfnpx'])
            n = Npx2csv (conf['shfnpx'])
            #you might need to prepare or delete the cache file manually
            tf = Tif_finder('../../../.tif_cache.json')
            tf.search_mpx(conf['lvlupmpx'], conf['tifdir'])
            tshf.main(conf['vfixmpx'], conf ['shfnpx'])

    elif args.cmd == 'boris':
        print ('*Working on Boris Test...')
        if os.path.isfile(conf['lvlupmpx']):
            rc = ResourceCp (conf['lvlupmpx']) 
            rc.boris_test('boris_test')

    #this datenblatt is made directly from mpx; other one is made from lido
    elif args.cmd == 'datenblatt':
        print ('*Converting to Deckblatt HTML ...')
        s = Saxon(conf, conf['lib'])
        s.dirTransform(conf['vfixmpx'], conf['Datenblatt'], conf['datenblatto'])
