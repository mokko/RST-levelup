'''
A very thin wrapper around Saxon that uses Python's subprocess

USAGE 
    s=Saxon(conf,lib) #lib is optional

    conf={
       "java":"path/to/java"
       "saxon":"path/to/saxon"
    }
    lib="path/to/dir/with/lots/of/xsl

    s.transform (input, xsl, output)     #plain transform, lib is not applied
    s.dirTransform (input, xsl, output)  #plain transform, but creates output dir if necessary
    s.join (source, stylesheet, output)  #apply join.xsl to source and write result to output

SAXON VERSION
    On Windows easiest way seems to be to use built for NET platform. Alternatively, this class 
    can also use the original Saxon in java.

SEE ALSO
    transform -s:source -xsl:stylesheet -o:output

    https://www.saxonica.com/documentation/index.html#!using-xsl/commandline
'''

import os
import shutil
import subprocess
import sys
from subprocess import Popen, PIPE


class Saxon:
    def __init__ (self, conf=None, lib=None):
        self.saxon="C:/Program Files/Saxonica/SaxonHE9.9N/bin/Transform.exe" # default
        if 'saxon' in conf:
            self.saxon=conf['saxon']
        if 'java' in conf:
            self.java=conf['java']
        if lib:
            self.lib=lib # default used in dirTransform


    def transform (self, source, stylesheet, output, report_fn=None):
        source=self._escapePath(source)
        stylesheet=self._escapePath(stylesheet)
        output=self._escapePath(output)
        
        cmd=self.saxon + ' -s:' + source + ' -xsl:' +stylesheet + ' -o:' + output
        if hasattr(self, 'java'):
            cmd='java -Xmx1024m -jar ' + cmd
        print (cmd)
        #check=True:dies on error
        #https://stackoverflow.com/questions/89228
        if report_fn is None:
            print ("NO REPORT")
            subprocess.run (cmd, check=True, stderr=subprocess.STDOUT) # overwrites output file without saying anything
        else:
            print (f"*WRITING REPORT TO {report_fn}")
            log = open(report_fn, mode='wb')
            with Popen(cmd, bufsize=0, stdout=PIPE, stderr=subprocess.STDOUT) as proc:
                line = proc.stdout.read()
                print (line)
                log.write(line)
            #result = subprocess.run(cmd, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            #print (result.stderr)
            #print (result.stdout)
            

    def dirTransform (self, source, stylesheet, output, report_fn=None):
        '''
         Like normal transform plus 
         a) it makes the output dir if it doesn't exist already
         b) it prefixes the stylesheet path with self.lib if it exists
        '''
        output=os.path.realpath(output)
        dr=os.path.dirname (output) 
        
        if os.path.isfile(output):
            print ("%s exists already, no overwrite" % output)
        else:
            if not os.path.isdir(dr): 
                os.mkdir(dr) # no chmod
            if hasattr(self, 'lib'):
                stylesheet=self.lib+'/'+stylesheet    
            self.transform (source, stylesheet, output, report_fn)    


    def _escapePath (self, path): 
        '''escape path w/ spaces'''
        return '"'+path+'"'


    def join (self, source, stylesheet, output):
        '''
            Join all lvl1 files into one big join file
        '''
        if os.path.isfile(output): #only join if target doesn't exist yet
            print ("%s exists already, no overwrite" % output) 
        else:
            source=self._escapePath(self.lib+'/'+source)
            #if os.path.isfile(source):
            styleorig=self.lib+'/'+stylesheet
            targetdir=os.path.dirname(output)
            styletarget=targetdir+'/'+stylesheet
            print ('orig: '+ styleorig)
            print ('target: '+ styletarget)
            shutil.copy(styleorig, styletarget) # cp stylesheet in same dir as *.xml
            self.transform (source, self._escapePath(styletarget), self._escapePath(output))
            os.remove(styletarget)


if __name__ == "__main__":
    conf={
        'java':'C:/Program Files (x86)/Common Files/Oracle/Java/javapath/java.exe',
        'saxon':'C:/Users/M-MM0002/Documents/P_Datenexport/Saxon/SaxonHE9-8-0-15J/saxon9he.jar'
        }
    sn=Saxon(conf)
    sn.transform("data/1-XML/SO1-RST.xml", "data/1-XML/joinCol.xsl", "o.xml")
