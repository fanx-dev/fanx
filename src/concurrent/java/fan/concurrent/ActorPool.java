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

/**
 * Controller for a group of actors which manages their execution
 * using pooled thread resources.
 */
public class ActorPool
  extends FanObj
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  private static ActorPool pool = null;
  public static ActorPool defVal() {
	  if (pool == null) {
		  pool = make();
	  }
	  return pool;
  }

  public static ActorPool make() { return make(null); }
  public static ActorPool make(Func func)
  {
    ActorPool self = new ActorPool();
    make$(self, func);
    return self;
  }

  public static void make$(ActorPool self) { make$(self, null); }
  public static void make$(ActorPool self, Func itBlock)
  {
    if (itBlock != null)
    {
//      itBlock.enterCtor(self);
      itBlock.call(self);
//      itBlock.exitCtor();
    }
    if (self.maxThreads < 1) throw ArgErr.make("ActorPool.maxThreads must be >= 1, not " + self.maxThreads);

    self.threadPool = new ThreadPool(self.name, (int)self.maxThreads);
    self.scheduler = new Scheduler(self.name);
  }

//////////////////////////////////////////////////////////////////////////
// Obj
//////////////////////////////////////////////////////////////////////////

  public Type typeof()
  {
    if (type == null) type = Sys.findType("concurrent::ActorPool");
    return type;
  }
  private static Type type;

//////////////////////////////////////////////////////////////////////////
// ActorPool
//////////////////////////////////////////////////////////////////////////

  public final boolean isStopped()
  {
    return threadPool.isStopped();
  }

  public final boolean isDone()
  {
    return threadPool.isDone();
  }

  public final ActorPool stop()
  {
    scheduler.stop();
    threadPool.stop();
    return this;
  }

  public final ActorPool kill()
  {
    killed = true;
    scheduler.stop();
    threadPool.kill();
    return this;
  }

  public final ActorPool join() { return join(null); }
  public final ActorPool join(Duration timeout)
  {
    if (!isStopped()) throw Err.make("ActorPool is not stopped");
    long ms = timeout == null ? Long.MAX_VALUE : timeout.toMillis();
    try
    {
      if (threadPool.join(ms)) return this;
    }
    catch (InterruptedException e)
    {
      throw InterruptedErr.make(e);
    }
    throw TimeoutErr.make("ActorPool.join timed out");
  }

  public Object trap(String name, List args)
  {
    if (name.equals("dump")) return dump(args);
    return super.trap(name, args);
  }

  public Actor balance(List actors)
  {
    Actor best = (Actor)actors.get(0);
    long bestSize = best.queueSize();
    if (bestSize == 0) return best;

    for (int i=1; i<actors.sz(); ++i)
    {
      Actor x = (Actor)actors.get(i);
      long xSize = x.queueSize();
      if (xSize < bestSize)
      {
        best = x;
        bestSize = xSize;
        if (bestSize == 0) return best;
      }
    }
    return best;
  }

  final boolean hasPending()
  {
    return threadPool.hasPending();
  }

  final void submit(Actor actor)
  {
    threadPool.submit(actor);
  }

  final void schedule(Actor a, Duration d, ActorFuture f)
  {
    scheduler.schedule(d.toNanos(), new ScheduledWork(a, f));
  }

//////////////////////////////////////////////////////////////////////////
// Debug
//////////////////////////////////////////////////////////////////////////

  public final Object dump(List args)
  {
    fan.std.OutStream out = fan.std.Env.cur().out();
    if (args != null && args.size() > 0)
      out = (fan.std.OutStream)args.get(0);
    try
    {
      out.printLine("ActorPool");
      out.printLine("  name:       " + name);
      out.printLine("  maxThreads: " + maxThreads);
      out.printLine("  maxTime:    " + maxTimeBeforeYield);
      threadPool.dump(out);
    }
    catch (Exception e) { out.printLine("  " + e + "\n"); }
    return out;
  }

//////////////////////////////////////////////////////////////////////////
// ScheduledWork
//////////////////////////////////////////////////////////////////////////

  static class ScheduledWork implements Scheduler.Work
  {
    ScheduledWork(Actor a, ActorFuture f) { actor = a; future = f; }
    public String toString() { return "ScheduledWork msg=" + future.msg; }
    public void work() { if (!future.isCancelled()) actor._enqueue(future, false); }
    public void cancel() { future.cancel(); }
    final Actor actor;
    final ActorFuture future;
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private ThreadPool threadPool;
  private Scheduler scheduler;
  volatile boolean killed;
  public String name = "ActorPool";
  public long maxThreads = 100;
  public Duration maxTimeBeforeYield = Duration.fromSec(1);
}