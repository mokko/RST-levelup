"""

To apply the translations which are now stored in Excel to LIDO, we could
transform them FIRST into xml; so we can include them into the normal 
LIDO transformation.

So this class will transform xls to xml dictionary.

What should the format be

Possibility 1
<geogrBezug>
    <de>Begriff 1</de>
    <en>english translation</en>

POssibility 2 
<voc>
    <term id="number">
        <pref_de">Begriff 1</pref_de>
        <pref_en>term 1</pref_en>
        <field>geogrBezug</field>
    </term>
</voc>

Possibility 3
<voc>
    <term prefde="Begriff 1">
        <en src="EM-SM\geogrBezug">term 1</en>
        <en src="AKu-StuSam\titel">another translation (unlikely, but possible)</en>
    </term>
<voc>

Possibility 4
<mpxvok>
    <context name="titel@art">
        <concept> <!--no id-->
            <pref lang="de" src="EM-SM>Titel</pref>
            <pref lang="en">Title</pref>
            <syn>Titellei</syn>
        </concept>
    </context>
</mpxvok>

Let's not write any term with frequency = 0 to the vocabulary.

If we do this extra step, we should also solve our other problem. Which is
that we have several distinct translate.xslx files for each object set we
export. 

My first question is if we save, merge those files beforehand or if we do
it in this step.

We cannot merge them up to this point, because it would probably mess up 
the frequency count. Well that's the reason why I don't just write one
big translation file to begin with.

Second question is if we can merge translations from different elements/fields.
I guess that would be just about possible. What are the chances that two 
different fields have the same term, but insist on translating them 
differently? Not so big. I mean "London" in one field will still be "London" in
the next field. Okay, but to build a structure where that is not possible even
a single time? I don't think so. 

Anyways, this program could walk thru different directories from the beginning
and look for multiple translation.xlsx files as input. Then it writes a new
translation-master file in xml. I think an update function is not necessary,
so it will just write a completely new list every time.

We still have to check if term exists already.

->gtranslation.xml

Pseudo Algorithm
*find & open translations xls files
*for each sheet
*for each term
*test if term/translation already exists, 
if not add it
"""

#import os
import glob
import openpyxl
from lxml import etree as ET
from XlsTools import XlsTools

needle_fn="translate.xlsx"

class vok2vok (XlsTools):
    def __init__(self, dir, out_fn):
        root = ET.Element("voc") # start a new document
        #tree = ET.parse("gtranslate.xml") #load existing document
        #root = tree.getroot()

        for path in glob.iglob(f"./**/{needle_fn}", recursive=True):
            wb=self._prepare_wb (path)
            print (f"*Processing translation table: {path}")
            
            for sheet in wb.worksheets:
                print (f"   {sheet.title}")
                self._per_sheet (sheet, root, path)

        ET.indent (root)
        doc = ET.ElementTree (root)
        with open(out_fn, 'wb') as f:
            doc.write(f, encoding="UTF-8", method="xml", 
                      xml_declaration=True, pretty_print=True)


    ### PRIVATE ###


    def _add_necessary_stuff (self, xml, term_xls, translation, src):
        if translation is not None:
            #todo: check if term exists
            #print (f"Checking if {term.value} exists already.")
            term_node = xml.xpath (f"//term[@prefde = '{term_xls}']")
            if term_node:
                #print (f"\current translation exists already: {translation}")
                en = xml.xpath (f"//term[@prefde = '{term_xls}']/en[. = '{translation}']")
                if not en: #current translation exist already?
                    self._add_new_translation(term_node[0], src, translation)
            else:
                #print (f"->TERM does NOT yet exist {term.value}")
                self._add_new_term (xml, term_xls, src, translation)

    def _add_new_translation (self, term_node, path, translation):
        print (f"\tAlternate translation: {term_node.text}:{translation}")
        term_node = ET.SubElement (sub, "en")
        term_node.set ("src",path)
        term_node.text = translation

    def _add_new_term (self, xml, term, path, cell):
        sub = ET.SubElement (xml, "term")
        sub.set ("prefde",term)
        sub2 = ET.SubElement (sub, "en")
        sub2.set ("src",path)
        sub2.text = cell

    def _per_sheet (self, sheet, xml, path): 
        lno=1 # 1-based line counter 
        for term_xls in sheet['A']:
            if lno > 1: #IGNORE HEADER
                #print (f"\t{sheet[name].value}")
                translation=sheet[f"B{lno}"].value
                npath = path.replace('\\','/')
                src=f"{npath}/{sheet.title}"
                #print (f"\t{term_xls.value} {src}")
                freq=int(sheet[f"D{lno}"].value)
                if freq > 0:
                    self._add_necessary_stuff(xml, term_xls.value, translation, src)
            lno += 1

if __name__ == '__main__': 
    #execute from ./data
    vok2vok('.', 'gtranslate.xml')