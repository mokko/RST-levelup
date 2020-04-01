class MiniLogger:
    def _init_log (self,outdir):
        #line buffer so everything gets written when it's written, so I can CTRL+C the program
        self._log=open(outdir+'/report.log', mode="a", buffering=1)

    def _write_log (self, msg):
        self._log.write(f"[{datetime.datetime.now()}] {msg}\n")
        print (msg)

    def _close_log (self):
        self._log.close()
