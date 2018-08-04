
package bar.baz;

import fan.sys.*;

public class Foo
{

  public Date today() { return Date.today(); }

  public String toString() { return getClass().getName(); }

  public static class Inner
  {
    public String toString() { return "Foo.Inner!"; }
  }

}