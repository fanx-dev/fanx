//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Mar 09  Brian Frank  Creation
//   24 Apr 20  Brian Frank  Make Future abstract
//
package fan.concurrent;

import fan.sys.*;
import fan.std.*;
import fanx.main.*;
import java.util.concurrent.TimeUnit;
import java.util.ArrayList;

/**
 * Future is used to manage the entire lifecycle of each
 * message send to an Actor.  An actor's queue is a linked
 * list of messages.
 */
public abstract class Future
  extends FanObj
  implements java.util.concurrent.Future
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  public static Future makeCompletable() { return ActorFuture.make(null); }

  public static void make$(Future self) {}

  public Future() {}

//////////////////////////////////////////////////////////////////////////
// Obj
//////////////////////////////////////////////////////////////////////////

  public Type typeof()
  {
    if (type == null) type = Sys.findType("concurrent::Future");
    return type;
  }
  private static Type type;

//////////////////////////////////////////////////////////////////////////
// Future
//////////////////////////////////////////////////////////////////////////

  public abstract FutureState state();

  public final boolean isDone() { return state().isComplete(); }

  public final boolean isCancelled() { return state().isCancelled(); }

  public Object get() { return get(null); }
  public Object get(long t, TimeUnit u) { return get(Duration.fromNanos(u.toNanos(t))); }
  public abstract Object get(Duration timeout);

  public Future waitFor() { return waitFor(null); }
  public abstract Future waitFor(Duration timeout);

  public static final void waitForAll(List list) { waitForAll(list, null); }
  public static final void waitForAll(List list, Duration timeout)
  {
    ActorFuture.waitForAll(list, timeout);
  }

  // java Future version
  public final boolean cancel(boolean mayInterrupt)
  {
    cancel();
    return true;
  }

  public abstract void cancel();

  public abstract Future complete(Object r);

  public abstract Future completeErr(Err e);

  public Future wraps() { return null; }

}