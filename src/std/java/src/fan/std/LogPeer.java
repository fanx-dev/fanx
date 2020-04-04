package fan.std;

import fan.sys.*;
import fanx.main.Sys;

public class LogPeer {
	
	public static void printLogRec(LogRec rec, OutStream out) {
		synchronized (out)
    {
      out.printLine(rec.toStr());
      //TODO
      if (rec.err != null) rec.err.printStackTrace();
    }
	}
}
