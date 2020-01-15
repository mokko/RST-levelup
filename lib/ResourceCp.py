'''
ResourceCp.py: A class to copy resources listed with paths in xml to a directory of your choice

- expects sourceXml to be mpx
- writes a log encountered problems into outdir/report.log 

USAGE:
    c=ResourceCp(sourceXml)
    c.Freigegeben (outdir)
    c.Standardbilder (outdir)

After repeated use there is a chance that images which have been deleted from source are still in the destination folder;
to avoid this: delete all image resources manually before repeated use 
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


    def init_log (self,outdir):
        self._log=open(outdir+'/report.log', "a")

    def write_log (self, msg):
        self._log.write("[" + str(datetime.datetime.now()) + "] "+ msg+'\n' )
        print (msg)


    def close_log (self):
        self._log.close()


    def freigegeben (self, outdir):
        '''
        UNTESTED
        (1) copy all resources that are marked as freigeben = JA
        (2) output filename is $mulId.$erweiterung -> multiple resources per object possible
        '''
        self._genericCopier(outdir, 'freigegeben')


    def standardbilder (self, outdir):
        '''
        (1) copy all resources that are marked as standardbild
        (2) Output filename: $objId.$erweiterung --> there can be only one
        '''
        self._genericCopier(outdir, 'standardbilder')


    def _genericCopier (self, outdir, mode):
        if os.path.isdir(outdir): #anything to do at all?
            print (outdir+' exists already, nothing copied') #this message is not important enough for logger
            return
        os.makedirs(outdir)
        self.init_log(outdir) 

        for mume in self.tree.findall("./mpx:multimediaobjekt", self.ns):
            if mode == 'freigegeben':
                ret=self._freigegeben(mume)
            elif mode == 'standardbilder':
                ret=self._standardbilder(mume)
            else:
                raise RuntimeError ('Unknown mode. Internal error.')
            if type(ret) is tuple:
                vpfad,out=ret
                out=outdir+'/'+out
                try:
                    self.cpFile (vpfad, out)
                except:
                    self.write_log ('File not found: '+ vpfad)
        self.close_log()

    
    def _freigegeben (self, mume):
        fg=mume.find('mpx:freigabe', self.ns)
        if (fg is not None):
            if (fg.text == "JA"):
                mulId=mume.get('mulId', self.ns) #might be ok to assume it always exists
                print ('mulId: '+mulId)
                try:
                    erw=mume.find('mpx:erweiterung', self.ns).text #higher chances that it doesn't exists
                except:
                    erw='' # incomplete path test is coming...
                vpfad=self._vpfad(mume)
                out=mulId+'.'+erw
                return vpfad, out

                
    def _standardbilder(self, mume):

        sb=mume.find('mpx:standardbild', self.ns)
        if (sb is not None):
            #print ('   '+str(sb))

            objId=mume.find('mpx:verknüpftesObjekt', self.ns).text
            erw=mume.find('mpx:erweiterung', self.ns).text
            vpfad=self._vpfad(mume)
            out=objId+'.'+erw
            return vpfad, out

    
    def _vpfad (self, mume):
        error=0
        mulId=mume.get('mulId', self.ns) #might be ok to assume it always exists
        try:
            pfad=mume.find('mpx:pfadangabe', self.ns).text
        except:
            error=1
        try:
            erw=mume.find('mpx:erweiterung', self.ns).text
        except:
            error=1
        try:
            datei=mume.find('mpx:dateiname', self.ns).text
        except:
            error=1

        if error==1:
            self.write_log('Path incomplete: '+ mulId)
            return #returns None, right?
        return pfad + '\\' + datei + '.'+ erw


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
            self.write_log('File not found: ' + in_path)
                

if __name__ == "__main__":
    c=ResourceCp('data/WAF55/20190927/2-MPX/levelup.mpx')
    c.standardbilder('data/WAF55/20190927/shf/Standardbilder')
    c.freigegeben('data/WAF55/20190927/shf/freigegeben')