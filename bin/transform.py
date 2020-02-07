import os, sys, argparse

if __name__ == "__main__":

    if os.getlogin() == 'M-MM0002':
        lib='C:/Users/M-MM0002/Documents/PY/RST-lvlup/lib'
    elif os.getlogin() == 'User':
        lib='C:/Users/User/eclipse-workspace/RST-Lvlup/RST-levelup/lib'
        saxon= "C:/Program Files/Saxonica/SaxonHE9.9N/bin/Transform.exe",
    elif os.getlogin() == 'mauri':
        lib='C:/Users/mauri/eclipse-workspace/PY3/RST-levelup/lib'
        saxon= "C:/Program Files/Saxonica/SaxonHE9.9N/bin/Transform.exe",
        
    else:
        print ('Unknown user:' + os.getlogin())
    sys.path.append (lib)
    from Saxon import Saxon

    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input', required=True)
    parser.add_argument('-x', '--xsl', required=True)
    parser.add_argument('-o', '--output', required=False)
    args = parser.parse_args()

    if not args.output:
        args.output='out.lido'
    
    #old: o=DirTransform(saxon, "2-MPX/levelup.mpx", "lib/mpx-fix.xsl", "2-MPX/fix.mpx")
    s=Saxon(saxon) #lib is where my xsl files are, so a short cut
    s.dirTransform(args.input, args.xsl, args.output)