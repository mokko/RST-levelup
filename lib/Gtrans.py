"""
Use google translate for the German to English translation for certain
fields: sachbegriff, titel, beschreibung, possibly others.

Let's write the translation into the excel file, so we can manually overwrite 
it. 

1. Let's write configuration information in existing conf:
        data2/generalvindex.conf
    specifically which sheets to act on -> 

    no -> let's just translate all sheets, but only empty English cells of course.

2. Let's write translations in translate.xlsx files
    scope/translate.xslx
    
    Let's not include this in the normal chain. Let's just think of this as script
    we execute when we need automatic translations
    
USAGE
    gtrans ..\translate.xslx
"""

from openpyxl import Workbook, load_workbook
from google.cloud import translate_v2 
from titlecase import titlecase
import html

class Gtrans:
    def __init__ (self, xls_fn):

        self.case = {
            "sachbegriffnot(@artSachb...": "lower",
            "titelnot(@artÜbersetzungengl.)": "title"
        }

        wb = load_workbook (filename = xls_fn)
        for sheet in wb.worksheets:
            print (f"*Working on {sheet.title}")
            if sheet.title != "geogrBezug":
                self.translate(sheet)
                wb.save(xls_fn)

    def translate (self, sheet):
        """Translate sheet

        Column A is DE, column B is EN
        Only fill in translation if there is none yet
        Save after every sheet.
        
        Currently, we lower-case and unescape all the results.
        """
        
        client = translate_v2.Client()
        
        c=1 # 1-based line counter 
        for de in sheet['A']:
            if c != 1 and de.value is not None:
                en=sheet[f"B{c}"]
                if en.value is None:
                    result = client.translate (de.value, 
                        source_language = "de", 
                        target_language = "en")
                    en=html.unescape(result['translatedText'])
                    if sheet.title in self.case.keys():
                        if self.case[sheet.title] == "lower":
                            print ("\tforcing lowercase")
                            en=en.lower()
                        elif self.case[sheet.title] == "title":
                            print ("\tforcing Titlecase")
                            en=titlecase(en)
                    print(f"   {de.value} -> {en}")
                    sheet[f"B{c}"]=en
            c+=1

if __name__ == "__main__":
    import sys
    Gtrans (sys.argv[1])
