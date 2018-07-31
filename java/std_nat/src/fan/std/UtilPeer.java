package fan.std;

import java.io.PrintStream;

import fan.sys.Err;
import fanx.interop.Interop;

public class UtilPeer {
	static Err trace(Err self, OutStream out, Map options) {
		self.printStackTrace(new PrintStream(Interop.toJava(out)));
		return self;
	}
}
