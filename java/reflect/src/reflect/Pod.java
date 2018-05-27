package reflect;

import fanx.main.Sys;
import fanx.main.Type;

public class Pod {

	private static Type typeof;

	  public Type typeof() { 
		  if (typeof == null) {
			  typeof = Sys.findType("reflect::Pod");
		  }
		  return typeof;
	  }
}
