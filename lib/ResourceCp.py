""" class that copies resources listed in xml to a destination directory of your choice

- expects sourceXml to be mpx
- writes a log with encountered problems into outdir/report.log 

USAGE:
    c=ResourceCp(sourceXml)
    c.Freigegeben (outdir)
    c.Standardbilder (outdir)

Sloppy Update:
    ResourceCp used to copy files only when outdir didn't exist; now it copies
    resources as long as target file doesn't exist. There is no overwriting
    of old file in case resource has changed. 
    Also files deleted from sourceXML are not deleted from cache directory.
    Currently, you need to manually delete the respective cache directories 
    to trigger the creation of an up-to-date cache.
"""

import xml.etree.ElementTree as ET
import os
import sys 
import shutil
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
        #line buffer so everything gets written when it's written, so I can CTRL+C the program
        self._log=open(outdir+'/report.log', mode="a", buffering=1)

    def write_log (self, msg):
        self._log.write(f"[{datetime.datetime.now()}] {msg}\n")
        print (msg)

    def close_log (self):
        self._log.close()


    def freigegeben (self, outdir):
        """
        freigegeben are only those photos that fulfill both conditions 
        a) are not Standardbilder
        b) mpx:veröffentlichen = ja
        Output filename: mulId.jpg (where erweiterung is always lowercase)

        We are considering to rename them to something like: oldfilename.mulId.jpg. Advantage would
        be to preserve the original filename, disadvantage would that I can't guess the filename any longer
        just from knowing the mulId. So what should I do?
        """
        self._genericCopier(outdir, 'freigegeben')


    def mulId (self, outdir):
        """cp resources to mulId.jpg"""
        self._genericCopier(outdir, 'mulId')


    def standardbilder (self, outdir):
        """cp standardbild to outdir/$objId.$erweiterung
        
        For SHF. There can be only one standardbild per object.
        """
        self._genericCopier(outdir, 'standardbilder')


    def cpFile (self, in_path, out_path):
        """cp file to out_path while reporting missing files 

        If out_path exists already, overwrite only if source is newer than target."""

        if not os.path.isfile(in_path):
            self.write_log(f'File not found: {in_path}')
            return
        if os.path.exists(out_path): 
            #overwrite ONLY if source is newer
            if os.path.getmtime(out_path) > os.path.getmtime(out_path):
                self._cpFile(in_path, out_path)
        else:
                self._cpFile(in_path, out_path)


    def _cpFile(self, in_path, out_path):
        #print (in_path +'->'+out_path)
        #shutil.copy doesn't seem to raise exception if source file not found
        try: 
            # copy2 preserves file info
            shutil.copy2(in_path, out_path) 
        except:
            print(f"Unexpected error: {sys.exc_info()[0]}")


    def boris_test (self, outdir):
        """ Boris möchte alle Bilder, die einen Pfad haben auf dead links testen. 
        
        Wie erkenne ich Bilder im Unterschied zu anderen Resourcen? An der Erweiterung? 
            jpg, tif, tiff, jpeg
        Wenn Erweiterung ausgefüllt, nehme ich das ein Pfad vorhanden sein soll."""

        if os.path.isdir(outdir): #anything to do at all?
            print (outdir+' exists already, nothing tested') #this message is not important enough for logger
            return
        os.makedirs(outdir)
        self.init_log(outdir) 

        for mume in self.tree.findall("./mpx:multimediaobjekt", self.ns):
            try:
                erw=mume.find('mpx:erweiterung', self.ns).text
            except: pass #really nothing to do
            else: 
                mulId=mume.get('mulId', self.ns) #might be ok to assume it always exists
                #print ('Testing mulId %s %s' % (mulId, erw))
                if erw.lower() == 'jpg' or erw.lower == 'jpeg' or erw.lower == 'tif' or erw.lower == 'tiff':
                    vpfad=self._fullpath(mume) # will log incomplete path
                    if vpfad is not None:
                        if not os.path.isfile(vpfad):
                            self.write_log('%s: %s: Datei nicht am Ort' % (mulId, vpfad))
        self.close_log()


    #############
    #############

    def _genericCopier (self, outdir, mode):
        if not os.path.isdir(outdir): #anything to do at all?
            os.makedirs(outdir)
        self.init_log(outdir) 

        print (f'*Working on {mode}')
        
        for mume in self.tree.findall("./mpx:multimediaobjekt", self.ns):
            if mode == 'freigegeben':
                ret=self._freigegeben(mume)
            elif mode == 'standardbilder':
                ret=self._standardbilder(mume)
            elif mode == 'mulId':
                ret=self._mulId(mume)
            else:
                raise RuntimeError ('Unknown mode. Internal error.')
            if type(ret) is tuple:
                vpfad,out=ret
                out=outdir+'/'+out
                try:
                    self.cpFile (vpfad, out)
                except:
                    self.write_log (f'File not found: {vpfad}')
        self.close_log()


    def _freigegeben (self, mume):
        """ See self.freigegeben """

        fg=mume.find('mpx:veröffentlichen', self.ns)
        stdb=mume.find('mpx:standardbild', self.ns)

        if (fg is not None and stdb is None):
            if (fg.text.lower() == "ja"):
                mulId=mume.get('mulId', self.ns) #might be ok to assume it always exists
                print (f'freigegeben-mulId: {mulId}')
                vpfad=self._fullpath(mume)
                try:
                    erw=mume.find('mpx:erweiterung', self.ns).text #higher chances that it doesn't exists
                except:
                    return # incomplete path test has been reported by _fullpath already
                out=f"{mulId}.{erw.lower()}"
                return vpfad, out


    def _standardbilder(self, mume):

        sb=mume.find('mpx:standardbild', self.ns)
        if (sb is not None):
            #print ('   '+str(sb))

            objId=mume.find('mpx:verknüpftesObjekt', self.ns).text
            vpfad=self._fullpath(mume)
            try:
                erw=mume.find('mpx:erweiterung', self.ns).text
            except:
                return # incomplete path test has been reported by _fullpath already
            out=f"{objId}.{erw.lower()}"
            return vpfad, out

    def _mulId (self, mume):
        mulId=mume.find('@mulId', self.ns).text
        try:
            erw=mume.find('mpx:erweiterung', self.ns).text
        except:
            return # incomplete path test has been reported by _fullpath already
        out=f"{mulId}.{erw.lower()}"
        vpfad=self._fullpath(mume)
        return vpfad,out


    def _fullpath (self, mume):
        """
        Expects multimediaobjekt node and returns full mume path. If path 
        has no pfadangabe or dateiname it writes an error message to logfile
        and returns None
        """
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
            self.write_log(f'Path incomplete mulId: {mulId}')
            return #returns None, right?
        return f"{pfad}\\{datei}.{erw}"



if __name__ == "__main__":
    c=ResourceCp('data/WAF55/20190927/2-MPX/levelup.mpx')
    c.standardbilder('data/WAF55/20190927/shf/Standardbilder')
    c.freigegeben('data/WAF55/20190927/shf/freigegeben')