import datetime
import json

class MiniLogger:
    def _init_log (self,outdir):
        #line buffer so everything gets written when it's written, so I can CTRL+C the program
        self._log=open(outdir+'/report.log', mode="a", buffering=1)

    def _write_log (self, msg):
        self._log.write(f"[{datetime.datetime.now()}] {msg}\n")
        print (msg)

    def _close_log (self):
        self._log.close()

    #config stuff
    def _read_conf (self, conf_fn):
        """Read json config file"""

        with open(conf_fn, encoding='utf-8') as json_data_file:
            data = json.load(json_data_file)
        return data

    #excel preparation
    def _prepare_wb (self, xls_fn):
        """Read existing xls or make new one.

        Expects excel file as path
        Returns workbook."""

        if os.path.isfile (xls_fn):
            print (f'   Excel file exists ({xls_fn})')
            return load_workbook(filename = xls_fn)
        else:
            print (f"   Excel file doesn't exist yet, making it ({xls_fn})")
            return Workbook()
