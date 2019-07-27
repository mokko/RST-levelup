'''
Trigger saxon from python using subprocess

https://docs.python.org/3.7/library/subprocess.html

conf={
   "java":"path/to/java"
   "saxon":"path/to/saxon"
}

sax=Saxon (conf)
sax.transform (input, xsl, output)

subprocess.run(args, *, stdin=None, input=None, stdout=None, stderr=None, capture_output=False, 
shell=False, cwd=None, timeout=None, check=False, encoding=None, errors=None, text=None, env=None, universal_newlines=None)

On Windows easiest way seems to be to use built for NET plattform. Alternatively, this class could also deal with java.

https://www.saxonica.com/documentation/index.html#!using-xsl/commandline

Transform -s:source -xsl:stylesheet -o:output

'''

import subprocess


class Saxon:
    def __init__ (self, conf):
        self.transform="C:/Program Files/Saxonica/SaxonHE9.9N/bin/Transform.exe" # default
        if conf['transform']:
            self.transform=conf['transform']
        
    
    def transform (source, stylesheet, output)
        cmd="%s -s:%s -xsl:%s -o:%s" % (self.transform, source, stylesheet, output ))
        print (cmd)
        subprocess.run (cmd)
