from pathlib import Path
import json, os

'''
In real life we want the same tif-cache for a lot of exports, so a parent directory like ../../tif_cache.json
'''

class TIFFinder:
    def __init__(self, cache_fn='tif_cache.json'): 
        if os.path.exists(cache_fn):
            print ('*Loading existing cache')
            with open(cache_fn, 'r') as f:
                self.cache = json.load(f)
        else:
            print ('*Making new cache')
            #Should I update the cache? too much work, too little use
            self.cache={}
            for path in Path('.').rglob("*.doc*"):
                abs=path.resolve()
                index = abs.parts.index('RST-levelup')
                
                new=Path().joinpath(*abs.parts[(index+1):])
                self.cache[str(abs)]=str(new).lower() 
    
            print ('**Writing new cache file')
            with open(cache_fn, 'w') as f:
                json.dump(self.cache, f)    

        print (self.cache)

    def cp_tif (self, mpx_fn):
        '''
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

        import shutil

        #Dont copy file again if it already exists at target

        try: 
            shutil.copy(cached_path, out_fn) # copy2 attempts to preserve file info; why not
        except:
            print("Unexpected error:", sys.exc_info()[0])
    
    
if __name__ == "__main__":
    
    f=Tif_Finder()
