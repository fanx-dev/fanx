//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   27 Mar 09  Brian Frank  Creation
//
package fan.concurrent;

import java.util.LinkedList;
import java.util.HashMap;
import java.util.Iterator;

/**
 * ThreadPool manages a pool of threads optimized for the Actor framework.
 */
public class ThreadPool
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  /**
   * Construct with max number of threads.
   */
  public ThreadPool(String name, int max)
  {
    this.name     = name;
    this.max      = max;
    this.idleTime = 5000; // 5sec
    this.idle     = new LinkedList();
    this.pending  = new LinkedList();
    this.workers  = new HashMap(max*3);
    this.state    = RUNNING;
  }

//////////////////////////////////////////////////////////////////////////
// Lifecycle
//////////////////////////////////////////////////////////////////////////

  /**
   * Has this pool been stopped or killed.
   */
  public final boolean isStopped()
  {
    return state != RUNNING;
  }

  /**
   * Has all the work in this queue finished processing and
   * all threads terminated.
   */
  public final boolean isDone()
  {
    if (state == DONE) return true;
    synchronized (this)
    {
      if (state == RUNNING || workers.size() > 0) return false;
      state = DONE;
      return true;
    }
  }

  /**
   * Orderly shutdown of threads.  All pending work items are processed.
   */
  public final synchronized void stop()
  {
    state = STOPPING;

    // immediately wake up all the idle workers so they can die
    while (true)
    {
      Worker w = (Worker)idle.poll();
      if (w == null) break;
      w.post(null);
    }
  }

  /**
   * Unorderly shutdown of threads.  All pending work are discarded,
   * and interrupt is sent to each thread.
   */
  public final synchronized void kill()
  {
    state = STOPPING;

    // kill all the pending work
    while (true)
    {
      Work work = (Work)pending.poll();
      if (work == null) break;
      work._kill();
    }

    // interupt each thread
    Iterator it = workers.values().iterator();
    while (it.hasNext()) ((Worker)it.next()).interrupt();
  }

  /**
   * Wait for all threads to stop.
   ** Return true on success or false on timeout.
   */
  public final synchronized boolean join(long msTimeout)
    throws InterruptedException
  {
    long deadline = System.nanoTime()/1000000L + msTimeout;
    while (true)
    {
      // if all workers have completed, then return success
      if (workers.size() == 0) return true;

      // if we have gone past our deadline, return false
      long toSleep = deadline - System.nanoTime()/1000000L;
      if (toSleep <= 0) return false;

      // sleep until something interesting happens
      wait(toSleep);
    }
  }

//////////////////////////////////////////////////////////////////////////
// Work Management
//////////////////////////////////////////////////////////////////////////

  /**
   * Submit the given work to be run by a thread in this pool.
   * If an idle thread is available, the work is immediately
   * run.  If no idle threads are available, but the current number
   * of threads is less than max, then launch a new thread to
   * execute the work.  If the current number of threads is at
   * max, then queue the work until a thread becomes available.
   */
  public synchronized void submit(Work work)
  {
    // if we have an idle thread, use it
    Worker worker = (Worker)idle.poll();
    if (worker != null)
    {
      worker.post(work);
      return;
    }

    // if we are below max, then spawn a new thread
    if (workers.size() < max)
    {
      worker = new Worker(name + "-Worker-" + (counter++), work);
      worker.start();
      workers.put(worker, worker);
      return;
    }

    // queue the runnable until we have an idle thread
    pending.addLast(work);
  }

  /**
   * This is called by a worker when it completes a work item.  If
   * there is pending work post it back to the worker and return true.
   * If there is no pending work and we are stopping then return
   * false, otherwise add worker to our idle queue and return true.
   */
  synchronized boolean ready(Worker w)
  {
    // if we have a pending work, then immediately reuse the worker
    Work work = (Work)pending.poll();
    if (work != null)
    {
      w.post(work);
      return true;
    }

    // if shutting down, then free the worker return false
    if (state != RUNNING)
    {
      free(w);
      return false;
    }

    // add to head of idle list (we let oldest threads die out first)
    idle.addFirst(w);
    return true;
  }

  /**
   * Free worker from all data structures and let it die.
   */
  synchronized void free(Worker w)
  {
    idle.remove(w);
    workers.remove(w);
    notifyAll();
  }

