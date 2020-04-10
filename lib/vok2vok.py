"""From several smaller translation tables to one bigger xml dictionary.

USAGE:
    vok2vok(src_dir, out_xml)


To apply the translations which are now stored in Excel to LIDO, we could
transform them FIRST into xml; so we can include them into the normal 
LIDO transformation.

So this class will transform xls to xml dictionary.

What should the format be

Possibility 1
<geogrBezug>
    <de>Begriff 1</de>
    <en>english translation</en>

Possibility 2 
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
different fields have the same t    erm, but insist on translating them 
differently? Not so big. I mean "London" in one field will still be "London" in
the next field. Okay, but to build a structure where that is not possible even
a single time? I don't think so. 

Anyways, this program could walk thru different directories from the beginning
and look for multiple translation.xlsx files as input. Then it writes a new
translation-master file in xml. I think an update function is not necessary,
so it will just write a completely new list every time.

We still have to check if term exists already.

PROBLEMS
It's still possible to have multiple translations of the same term. At the 
moment, they should all be called pref[@lang="en"]. That's not acceptable.

"""

import os
import glob
import openpyxl
from lxml import etree as ET
from XlsTools import XlsTools

needle_fn="translate.xlsx"

class vok2vok (XlsTools):
    def __init__(self, dir, out_fn):
        print (f"**vok2vok source dir {dir}")
        root = ET.Element("mpxvoc") # start a new document
        #tree = ET.parse("gtranslate.xml") #load existing document
        #root = tree.getroot()
        needle_path=os.path.realpath(os.path.join(dir,f"./**/{needle_fn}"))
        print (needle_path)
        for path in glob.iglob(needle_path, recursive=True):
            wb=self._prepare_wb (path)
            print (f"*Processing translation table: {path}")
            
            for sheet in wb.worksheets:
                print (f"   {sheet.title}")
                self._per_sheet (sheet, root, path)
        ET.indent (root)
        doc = ET.ElementTree (root)
        print (f"**About to write to {out_fn}, overwriting old file")
        with open(out_fn, 'wb') as f:
            doc.write(f, encoding="UTF-8", method="xml", 
                xml_declaration=True, pretty_print=True)


    ### PRIVATE ###


    def _add_concept (self, xml, context, row, scope):
        term_xls = row[0].value
        translation_xls = row[1].value
        comment_xls = row[2].value
        freq_xls = row[3].value #xml attribs must be string
        try:
            src = row[4].value
        except: 
            src = None
        #print (f"context:{context}")
        #(1)Does concept exist already?
        rls = xml.xpath (f"//mpxvoc/context[@name = '{context}']")
        if len(rls) > 0:
            context_nd = rls[0]
        else:
            #print (f"\tContext doesn't exists yet: {context}")
            context_nd = ET.SubElement(xml, "context", attrib={"name":context})
        #(2)Does pref_de exist yet?
        rls = context_nd.xpath (f"./concept/pref[@lang='de' and .='{term_xls}']")
        if len(rls) > 0:
            pref_de = rls[0]
            concept_nd = pref_de.xpath (f"..")[0]
            freq_xml = int(concept_nd.get("freq"))
            concept_nd.set("freq", str(freq_xml+freq_xls))
        else:
            #print (f"\tconcept/pref doesn't exist yet: {term_xls} ")
            concept_nd = ET.SubElement(context_nd, "concept", attrib={"freq": str(freq_xls)})
            pref_de = ET.SubElement(concept_nd, "pref", attrib={"lang":"de"})
            pref_de.text = term_xls
        #(3)Does translation exist yet?
        rls = pref_de.xpath (f"../pref[@lang = 'en' and .='{translation_xls}']")
        if len(rls) > 0:
            pref_en = rls[0]
        else:
            #print (f"\ttranslation doesn't exist yet {translation}")
            pref_en=ET.SubElement (concept_nd, "pref", attrib={"lang":"en"})
            pref_en.text = translation_xls
        #there should always be scope 
        scope_nd = ET.SubElement(concept_nd, "scope")
        scope_nd.text=scope
        if comment_xls:
            comment_nd = ET.SubElement(concept_nd, "comment")
            comment_nd.text = comment_xls
        if src is not None: 
            #just append another element sources if multiple  
            sources_nd = ET.SubElement(concept_nd, "sources")
            sources_nd.text = src
        #https://stackoverflow.com/questions/40154757/sorting-xml-tags-by-child-elements-python
        concept_nd[:] = sorted(concept_nd, key=lambda e: e.tag)

    def _mk_scope (self, path):
        npath=os.path.dirname(os.path.abspath(path))
        return npath.replace('\\','/')

    def _per_sheet (self, sheet, xml, path): 
        lno=1 # 1-based line counter 
        for term_xls in sheet['A']:
            if lno > 1: #IGNORE HEADER
                scope=self._mk_scope(path)
                translation=sheet[f"B{lno}"].value
                freq=int(sheet[f"D{lno}"].value)
                if freq > 0 and translation is not None:
                    self._add_concept(xml, sheet.title, sheet[lno], scope)
            lno += 1


if __name__ == '__main__': 
    #execute from ./data
    vok2vok('..', 'mpxvoc3.xml')