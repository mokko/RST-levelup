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


class Saxon:
    def __init__ (self, path=None):
        self.saxonpath="C:/Program Files/Saxonica/SaxonHE9.9N/bin/Transform.exe" # default
        if path:
            self.saxon=path
        #print (self.saxonpath)
    
    def transform (self, source, stylesheet, output):
        cmd=self.saxonpath + ' -s:' + source + ' -xsl:' + stylesheet + ' -o:' + output 
        print (cmd)
        subprocess.run (cmd) # overwrites output file without saying anything

        

if __name__ == "__main__":
    conf={}
    sn=Saxon(conf)
    sn.transform("1-XML/so.xml", "lib/join.xsl", "o.xml")
