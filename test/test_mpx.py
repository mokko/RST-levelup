from lxml import etree
import argparse

def main (mpx_fn):
    test_identNr(mpx_fn)
    test_mume_pfad(mpx_fn)
    #test_hersteller(source_fn, dest_fn)
    #test_künstler(source_fn, dest_fn)


def test_identNr(xml_fn):
    """Es soll keine DS ohne identNr geben"""
    tree = etree.parse(xml_fn)
    r = tree.xpath('/m:museumPlusExport/m:sammlungsobjekt[not(m:identNr)]',namespaces={'m': 'http://www.mpx.org/mpx'})
    #r should be empty
    if r:
        raise ValueError ('Es soll keine DS ohne identNr geben')
    #else:
    #    print ('all good')


def test_mume_pfad (mpx_fn):
    """Meckere, wenn Pfadangaben ausgefüllt ist, aber Dateiname oder Erweiterung fehlt."""
    mpx = etree.parse(mpx_fn)
    
    s = mpx.xpath("/m:museumPlusExport/m:multimediaobjekt[m:pfadangabe]",namespaces={'m': 'http://www.mpx.org/mpx'})
    for mume in s:
        r1=mume.xpath ("m:dateiname",namespaces={'m': 'http://www.mpx.org/mpx'})
        r2=mume.xpath ("m:erweiterung",namespaces={'m': 'http://www.mpx.org/mpx'})
        e=[]
        if len(r1) <1 or len(r2) < 1:
            mulId=mume.xpath("@mulId")[0]
            e.append(mulId)
        if len(e) > 0:
            raise ValueError (f"MM path incomplete: mulId {e}")


"""Todo: I could test if a MM Standardbild has veröffentlichen = nein"""


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-m', '--mpx_fn', required=True)
    args = parser.parse_args()

    main (args.mpx_fn)

    print ('mpx OK')

