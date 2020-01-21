'''
ResourceCp.py: A class to copy resources listed with paths in xml to a destination directory of your choice

- expects sourceXml to be mpx
- writes a log with encountered problems into outdir/report.log 

USAGE:
    c=ResourceCp(sourceXml)
    c.Freigegeben (outdir)
    c.Standardbilder (outdir)

After repeated use there is a chance that images which have been deleted from source are still in the destination folder;
to avoid this: delete all image resources manually before repeated use

Doesn't do anything is destination folder already exists, so that once images have copied, they are not copied again when 
process is repeated. User needs to delete/move/backup the folder if they want to copy again. This mechanism is consistent 
with other rst-levelup modules. 
'''

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
        #line buffer so every gets written when it's written, so I can CTRL+C the program
        self._log=open(outdir+'/report.log', mode="a", buffering=1)

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

        Soll die Bilder/Ressourcen kopieren, die mit veröffentlichen="JA" gekennzeichnet sind. Dieses Feld
        wurde aber bisher nicht exportiert, also liegen keine Beispieldaten vor und diese Funktion ist 
        entsprechend ungetestet.
        '''
        self._genericCopier(outdir, 'freigegeben')


    def standardbilder (self, outdir):
        '''
        (1) copy all resources that are marked as standardbild
        (2) Output filename: $objId.$erweiterung --> there can be only one
        '''
        self._genericCopier(outdir, 'standardbilder')

        
    def boris_test (self, outdir):
        '''Boris hätte gerne einen Test aller Bilder, die einen Pfad haben. Dabei handelt es sich um einen
        Test, ob das Bild am angegebenen Ort ist.
        
        Wie erkenne ich Bilder im Unterschied zu anderen Resourcen? An der Erweiterung? 
            jpg, tif, tiff, jpeg
        Wenn Erweiterung ausgefüllt, nehme ich das ein Pfad vorhanden sein soll. 
        Ich kann testen, ob Pfad vollständig ist und ob Bild am angegebenen Ort ist.
        '''
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
                    vpfad=self._vpfad(mume) # will log incomplete path
                    if not os.path.isfile(vpfad):
                        self.write_log('%s: %s: Datei nicht am Ort' % (mulId, vpfad))
        self.close_log()

                
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
        ''' 
            new output format: oldfilename.mulId.jpg
        '''

        fg=mume.find('mpx:veröffentlichen', self.ns)
        if (fg is not None):
            if (fg.text == "JA"):
                mulId=mume.get('mulId', self.ns) #might be ok to assume it always exists
                print ('mulId: '+mulId)
                vpfad=self._vpfad(mume)
                try:
                    erw=mume.find('mpx:erweiterung', self.ns).text #higher chances that it doesn't exists
                except:
                    return # incomplete path test has been reported by _vpfad already
                out=mulId+'.'+erw
                return vpfad, out


    def _standardbilder(self, mume):

        sb=mume.find('mpx:standardbild', self.ns)
        if (sb is not None):
            #print ('   '+str(sb))

            objId=mume.find('mpx:verknüpftesObjekt', self.ns).text
            vpfad=self._vpfad(mume)
            try:
                erw=mume.find('mpx:erweiterung', self.ns).text
            except:
                return # incomplete path test has been reported by _vpfad already
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
            self.write_log('Path incomplete mulId: '+ mulId)
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
                

    def cpTifs (self, path)
        ''' TODO
        1. make a cache of tifs in directory recursively and save it to json file
        2. only if json file is missing/deleted, make it again
        3. keep the absolute path of the image and make a copy of it in json, 
        4. discard irrelevant part of the path in copy (everything including Archive)
        5. replace underline with space in json copy
        6. loop thru all HF objects in xml or only those where MM record says there is a TIFF and we have a fotograf?
        7. for each object use Ident.Nr to find corresponding tif files (in the cache).
        8. If a tif file was found, copy it to "archive" folder
        Should we try to extract Fotograf information?
        '''
                
                
if __name__ == "__main__":
    c=ResourceCp('data/WAF55/20190927/2-MPX/levelup.mpx')
    c.standardbilder('data/WAF55/20190927/shf/Standardbilder')
    c.freigegeben('data/WAF55/20190927/shf/freigegeben')