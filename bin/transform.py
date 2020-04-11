import os, sys, argparse

lib=os.path.realpath(os.path.join(__file__,'../../lib'))

if os.getlogin() == 'User':
    saxon= "C:/Program Files/Saxonica/SaxonHE9.9N/bin/Transform.exe",
elif os.getlogin() == 'mauri':
    saxon= "C:/Program Files/Saxonica/SaxonHE9.9N/bin/Transform.exe",

sys.path.append (lib)
from Saxon import Saxon

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input', required=True)
    parser.add_argument('-x', '--xsl', required=True)
    parser.add_argument('-o', '--output', required=False)
    args = parser.parse_args()

    if not args.output:
        args.output='out.lido'
    
    s=Saxon(saxon) #lib is where my xsl files are, so a short cut
    s.dirTransform(args.input, args.xsl, args.output)