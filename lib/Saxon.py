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
    def __init__ (self, conf=None, lib=None):
        self.saxon="C:/Program Files/Saxonica/SaxonHE9.9N/bin/Transform.exe" # default
        if 'saxon' in conf:
            self.saxon=conf['saxon']
        if 'java' in conf:
            self.java=conf['java']
        if lib:
            self.lib=lib # default used in dirTransform


    def transform (self, source, stylesheet, output):
        source=self.escapePath(source)
        stylesheet=self.escapePath(stylesheet)
        output=self.escapePath(output)
        
        cmd=self.saxon + ' -s:' + source + ' -xsl:' +stylesheet + ' -o:' + output
        if hasattr(self, 'java'):
            cmd='java -Xmx1024m -jar ' + cmd
        print (cmd)
        #check=True:dies on error
        subprocess.run (cmd, check=True, stderr=subprocess.STDOUT) # overwrites output file without saying anything


    def dirTransform (self, source, stylesheet, output):
        '''
         Like normal transform plus 
         a) it makes the output if it doesn't exist already
         b) it prefixes the stylesheet path with self.lib if it exists
        '''
        dr=os.path.dirname (output) 
        
        if os.path.isfile(output):
            print ("%s exists already, no overwrite" % output)
        else:
            if not os.path.isdir(dr): 
                os.mkdir(dr) # no chmod
            if hasattr(self, 'lib'):
                stylesheet=self.lib+'/'+stylesheet    
            self.transform (source, stylesheet, output)    


    def escapePath (self, path): 
        '''escape path w/ spaces'''
        return '"'+path+'"'


    def join (self, source, stylesheet, output):
        #todo mk sure that self.lib exists
        if os.path.isfile(output):
            print ("%s exists already, no overwrite" % output)
        else:
            source=self.escapePath(self.lib+'/'+source)
            styleorig=self.lib+'/'+stylesheet
            targetdir=os.path.dirname(output)
            styletarget=targetdir+'/'+stylesheet
            shutil.copy(styleorig, styletarget) # cp stylesheet in same dir as *.xml
            self.transform (source, self.escapePath(styletarget), self.escapePath(output))    


if __name__ == "__main__":
    conf={
        'java':'C:/Program Files (x86)/Common Files/Oracle/Java/javapath/java.exe',
        'saxon':'C:/Users/M-MM0002/Documents/P_Datenexport/Saxon/SaxonHE9-8-0-15J/saxon9he.jar'
        }
    sn=Saxon(conf)
    sn.transform("data/1-XML/SO1-RST.xml", "data/1-XML/joinCol.xsl", "o.xml")
