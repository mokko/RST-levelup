'''
A very thin wrapper around saxon that uses subprocess

https://docs.python.org/3.7/library/subprocess.html

conf={
   "java":"path/to/java"
   "saxon":"path/to/saxon"
}

s=Saxon (conf)
s.transform (input, xsl, output)

On Windows easiest way seems to be to use built for NET plattform. Alternatively, this class 
could also deal with java, but it doesnt right now, becuase I don't need it yet.

https://www.saxonica.com/documentation/index.html#!using-xsl/commandline

Transform -s:source -xsl:stylesheet -o:output
'''

import subprocess
import os
import shutil


class Saxon:
    def __init__ (self, path=None, lib=None):
        self.saxonpath="C:/Program Files/Saxonica/SaxonHE9.9N/bin/Transform.exe" # default
        if path:
            self.saxon=path
        if lib:
            self.lib=lib # default used in dirTransform    
        #print (self.saxonpath)
    
    def transform (self, source, stylesheet, output):
        cmd=self.saxonpath + ' -s:' + source + ' -xsl:' + stylesheet + ' -o:' + output
        #die on error 
        print (cmd)
        subprocess.run (cmd, check=True) # overwrites output file without saying anything

    '''
     Like normal transform plus 
     a) it makes the output if it doesn't exist already
     b) it prefixes the stylesheet paths with self.lib if it exists
    '''
    def dirTransform (self, source, stylesheet, output):
        dir=os.path.dirname (output) 
        
        if os.path.isfile(output):
            print ("%s exists already, no overwrite" % output)
        else:
            if not os.path.isdir(dir): 
                os.mkdir(dir) # no chmod
            if self.lib:
                stylesheet=self.lib+'/'+stylesheet    
                print (stylesheet)    
            self.transform (source, stylesheet, output)    

    def join (self, source, stylesheet, output):
        #todo mk sure that self.lib exists
        if os.path.isfile(output):
            print ("%s exists already, no overwrite" % output)
        else:
            source=self.lib+'/'+source
            styleorig=self.lib+'/'+stylesheet
            targetdir=os.path.dirname(output)
            styletarget=targetdir+'/'+stylesheet
            shutil.copy(styleorig, styletarget) # cp stylesheet in same dir as *.xml
            self.transform (source, styletarget, output)    


if __name__ == "__main__":
    conf={}
    sn=Saxon(conf)
    sn.transform("1-XML/so.xml", "lib/join.xsl", "o.xml")
