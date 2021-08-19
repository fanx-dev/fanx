
package bar.baz;

import fan.sys.*;
import fanx.main.*;
import fan.std.*;

public class Foo
{

  public Date today() { return Date.today(); }

  public String toString() { return getClass().getName(); }

  public static class Inner
  {
    public String toString() { return "Foo.Inner!"; }
  }

}