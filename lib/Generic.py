import os
class Generic:
    def mkdir(self, path):
        if not os.path.isdir(path): 
            os.mkdir(path) # no chmod
