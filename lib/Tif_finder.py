import shutil, json, os
from pathlib import Path
from openpyxl import Workbook, load_workbook
from lxml import etree

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
    def __init__(self, cache_fn, scan_dir=None): 
        """
        scan_dir: directory that should be scanned (optional); 
        in CLI mode this can be specified later.
    
        cache_fn: location (path) of cache file; can be specified for use inside
        levelup.
    
        For CLI mode assume that cache is at ~/.tif_finder.json; -> todo
        For use inside of levelup expect location from data directory
        """
        self.cache_fn=cache_fn
        #print ('cache_fn %s' % cache_fn)

        if os.path.exists(self.cache_fn):
            #print ('cache exists, loading')
            with open(self.cache_fn, 'r') as f:
                self.cache = json.load(f)
        else:
            #we can only fill the empty cache if we have a scan_dir
            if scan_dir is not None: 
                self.scandir(scan_dir)


    def scandir (self, scan_dir):
        """
        Scans directory for *.tif? files and writes results to cache file, 
        updating existing info in cache file.

        scan_dir needs to be a directory.

        Update does not remove cache entries for files that have been removed 
        from disk.

        You can scan multiple directories by running the scan multiple times.
        """
        if (not os.path.isdir (scan_dir)):
            raise ValueError (f"Scan dir '{scan_dir}' does not exist")

        if os.path.exists(self.cache_fn):
            with open(self.cache_fn, 'r') as f:
                self.cache = json.load(f)

        if not hasattr(self, 'cache'):
            self.cache={}

        print (f"* About to scan {scan_dir}")
        for path in Path(scan_dir).rglob('*.tif?'):
            abs = path.resolve()
            base = os.path.basename(abs)
            (trunk,ext)=os.path.splitext(base)
            print (f"{abs}")
            #print (str(trunk))
            self.cache[str(abs)]=str(trunk)

        print ('* Writing updated cache file')
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
        #print (f"{needle} -> {c}")
        return ret


    def search_xls (self, xls_fn, target_dir=''):
        """
        Take needle from Excel file (first sheet, column A). If target_dir is 
        specified copy file there; if target_dir is None just report matching
        paths to STDOUT
        """

        print (f"* Searching cache for needles from Excel file {xls_fn}")

        self.wb=self._prepare_wb(xls_fn)
        #ws = self.wb.active # last active sheet
        ws = self.wb.worksheets[0]
        print (f"* Sheet title: {ws.title}")
        col = ws['A'] # zero or one based?
        for needle in col:
            #print ('Needle: %s' % needle.value)
            if needle != 'None':
                found=self.search(needle.value)
                print(f'found {found}')
                if target_dir is not None:
                    for f in found:
                        self._copy_to_dir(f,target_dir)


    def search_mpx (self, mpx_fn, target_dir):
        """
        for each identNr from mpx look for tifs in cache and copy them to 
        target_dir
        """
        
        if os.path.isdir (target_dir):
            print(f"{target_dir} exists already, nothing copied")
        else:
            target_dir=os.path.realpath(target_dir)
            os.makedirs (target_dir)
            tree = etree.parse(mpx_fn)
            r = tree.xpath('/m:museumPlusExport/m:sammlungsobjekt/m:identNr', 
                namespaces={'m':'http://www.mpx.org/mpx'})

            for identNr_node in r:
                tifs=self.search (identNr_node.text)
                #print(identNr.text)
                objId=tree.xpath(f"/m:museumPlusExport/m:sammlungsobjekt/@objId[../m:identNr = '{identNr_node.text}']", 
                    namespaces={'m':'http://www.mpx.org/mpx'})[0]
                for positive in tifs:
                    #print(f"{identNr_node.text}:{objId}")
                    self._copy_to_dir(positive, target_dir, objId)


    def show(self):
        """prints contents of cache to STDOUT"""

        print ('* Displaying cache contents')
        if hasattr (self, 'cache'):
            for item in self.cache:
                print (f"  {item}")
            print (f"Number of tifs in cache: {len(self.cache)}")
        else:
            print (' Cache does not exist!')


#############


    def _target_fn (self, fn):
        """
        Check if target exists. If so, find new variant that does not yet 
        exist according to the following schema and return that:
            path/to/base.ext
            path/to/base (1).ext
            path/to/base (2).ext
            ...
        """
        new=fn
        i=1
        while os.path.exists (new):
            #print ('Target exists already')
            trunk,ext=os.path.splitext(fn)
            new= f"{trunk} {i} {ext}"
            i+=1
        print (f"[{i}] {new}")
        return new


    def _copy_to_dir(self, source,target_dir, objId=None):
        """ 
        Copy source file to target dir. If there already is a file with 
        that name find a new name that doesn't exist yet. 
        
        If objId is specified it's added to the target target filename: 
            $objId.filename.tif
        
        Upside: we can have multiple tifs for one identNr. 
        Downside: new filenames don't necessarily match the old ones and it 
        will be difficult to reconstruct what has been copied from where to 
        where.
        """
        if target_dir != '':
            #print ('cp %s -> %s' %(source, target_dir))
            s_base = os.path.basename(source)
            if objId is not None:
                s_base=f"{objId}.{s_base}"
            target_fn=self._target_fn (os.path.join(target_dir, s_base)) # should be full path
            print (f"cp:{source} -> {target_fn}")
            try: 
                shutil.copy(source, target_fn) # copy2 attempts to preserve file info;
            except:
                print (f"File not found: {source}")


    def _prepare_wb (self, xls_fn):
        """Read existing xlsx and return workbook"""

        if os.path.isfile (xls_fn):
            #print (f"File exists ({xls_fn})")
            return load_workbook(filename = xls_fn)
        else:
            raise (f"Excel file not found: {xls_fn}")


if __name__ == "__main__":
    
    f=Tif_Finder()
