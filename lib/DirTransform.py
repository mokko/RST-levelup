import os
from Saxon import Saxon
from Generic import Generic

class DirTransform (Generic):

    def __init__ (self, saxon, source, xsl, outpath):
        destdir=os.path.dirname(outpath) #check 
        #print (destdir)
        self.mkdir (destdir)
        
        if os.path.isfile(outpath):
            print ("%s exists already, no overwrite" % outpath)
        else:
            sn=Saxon(saxon)
            sn.transform(source, xsl, outpath)



if __name__ == "__main__":
    saxon= "C:/Program Files/Saxonica/SaxonHE9.9N/bin/Transform.exe",
    o=DirTransform(saxon, "2-MPX/levelup.mpx", "lib/mpx-fix.xsl", "2-MPX/fix.mpx")
