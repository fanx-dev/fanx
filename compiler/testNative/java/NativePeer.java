//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   3 Mar 06  Brian Frank  Creation
//
package fan.testNative;

import fan.sys.*;
import fanx.main.*;
import fan.std.*;
import bar.baz.*;

/**
 * Verify Java native integration
 */
public class NativePeer
{

  public static NativePeer make(Native t)
  {
    NativePeer peer = new NativePeer();
    peer.ctorY = t.y;
    return peer;
  }

  public static long doStaticA()
  {
    return 2006L;
  }

  public static long doStaticB(long a, long b)
  {
    return a + b;
  }

  public long fX(Native t) { return t.x; }
  public void fX(Native t, long x) { t.x = x; }

  public Long fA(Native t) { return fA; }
  public void fA(Native t, Long x) { fA = x; }

  public String fV(Native t) { return fV; }
  public void fV(Native t, String x) { fV = x; }

  public long getPeerZ(Native t)
  {
    return z;
  }

  public void setPeerZ(Native t, long z)
  {
    if (t.peer != this) throw new RuntimeException();
    this.z = z;
  }

  public long getCtorY(Native t)
  {
    return ctorY;
  }

  public String defs1(Native t, String a) { return a; }
  public String defs2(Native t, String a, String b) { return a + b;  }
  public String defs3(Native t, String a, String b, String c) { return a + b + c;  }

  public static String sdefs1(String a) { return a; }
  public static String sdefs2(String a, String b) { return a + b;  }
  public static String sdefs3(String a, String b, String c) { return a + b + c;  }

  long ctorY;  // value of y during make()
  long z;
  Long fA = 444L;
  String fV = "fV";

  public static void runPlatformTests(Test test)
  {
    // basic sanity check
    test.verifyEq(Env.cur().runtime(), "java");

    // verify FanClassLoader loads non-Fan classes from my pod
    Foo foo = new Foo();
    test.verifyEq(foo.toString(), "bar.baz.Foo");
    test.verifyEq(foo.today(), Date.today());
    test.verifyEq(new Foo.Inner().toString(), "Foo.Inner!");
  }
}