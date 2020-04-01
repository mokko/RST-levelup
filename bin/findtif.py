import glob
for filename in glob.iglob('**/*.tif', recursive = True): 
    print(filename) 