"""
Using lxml to validate xml files on the command line.
USAGE
    validate.py bla.xml

1. Locate schemalocation. It's an attribute. It could be in root. There could be multiple, I guess
2. Parse schemaLocation
3. Using lxml load xml and xsd to memory
4. validate
"""

import os
from lxml import etree
import argparse

conf = {
    'lido': 'http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd',
}
lib = os.path.realpath(os.path.join(__file__,'../../lib'))
conf['mpx']=os.path.join (lib, 'mpx20.xsd')

nsmap = { #currently unused
    'lido' 'http://www.lido-schema.org'
    'mpx': 'http://www.mpx.org/mpx',
    'xsd': 'http://www.w3.org/2001/XMLSchema-instance',
}

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input', required=True)
    parser.add_argument('-s', '--schema', required=True)
    args = parser.parse_args()

    if args.schema in conf:
        print ('*Looking for xsd at %s...' % conf[args.schema])
        schema_doc = etree.parse(conf[args.schema])
    else:
        raise Exception ('Unknown schema')
    schema = etree.XMLSchema(schema_doc)

    print ('*About to load input document...')
    doc = etree.parse(args.input)
    schema.assert_(doc)
    print ('*ok')

