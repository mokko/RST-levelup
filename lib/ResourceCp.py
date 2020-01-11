'''
ResourceCp.py: A class to copy resources listed with paths in xml to a directory of your choice

expects sourceXml to be mpx

TODO: Currently writes only one log file not two separate ones 
'''

import xml.etree.ElementTree as ET
import os
import sys 
import shutil
#import logging
import datetime

_verbose=1
def verbose (msg):
    if _verbose: 
        print (msg)
        

class ResourceCp:
    def __init__ (self, sourceXml):
        #load XML
        self.tree = ET.parse(sourceXml)
        #verbose ('FOUND ' + sourceXml)

        self.ns = {
            'mpx': 'http://www.mpx.org/mpx',
        }


    '''not used'''
    def _vpfad (self, mume_node):
        pfad=mume.find('mpx:pfadangabe', self.ns).text
        erw=mume.find('mpx:erweiterung', self.ns).text
        datei=mume.find('mpx:dateiname', self.ns).text
        return pfad + '\\' + datei + '.'+ erw

    def _cpBilder (self, outdir):

        if os.path.isdir(outdir):
            print (outdir+' exists already, nothing copied')
            return
        os.makedirs(outdir)
        return open(outdir+'/report.log', "a")


    
    def freigegeben (self, outdir):
        '''
        UNTESTED
        (1) copy all resources that are marked as freigeben = JA
        (2) output filename is $mulId.$erweiterung -> multiple resources per object possible
        (3) write error messages to log file
        '''
        if os.path.isdir(outdir):
            print (outdir+' exists already, nothing copied')
            return
        os.makedirs(outdir)
        log = open(outdir+'/report.log', "a")
    
        for mume in self.tree.findall("./mpx:multimediaobjekt", self.ns):
            fg=mume.find('mpx:freigabe', self.ns)
            if (fg is not None):
                if (fg.text == "JA"):
                    pfad=mume.find('mpx:pfadangabe', self.ns).text
                    datei=mume.find('mpx:dateiname', self.ns).text
                    erw=mume.find('mpx:erweiterung', self.ns).text
                    mulId=mume.get('mulId', self.ns)
                    vpfad=pfad + '\\' + datei + '.'+ erw

                    out=outdir+'/'+mulId+'.'+erw
                    verbose (out)
                    try:
                        self.cpFile (vpfad, out)
                    except:
                        msg='File not found: '+ vpfad 
                        log.write("[" + str(datetime.datetime.now()) + "] "+ msg+'\n' )
                        print (msg)
        log.close()


    def standardbilder (self, outdir):
        '''
        (1) copy all resources that are marked as standardbild
        (2) Output filename: $objId.$erweiterung --> there can be only one
        (3) $outdir/report.log has info on files that have not been found
        
        after repeated use there is a chance that images which have been deleted from source are still in the destination folder;
        to avoid this: delete all image resources manually before repeated use 
        '''
        if os.path.isdir(outdir):
            print (outdir + ' exists already, nothing copied')
            return
        os.makedirs(outdir)

        log = open(outdir+'/report.log', "a")
                        
        for mume in self.tree.findall("./mpx:multimediaobjekt", self.ns):
            #print (mume)
            sb=mume.find('mpx:standardbild', self.ns)
            if (sb is not None):
                #print ('   '+str(sb))
                pfad=mume.find('mpx:pfadangabe', self.ns).text
                erw=mume.find('mpx:erweiterung', self.ns).text
                datei=mume.find('mpx:dateiname', self.ns).text
                vpfad=pfad + '\\' + datei + '.'+ erw
                objId=mume.find('mpx:verknüpftesObjekt', self.ns).text
                out=outdir+'/'+objId+'.'+erw
                #verbose (vpfad + '->' + out)
                try:
                    self.cpFile (vpfad, out)
                except:
                    msg='File not found: '+ vpfad 
                    log.write("[" + str(datetime.datetime.now()) + "] "+ msg+'\n' )
                    print (msg)
        log.close()

    
    def cpFile (self, in_path, out_path):
        '''
        self.cpFile (in, out): cp file to target path while reporting missing files 
        '''
        #shutil.copy doesn't seem to raise exception if source file not found
        if os.path.isfile(in_path):
            #print (in_path +'->'+out_path)
            try: 
                shutil.copy2(in_path, out_path) # copy2 attempts to preserve file info; why not
            except:
                print("Unexpected error:", sys.exc_info()[0])
        else:
            raise ValueError('File not found: ' + in_path)
                

if __name__ == "__main__":
    copier=ResourceCp('data/WAF55/20190927/2-MPX/levelup.mpx')
    copier.standardbilder('outdir')
    copier.freigegeben('freigegeben')