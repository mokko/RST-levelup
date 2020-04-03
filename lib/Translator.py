""" Partially translates LIDO file 
: source LIDO
: output LIDO
: translate.json configuration information with LIDO elements to work on
: translate.xlsx

We need a conf.json file with information on which fields are to be translated.
sheet.title: LIDO xpath element or attribute

We look up the German element/attribute value, check if this term/value is in our 
list; if we do, we create a new sibling element with xml:lang="en" tag.

USAGE:
    t=Translator(source_fn, config_fn, xls_fn)
    t.translate (out_fn)
"""
from MiniLogger import MiniLogger

class Translator (MiniLogger): 
    def __init__ (self, source_fn, config_fn, xsl_fn):
        self._init_log ('.')
        self._write_log ('bla')
        self._read_conf (config_fn)


if __name__ == '__main__': 
    t=Translator('source', '../../l_translate.json', 'xsl')