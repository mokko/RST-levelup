'''
USAGE:
    tif_finder.py -u path/to/dir: makes new cache (not typical update)
    tif_finder.py -s needle: just report found files
    tif_finder.py -x excel_fn: without -t argument it just reports found files
    tif_finder.py -x excel_fn -t target_dir: copy found files to target dir
'''
import os, sys, argparse

lib=os.path.realpath(os.path.join(__file__,'../../lib'))
sys.path.append (lib)

from Tif_finder import Tif_finder

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-u', '--update_cache', required=False)
    parser.add_argument('-s', '--search', required=False)
    parser.add_argument('-x', '--xls', required=False)
    parser.add_argument('-t', '--target_dir', required=False)

    args = parser.parse_args()

    t=Tif_finder()

    if args.update_cache is not None:
        t.update_cache(args.update_cache)
    elif args.search is not None:
        t.search(args.search)
    elif args.target_dir is not None:
        t.search_xls (args.xls, args.target_dir)
    elif args.xls is not None:
        t.search_xls(args.xls)
    else:
        raise ValueError ('Unknown command line argument')
