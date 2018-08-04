//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Mar 09  Brian Frank  Creation
//
package fan.concurrent;

import fan.sys.*;
import fan.std.*;
import fanx.main.*;
import java.util.ArrayList;

/**
 * Future is used to manage the entire lifecycle of each
 * message send to an Actor.  An actor's queue is a linked
 * list of messages.
 */
public final class Future
  extends FanObj
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  public static Future make()
  {
    return new Future(null);
  }

  Future(Object msg)
  {
    this.msg   = msg;
    this.state = PENDING;
  }

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

  public final FutureState state()
  {
    int state = this.state;
    switch(state)
    {
      case PENDING:     return FutureState.pending;
      case DONE_OK:     return FutureState.ok;
      case DONE_ERR:    return FutureState.err;
      case DONE_CANCEL: return FutureState.cancelled;
    }
    throw Err.make("Internal error " + state);
  }

  public final boolean isDone()
  {
    return (state & DONE) != 0;
  }

  public final boolean isCancelled()
  {
    return state == DONE_CANCEL;
  }

  public final Object get() { return get(null); }
  public final Object get(Duration timeout)
  {
    Object r = null;
    try
    {
      synchronized (this)
      {
        // wait until we enter a done state, the only notifies
        // on this object should be from cancel, complete, or completeErr
        if (timeout == null)
        {
          // wait forever until done
          while ((state & DONE) == 0) wait();
        }
        else
        {
          // if not done, then wait with timeout and then
          // if still not done throw a timeout exception
          if ((state & DONE) == 0)
          {
            // compute deadline in millis
            long deadline = TimePoint.nowMillis() + timeout.toMillis();

            // loop until we are done or our deadline has passed
            while ((state & DONE) == 0)
            {
              long left = deadline - TimePoint.nowMillis();
              if (left <= 0L) break;
              wait(left);
            }

            // if we still aren't done this is a timeout
            if ((state & DONE) == 0) throw TimeoutErr.make("Future.get timed out");
          }
        }

        // if canceled throw CancelErr
        if (state == DONE_CANCEL)
          throw CancelledErr.make("Future cancelled");

        // if error was raised, raise it to caller
        if (state == DONE_ERR)
          throw ((Err)result);//.rebase();

        // assign result to local variable for return
        r = result;
      }
    }
    catch (InterruptedException e)
    {
      throw InterruptedErr.make(e);
    }

    // ensure immutable or safe copy
    return Actor._safe(r);
  }

  public final Future waitFor() { return waitFor(null); }
  public final Future waitFor(Duration timeout)
  {
    try
    {
      synchronized (this)
      {
        // wait until we enter a done state, the only notifies
        // on this object should be from cancel, complete, or completeErr
        if (timeout == null)
        {
          // wait forever until done
          while ((state & DONE) == 0) wait();
        }
        else
        {
          // if not done, then wait with timeout and then
          // if still not done throw a timeout exception
          if ((state & DONE) == 0)
          {
            // compute deadline in millis
            long deadline = TimePoint.nowMillis() + timeout.toMillis();

            // loop until we are done or our deadline has passed
            while ((state & DONE) == 0)
            {
              long left = deadline - TimePoint.nowMillis();
              if (left <= 0L) break;
              wait(left);
            }

            // if we still aren't done this is a timeout
            if ((state & DONE) == 0) throw TimeoutErr.make("Future.get timed out");
          }
        }
        return this;
      }
    }
    catch (InterruptedException e)
    {
      throw InterruptedErr.make(e);
    }
  }

  public static final void waitForAll(List list) { waitForAll(list, null); }
  public static final void waitForAll(List list, Duration timeout)
  {
    if (timeout == null)
    {
      for (int i=0; i<list.size(); ++i)
      {
        Future f = (Future)list.get(i);
        f.waitFor(null);
      }
    }
    else
    {
      long deadline = TimePoint.nowMillis() + timeout.toMillis();
      for (int i=0; i<list.size(); ++i)
      {
        Future f = (Future)list.get(i);
        long left = deadline - TimePoint.nowMillis();
        f.waitFor(Duration.fromMillis(left));
      }
    }
  }

  public final void cancel()
  {
    ArrayList wd;
    synchronized (this)
    {
      if ((state & DONE) == 0) state = DONE_CANCEL;
      msg = result = null;  // allow gc
      notifyAll();
      wd = whenDone; whenDone = null;
    }
    sendWhenDone(wd);
  }

  public final Future complete(Object r)
  {
    r = Actor._safe(r);
    ArrayList wd;
    synchronized (this)
    {
      if (state == DONE_CANCEL) return this;
      if (state != PENDING) throw Err.make("Future already complete");
      state = DONE_OK;
      result = r;
      notifyAll();
      wd = whenDone; whenDone = null;
    }
    sendWhenDone(wd);
    return this;
  }

  public final Future completeErr(Err e)
  {
    ArrayList wd;
    synchronized (this)
    {
      if (state == DONE_CANCEL) return this;
      if (state != PENDING) throw Err.make("Future already complete");
      state = DONE_ERR;
      result = e;
      notifyAll();
      wd = whenDone; whenDone = null;
    }
    sendWhenDone(wd);
    return this;
  }

//////////////////////////////////////////////////////////////////////////
// When Done
//////////////////////////////////////////////////////////////////////////

  final void sendWhenDone(Actor a, Future f)
  {
    // if already done, then set immediate flag
    // otherwise add to our when done list
    boolean immediate = false;
    synchronized (this)
    {
      if (isDone()) immediate = true;
      else
      {
        if (whenDone == null) whenDone = new ArrayList();
        whenDone.add(new WhenDone(a, f));
      }
    }

    // if immediate we are already done so enqueue immediately
    if (immediate)
    {
      try { a._enqueue(f, false); }
      catch (Throwable e) { e.printStackTrace(); }
    }
  }

  static void sendWhenDone(ArrayList list)
  {
    if (list == null) return;
    for (int i=0; i<list.size(); ++i)
    {
      WhenDone wd = (WhenDone)list.get(i);
      try { wd.actor._enqueue(wd.future, false); }
      catch (Throwable e) { e.printStackTrace(); }
    }
  }

  static class WhenDone
  {
    WhenDone(Actor a, Future f) { actor = a; future = f; }
    Actor actor;
    Future future;
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  static final int PENDING     = 0x00;
  static final int DONE        = 0x0f;
  static final int DONE_CANCEL = 0x1f;
  static final int DONE_OK     = 0x2f;
  static final int DONE_ERR    = 0x4f;

  Object msg;                  // message send to Actor
  Future next;                 // linked list in Actor
  private volatile int state;  // processing state of message
  private Object result;       // result or exception of processing
  private ArrayList whenDone;  // list of messages to deliver when done

}