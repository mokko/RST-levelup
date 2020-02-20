import shutil, json, os
from pathlib import Path
from openpyxl import Workbook, load_workbook
from os.path import expanduser
#from ntpath import splitext

'''
    We want to find certain tif images by filename. Sometimes we have a single needle (identNr), sometimes 
    we have multiple needles in an excel file. We could even have a mpx file with lots of needles. 
    Let's tacke these cases one by one.
    
    First we need to scan a certain directory recursively and save the result into memory and to json cache file.
    
    Let's use NIX style:
        $home/.tif_finder.json
    
    We need to delete the json file; for now we can do that outside of the program. 
    
    Right now we filter for permanentely for .tif* extensions
'''

class Tif_finder:
    def __init__(self): 
        home = expanduser("~")
        cache_fn=os.path.join(home, '.tif_finder.json')
        self.cache_fn=cache_fn
        print ('cache_fn %s' % cache_fn)

        if os.path.exists(cache_fn):
            print ('cache exists, loading')
            with open(cache_fn, 'r') as f:
                self.cache = json.load(f)
        else:
            print ('* No cache file not found!')


    '''Starts a new cache everytimes it's called so not a usual update function'''
    def update_cache (self, target_dir):
        print ('* Updating cache: %s' % target_dir)
        if (not os.path.isdir (target_dir)):
            raise ValueError ("Target dir '%s' does not exist" % target_dir)

        self.cache={}
        ext='tif' #using *tif*

        print ('* About to scan %s' % target_dir)
        for path in Path(target_dir).rglob('*.'+ext+'*'):
            abs = path.resolve()
            base = os.path.basename(abs)
            (trunk,ext)=os.path.splitext(base)
            print (' %s' % abs)
            #print (str(trunk))
            self.cache[str(abs)]=str(trunk)

        print ('* Writing new cache file')
        with open(self.cache_fn, 'w') as f:
            json.dump(self.cache, f)


    '''search: a simple search taking needle from command line, simply reporting matching path from cache'''
    def search (self, needle, target_dir=''):
        print ("* Searching cache for needle '%s'" % needle)
        ret=[]
        c=0
        for path in self.cache:
            #print ('%s->%s' % (path,self.cache[path]))
            if needle in self.cache[path]:
                c=c+1
                ret.append(path) 
                print (path)
                self._copy(path,target_dir)
        print ('%s matches'% c)
        return ret


    '''Take needle from Excel file (first sheet, column A) and copy file to target_dir if specified; if not just report it'''
    def search_xls (self, xls_fn, target_dir=''):
        print ("* Searching cache for needles from Excel file '%s'" % xls_fn)

        self.wb=self._prepare_wb(xls_fn)
        #ws = self.wb.active # last active sheet
        ws = self.wb.worksheets[0]
        print ('Sheet title: %s' % ws.title)
        row = ws[1] # zero or one based?
        for needle in row:
            print ('Needle: %s' % needle.value)
            if needle == 'None':
                found=self.search(needle.value)
                for f in found:
                    print ('   FOUND: %s' % f)
                    self._copy(f,target_dir)


    ''' TODO
    foreach record in lvlup.mpx
    1. identNr & objId
    2. look into cache if you find a tif for that
    3. look for mumeRecord which has TIFF signal and urheber
        findall (multimediaobjekt[verknüpftesObjekt == objId])
        dateiname
        if TIFsignal and urhebFotograf
            mulId
            urhebFotograf
        out_fn=archived/dateiname.urhebFotograf.VmulId.tif
    
    V indicates that association between that MM record and this tif is a guess; 
    i.e. it's not certain this is a version of the same photo.
    '''
    def search_mpx (self, mpx_fn):
        try: 
            shutil.copy(cached_path, out_fn) # copy2 attempts to preserve file info; why not
        except:
            print("Unexpected error:", sys.exc_info()[0])


    def show(self):
        print ('*Displaying cache contents')
        for item in self.cache:
            print (' %s' % item)
        print ('%i total number of found items' % len(self.cache))

    #############


    def _copy(self, source,target_dir):
        if target_dir != '':
            print ('cp %s -> %s' %(source, target_dir))
            try:
                shutil.copy(source, target_dir) # copy2 attempts to preserve file info;
            except:
                print ('File not found: %s' % source)


    '''Read existing xls and return workbook'''
    def _prepare_wb (self, xls_fn):

        if os.path.isfile (xls_fn):
            print ('File exists ('+ xls_fn+')')
            return load_workbook(filename = xls_fn)
        else:
            raise ("Excel File doesn't exist yet: %s" % xls_fn)
            self.new_file=1
            return Workbook()


if __name__ == "__main__":
    
    f=Tif_Finder()