//////////////////////////////////////////////////////////////////////////
// Debug
//////////////////////////////////////////////////////////////////////////

  public void dump(fan.std.OutStream out)
  {
    out.printLine("  pending:    " + pending.size());
    out.printLine("  idle:       " + idle.size());
    out.printLine("  workers:    " + workers.size());
    Iterator it = workers.values().iterator();
    while (it.hasNext())
    {
      Worker w = (Worker)it.next();
      out.print("  ").print(w.getName()).print(": ");
      Work work = w.work;
      if (work == null)
        out.print("idle");
      else
        out.print(work);
      if (work instanceof Actor)
      {
        Actor actor = (Actor)work;
        out.print(" [queue: ").print(actor.queueSize()).print("]");
      }
      out.printLine();
    }
  }

//////////////////////////////////////////////////////////////////////////
// Worker
//////////////////////////////////////////////////////////////////////////

  /**
   * Worker is a reusable thread within the thread pool.
   */
  class Worker extends Thread
  {
    /**
     * Construct with name and initial work to execute.
     */
    Worker(String name, Work work)
    {
      super(name);
      this.work = work;
    }

    /**
     * Equality must be reference for storage in a hash table.
     */
    public final boolean equals(Object o)
    {
      return this == o;
    }

    /**
     * A worker thread loops repeatly executing work until it times out.
     */
    public void run()
    {
      try
      {
        // loop until we have explicit return
        while (true)
        {
          // execute work posted to me
          try { work._work(); } catch (Throwable e) { e.printStackTrace(); }
          work = null;

          // inform pool I'm ready for more work, three potential outcomes:
          //   - if ready returns false then time to immediately
          //     exit and have this thread die
          //   - if ready posted a new work item to me, then continue
          //     my loop and immediately execute it
          //   - enter the idle state and wait for a bit more work
          if (!ready(this)) return;
          if (work != null) continue;

          // enter idle state until more work is posted to me
          synchronized(this)
          {
            // it is possible that between ready and acquiring my
            // lock that submit posted work to me, so double check
            // work field before I enter my sleep cycle
            if (work != null) continue;

            // enter wait state until either timeout or more work is posted
            try { wait(idleTime); } catch (InterruptedException e) {}
            if (work != null) continue;
          }

          // if we've made it here, then we've expired our idle time;
          // so free ourselves from the thread pool
          free(this);

          // it is possible that between releasing my lock and calling
          // free that submit posted one more work item to me, so double
          // check work field before we exit the thread
          synchronized (this)
          {
            if (work != null)
            {
              try { work._work(); } catch (Throwable e) { e.printStackTrace(); }
            }
            return;
          }
        }
      }
      catch (Throwable e)
      {
        // if an exception is raised, free worker
        e.printStackTrace();
        free(this);
      }
    }

    /**
     * Give this thread a work item and call notify in case its idling.
     */
    public synchronized void post(Work work)
    {
      this.work = work;
      notifyAll();
    }

    Work work;
  }

//////////////////////////////////////////////////////////////////////////
// Work
//////////////////////////////////////////////////////////////////////////

  /**
   * Item of work to execute in the thread pool.
   * Note: method _work() is used so we don't polluate Actor's namespace.
   */
  public static interface Work
  {
    public void _work();
    public void _kill();
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  static final int RUNNING  = 0;
  static final int STOPPING = 1;
  static final int DONE     = 2;

  final String name;           // actor pool name
  final int max;               // maximum number of threads to use
  final int idleTime;          // time in ms to let threads idle (5sec)
  private volatile int state;  // life cycle state
  private LinkedList idle;     // idle threads waiting for work
  private LinkedList pending;  // pending working we don't have threads for yet
  private HashMap workers;     // map of all worker threads
  private int counter;         // counter for all threads ever created
}