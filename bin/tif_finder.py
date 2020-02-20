'''
USAGE:
    tif_finder.py -u path/to/dir: makes new cache (not typical update)
    tif_finder.py -s needle: just report found files

    tif_finder.py -s needle -t target_dir: copy found tifs for needle to target_dir.

    tif_finder.py -x excel_fn: just reports found tifs
    tif_finder.py -x excel_fn: -t target_dir: copy found tifs to target dir
    
    tif_finder.py -S: show cache
'''
import os, sys, argparse

lib=os.path.realpath(os.path.join(__file__,'../../lib'))
sys.path.append (lib)

from Tif_finder import Tif_finder

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-u', '--update_cache')
    parser.add_argument('-s', '--search')
    parser.add_argument('-x', '--xls')
    parser.add_argument('-t', '--target_dir')
    parser.add_argument('-S', '--show_cache', action='store_true')

    args = parser.parse_args()

    t=Tif_finder()

    if args.update_cache is not None:
        t.update_cache(args.update_cache)
    elif args.show_cache:
        t.show()
    elif args.search is not None and args.target_dir is not None:
        t.search (args.search, args.target_dir)
    elif args.search is not None and not args.target_dir:
        t.search(args.search)
    elif args.search_xls is not None and args.target_dir is not None:
        t.search_xls (args.xls, args.target_dir)
    elif args.xls is not None and not args.target_dir:
        t.search_xls(args.xls)
    else:
        raise ValueError ('Unknown command line argument')
