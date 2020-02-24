''' 
I want to identify and import tif to DB.
(1) write info to xls; write excel utility methods
(2) list path in sheet 1 col a
(3) base.extension in col b
(4) extract signatur from fn (base) and put in col c
(5) associate with objId col d (info coming from mpx)
(6) make a new similar sheet for jpgs using phash to identify structurally similar tifs
(7) check only the mulId-records for that objId for identical hashes
'''

import os, sys, argparse, openpyxl

lib=os.path.realpath(os.path.join(__file__,'../../lib'))
sys.path.append (lib)
from TifId import TifId

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-x', '--xls_lib', required=True) #Excel file where we store our info, sort of like a db
    parser.add_argument('-s', '--scan') # scan tif_dir
    parser.add_argument('-m', '--mpx') # fill in empty spots if you can
    parser.add_argument('-p', '--process', action='store_true') # process filepath information from scan 

    args = parser.parse_args()

    t=TifId(args.xls_lib)

    if args.scan is not None:
        t.scan_tif(args.scan)

    if args.mpx is not None:
        t.mpx(args.mpx)

    if args.process is not None:
        t.process_path()

