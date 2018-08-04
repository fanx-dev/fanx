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
import java.util.HashMap;

/**
 * Actor is a worker who processes messages asynchronously.
 */
public class Actor
  extends FanObj
  implements ThreadPool.Work
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  public static Actor make(ActorPool pool) { return make(pool, null); }
  public static Actor make(ActorPool pool, Func receive)
  {
    Actor self = new Actor();
    make$(self, pool, receive);
    return self;
  }

  public static void make$(Actor self, ActorPool pool) { make$(self, pool, null); }
  public static void make$(Actor self, ActorPool pool, Func receive)
  {
    // check pool
    if (pool == null)
      throw NullErr.make("pool is null");

    // check receive method
    if (receive == null && self.typeof().qname().equals("concurrent::Actor"))
      throw ArgErr.make("must supply receive func or subclass Actor");
    if (receive != null) receive = (Func)receive.toImmutable();

    // init
    self.pool = pool;
    self.receive = receive;
    self.queue = new Queue();
  }

  public static Actor makeCoalescing(ActorPool pool, Func k, Func c) { return makeCoalescing(pool, k, c, null); }
  public static Actor makeCoalescing(ActorPool pool, Func k, Func c, Func r)
  {
    Actor self = new Actor();
    makeCoalescing$(self, pool, k, c, r);
    return self;
  }

  public static void makeCoalescing$(Actor self, ActorPool pool, Func k, Func c) { makeCoalescing$(self, pool, k, c, null); }
  public static void makeCoalescing$(Actor self, ActorPool pool, Func k, Func c, Func r)
  {
    if (k != null) k = (Func)k.toImmutable();
    if (c != null) c = (Func)c.toImmutable();

    make$(self, pool, r);
    self.queue = new CoalescingQueue(k, c);
  }

  public Actor()
  {
    this.context  = new Context(this);
  }

//////////////////////////////////////////////////////////////////////////
// Obj
//////////////////////////////////////////////////////////////////////////

  public Type typeof()
  {
    if (type == null) type = Sys.findType("concurrent::Actor");
    return type;
  }
  private static Type type;

//////////////////////////////////////////////////////////////////////////
// Actor
//////////////////////////////////////////////////////////////////////////

  public final ActorPool pool() { return pool; }

  public final Future send(Object msg) { return _send(msg, null, null); }

  public final Future sendLater(Duration d, Object msg) { return _send(msg, d, null); }

  public final Future sendWhenComplete(Future f, Object msg) { return _send(msg, null, f); }

  public final Future sendWhenDone(Future f, Object msg) { return _send(msg, null, f); }

  protected Object receive(Object msg)
  {
    if (receive != null) return receive.call(msg);
    System.out.println("WARNING: " + typeof() + ".receive not overridden");
    return null;
  }

  public final long queueSize() { return queue.size; }

  public final long queuePeak() { return queue.peak; }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  public static void sleep(Duration duration)
  {
    try
    {
      long ticks = duration.toNanos();
      java.lang.Thread.sleep(ticks/1000000L, (int)(ticks%1000000L));
    }
    catch (InterruptedException e)
    {
      throw InterruptedErr.make(e);
    }
  }

  public static Map locals() { return (Map)locals.get(); }
  private static final ThreadLocal locals = new ThreadLocal()
  {
    protected Object initialValue()
    {
      return Map.make();
      //return new Map(Sys.StrType, Sys.ObjType.toNullable());
    }
  };

//////////////////////////////////////////////////////////////////////////
// Implementation
//////////////////////////////////////////////////////////////////////////

  private Future _send(Object msg, Duration dur, Future whenDone)
  {
    // ensure immutable or safe copy
    msg = _safe(msg);

    // don't deliver new messages to a stopped pool
    if (pool.isStopped()) throw Err.make("ActorPool is stopped");

    // get the future instance to manage this message's lifecycle
    Future f = new Future(msg);

    // either enqueue immediately or schedule with pool
    if (dur != null)
      pool.schedule(this, dur, f);
    else if (whenDone != null)
      whenDone.sendWhenDone(this, f);
    else
      f = _enqueue(f, true);

    return f;
  }

  final Future _enqueue(Future f, boolean coalesce)
  {
    synchronized (lock)
    {
      // attempt to coalesce
      if (coalesce)
      {
        Future c = queue.coalesce(f);
        if (c != null) return c;
      }

      // add to queue
      queue.add(f);

      // submit to thread pool if not submitted or current running
      if (!submitted)
      {
        submitted = true;
        pool.submit(this);
      }

      return f;
    }
  }

  public final void _work()
  {
    // set locals for this actor
    locals.set(context.locals);
    Locale.setCur(context.locale);

    // process up to 100 messages before yielding the thread
    int maxMessages = (int)pool.maxMsgsBeforeYield;
    for (int count = 0; count < maxMessages; count++)
    {
      // get next message, or if none pending we are done
      Future future = null;
      synchronized (lock) { future = queue.get(); }
      if (future == null) break;

      // dispatch the messge
      this.curMsg = future.msg;
      _dispatch(future);
      this.curMsg = null;
    }

    // flush locals back to context
    context.locale = Locale.cur();

    // done dispatching, either clear the submitted
    // flag or resubmit to the thread pool
    synchronized (lock)
    {
      if (queue.size == 0)
      {
        submitted = false;
      }
      else
      {
        submitted = true;
        pool.submit(this);
      }
    }

  }

  final void _dispatch(Future future)
  {
    try
    {
      if (future.isCancelled()) return;
      if (pool.killed) { future.cancel(); return; }
      future.complete(receive(future.msg));
    }
    catch (Err e)
    {
      future.completeErr(e);
    }
    catch (Throwable e)
    {
      future.completeErr(Err.make(e));
    }
  }

  public void _kill()
  {
    // get/reset the pending queue
    Queue queue = null;
    synchronized (lock)
    {
      queue = this.queue;
      this.queue = new Queue();
    }

    // cancel all pending messages
    while (true)
    {
      Future future = queue.get();
      if (future == null) break;
      future.cancel();
    }
  }

  static Object _safe(Object obj)
  {
    if (obj == null) return null;
    if (FanObj.isImmutable(obj)) return obj;

    if (_safeLogErr)
    {
      _safeLogErr = false;
      System.out.println("==");
      System.out.println("==");
      System.out.println("== Actor msg serialization is deprecated;");
      System.out.println("== See http://fantom.org/forum/topic/2428");
      System.out.println("==");
      System.out.println("==");
    }

    Buf buf = MemBuf.make(512);
    Util.writeObj(buf.out(), obj);
    buf.flip();
    return Util.readObj(buf.in());
  }
  private static volatile boolean _safeLogErr = true;

