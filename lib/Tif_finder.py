import shutil, json, os
from pathlib import Path
from openpyxl import Workbook, load_workbook
from os.path import expanduser

"""
    Find tif images by filename/identNr. Sometimes we have a single needle (identNr), sometimes 
    we have multiple needles in an excel file. We could even have a mpx file with lots of needles. 
    Let's tacke these cases one by one.
    
    First we need to scan a certain directory recursively and save the result to a json cache file.
    
    For command line let's use NIX style:
        $home/.tif_finder.json
    From lvlup let's use a user-defined dir
    
    Use external program to delete cache. 
    
    Right now we filter for 'permanently' for .tif* extensions
"""

class Tif_finder:
   
    def __init__(self, scan_dir=None, cache_fn=None): 
        """
        scan_dir: directory that should be scanned (optional); 
        in CLI mode this can be specified later.
    
        cache_fn: location (path) of cache file; can be specified for use inside
        levelup.
    
        For CLI mode assume that cache is at ~/.tif_finder.json; -> todo
        For use inside of levelup expect location from data directory
        """
        if cache_fn is None:
            home = expanduser("~")
            cache_fn=os.path.join(home, '.tif_finder.json')
        self.cache_fn=cache_fn
        #print ('cache_fn %s' % cache_fn)

        if os.path.exists(cache_fn):
            #print ('cache exists, loading')
            with open(cache_fn, 'r') as f:
                self.cache = json.load(f)
        else:
            #print ('* Cache file not found!')
            if scan_dir is not None: # in cli mode you need to update your cache manually
                self.mk_new_cache(scan_dir)


    def mk_new_cache (self, scan_dir):
        """
        Scans directory and writes results to cache file, overwriting any
        previous contents, if any. 
        
        scan_dir needs to be a directory
        """
        print ('* Making new cache: %s' % scan_dir)
        if (not os.path.isdir (scan_dir)):
            raise ValueError ("Target dir '%s' does not exist" % scan_dir)

        self.cache={}
        ext='tif' #using *tif*

        print ('* About to scan %s' % scan_dir)
        for path in Path(scan_dir).rglob('*.'+ext+'*'):
            abs = path.resolve()
            base = os.path.basename(abs)
            (trunk,ext)=os.path.splitext(base)
            print (' %s' % abs)
            #print (str(trunk))
            self.cache[str(abs)]=str(trunk)

        print ('* Writing new cache file')
        with open(self.cache_fn, 'w') as f:
            json.dump(self.cache, f)


    def search (self, needle):
        """
        search: a simple search with a single needle, returns matches from 
        cache as a list; i.e. there can be multiple matches.
        
        ls=self.search(needle)
        
        """
        #print ("* Searching cache for needle '%s'" % needle)
        ret=[]
        c=0
        for path in self.cache:
            #print ('%s->%s' % (path,self.cache[path]))
            if needle in self.cache[path]:
                c+=1
                ret.append(path) 
                #print (path)
        print ('%s -> %i' % (needle,c))
        return ret


    def search_xls (self, xls_fn, target_dir=''):
        """
        Take needle from Excel file (first sheet, column A). If target_dir is 
        specified copy file there; if target_dir is None just report matching
        paths to STDOUT
        """

        print ("* Searching cache for needles from Excel file '%s'" % xls_fn)

        self.wb=self._prepare_wb(xls_fn)
        #ws = self.wb.active # last active sheet
        ws = self.wb.worksheets[0]
        print ('* Sheet title: %s' % ws.title)
        col = ws['A'] # zero or one based?
        for needle in col:
            #print ('Needle: %s' % needle.value)
            if needle != 'None':
                found=self.search(needle.value)
                if target_dir is None:
                    print('found %s' % found)
                else:
                    for f in found:
                        #print ('   FOUND: %s' % f)
                        self._copy_to_dir(f,target_dir)


    def search_mpx (self, mpx_fn):
        """ TODO
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
        """
        try:pass 
            #shutil.copy(cached_path, out_fn) # copy2 attempts to preserve file info; why not
        except:
            print("Unexpected error:", sys.exc_info()[0])


    def show(self):
        """prints contents of cache to STDOUT"""

        print ('*Displaying cache contents')
        if hasattr (self, 'cache'):
            for item in self.cache:
                print (' %s' % item)
            print ('%i total number of found items' % len(self.cache))
        else:
            print (' Cache does not exist!')

    #############

    
    def _target_fn (self, fn):
        """
        Check if target exists. If so , find new variant that does not yet 
        exist according to the following schema
                path/to/base.ext
                path/to/base (1).ext
                path/to/base (2).ext
        """
        new=fn
        i=1
        while os.path.exists (new):
            #print ('Target exists already')
            trunk,ext=os.path.splitext(fn)
            new= '%s (%i)%s' % (trunk, i, ext)
            i=i+1
        print ('[%i] %s' % (i, new))
        return new


    def _copy_to_dir(self, source,target_dir):
        """ 
        Copy source file to target dir. If there already is a file with 
        that name find a new name that doesn't exist yet. 
        
        Upside: we can have multiple tifs for one identNr. 
        Downside: new filenames don't necessarily match the old ones and it 
        will be difficult to reconstruct what has been copied from where to 
        where.
        """
        if target_dir != '':
            #print ('cp %s -> %s' %(source, target_dir))
            base = os.path.basename(source)
            target_fn=self._target_fn (os.path.join(target_dir, base)) # should be full path
            
            try: 
                shutil.copy(source, target_fn) # copy2 attempts to preserve file info;
            except:
                print ('File not found: %s' % source)


    def _prepare_wb (self, xls_fn):
        """Read existing xls and return workbook"""

        if os.path.isfile (xls_fn):
            print ('File exists ('+ xls_fn+')')
            return load_workbook(filename = xls_fn)
        else:
            raise ("Excel file not found: %s" % xls_fn)


if __name__ == "__main__":
    
    f=Tif_Finder()