//////////////////////////////////////////////////////////////////////////
// Queue
//////////////////////////////////////////////////////////////////////////

  static class Queue
  {
    public Future get()
    {
      if (head == null) return null;
      Future f = head;
      head = f.next;
      if (head == null) tail = null;
      f.next = null;
      size--;
      return f;
    }

    public void add(Future f)
    {
      if (tail == null) { head = tail = f; f.next = null; }
      else { tail.next = f; tail = f; }
      size++;
      if (size > peak) peak = size;
    }

    public Future coalesce(Future f)
    {
      return null;
    }

    void dump(fan.std.OutStream out)
    {
      int num = 0;
      int max = 50;
      for (Future x = head; x != null; x = x.next)
      {
        if (num < max) out.print("  ").printLine(x.msg);
        num++;
      }
      if (num > max) out.print("  " + (num-max) + " more messages...");
    }

    Future head, tail;
    int size;
    int peak;
  }

//////////////////////////////////////////////////////////////////////////
// CoalescingQueue
//////////////////////////////////////////////////////////////////////////

  static class CoalescingQueue extends Queue
  {
    CoalescingQueue(Func toKeyFunc, Func coalesceFunc)
    {
      this.toKeyFunc = toKeyFunc;
      this.coalesceFunc = coalesceFunc;
    }

    public Future get()
    {
      Future f = super.get();
      if (f != null)
      {
        try
        {
          Object key = toKey(f.msg);
          if (key != null) pending.remove(key);
        }
        catch (Throwable e)
        {
          e.printStackTrace();
        }
      }
      return f;
    }

    public void add(Future f)
    {
      try
      {
        Object key = toKey(f.msg);
        if (key != null) pending.put(key, f);
      }
      catch (Throwable e)
      {
        e.printStackTrace();
      }
      super.add(f);
    }

    public Future coalesce(Future incoming)
    {
      Object key = toKey(incoming.msg);
      if (key == null) return null;

      Future orig = (Future)pending.get(key);
      if (orig == null) return null;

      orig.msg = coalesce(orig.msg, incoming.msg);
      return orig;
    }

    private Object toKey(Object obj)
    {
      return toKeyFunc == null ? obj : toKeyFunc.call(obj);
    }

    private Object coalesce(Object orig, Object incoming)
    {
      return coalesceFunc == null ? incoming : coalesceFunc.call(orig, incoming);
    }

    Func toKeyFunc, coalesceFunc;
    HashMap pending = new HashMap();
  }

//////////////////////////////////////////////////////////////////////////
// Debug
//////////////////////////////////////////////////////////////////////////

  public Object trap(String name, List args)
  {
    if (name.equals("dump")) return dump(args);
    return super.trap(name, args);
  }

  public final Object dump(List args)
  {
    fan.std.OutStream out = fan.std.Env.cur().out();
    if (args != null && args.size() > 0)
      out = (fan.std.OutStream)args.get(0);
    try
    {
      out.printLine("Actor");
      out.printLine("  pool:      " + pool.name);
      out.printLine("  submitted: " + submitted);
      out.printLine("  queue:     " + queueSize());
      out.printLine("  peak:      " + queuePeak());
      out.printLine("  curMsg:    " + curMsg);
      queue.dump(out);

    }
    catch (Exception e) { out.printLine("  " + e + "\n"); }
    return out;
  }

//////////////////////////////////////////////////////////////////////////
// Context
//////////////////////////////////////////////////////////////////////////

  static final class Context
  {
    Context(Actor actor) { this.actor = actor; }
    final Actor actor;
    final Map locals = Map.make();//new Map(Sys.StrType, Sys.ObjType.toNullable());
    Locale locale = Locale.cur();
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  final Context context;                 // mutable world state of actor
  private ActorPool pool;                // pooled controller
  private Func receive;                  // func to invoke on receive or null
  private Object lock = new Object();    // lock for message queue
  private Queue queue;                   // message queue linked list
  private Object curMsg;                 // if currently processing a message
  private boolean submitted = false;     // is actor submitted to thread pool

}