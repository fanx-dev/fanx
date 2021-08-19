//
// Copyright (c) 2021, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2021-8-13 Jed Young Creation
//

internal rtconst class ThreadPool
{
  private BlockingQueue queue := BlockingQueue()
  private Thread[] threads := [,]
  private Str name
  private Int max
  private Lock lock := Lock()
  private Bool _isDone := false
  private Bool _isStoped := false
  private Int busyThreadNum := 0

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  /**
   * Construct with max number of threads.
   */
  new make(Str name, Int max)
  {
    this.name       = name;
    this.max        = max;
  }

  override Bool isImmutable() { true }

//////////////////////////////////////////////////////////////////////////
// Lifecycle
//////////////////////////////////////////////////////////////////////////

  /**
   * Has this pool been stopped or killed.
   */
  public Bool isStopped()
  {
    _isStoped || queue.isStopped
  }

  /**
   * Has all the work in this queue finished processing and
   * all threads terminated.
   */
  public Bool isDone() { _isDone }


  /**
   * Orderly shutdown of threads.  All pending work items are processed.
   */
  public Void stop() { queue.stop }

  /**
   * Unorderly shutdown of threads.  All pending work are discarded,
   * and interrupt is sent to each thread.
   */
  public Void kill()
  {
    _isStoped = true
    queue.stop
  }

  /**
   * Wait for all threads to stop.
   * Return true on success or false on timeout.
   */
  public Void join(Int msTimeout)
  {
    while (true) {
      Thread? t
      lock.lock
      if (threads.size > 0) t = threads.pop
      lock.unlock
      if (t == null) break
      t.join
    }
  }

//////////////////////////////////////////////////////////////////////////
// Work Management
//////////////////////////////////////////////////////////////////////////

  /**
   * Return if we have pending worker awaiting a thread.
   */
  Bool hasPending() { return queue.size() > 0; }

  /**
   * Submit the given work to be run by a thread in this pool.
   * If an idle thread is available, the work is immediately
   * run.  If no idle threads are available, but the current number
   * of threads is less than max, then launch a new thread to
   * execute the work.  If the current number of threads is at
   * max, then queue the work until a thread becomes available.
   */
  public Void submit(|->| task)
  {
    queue.enqueue(task)
    lock.lock
    if (threads.size == busyThreadNum) addThread
    lock.unlock
  }

  private Void addThread() {
    lock.sync {
      if (threads.size < max) {
        Thread? t
        t = Thread("$name-$threads.size") |->| { run(t) }
        threads.add(t)
        t.start
      }
      lret null
    }
  }

  private Void removeThread(Thread t) {
    lock.lock
      threads.remove(t)
    lock.unlock
  }

  private Void run(Thread t) {
    while (true) {
      |->|? task := queue.dequeue(5sec)

      lock.lock
      //kill
      // if (_isStoped) {
      //   _isDone = true
      //   lock.unlock
      //   return
      // }
      
      if (task != null) ++busyThreadNum
      //add thread again
      if (threads.size < max && threads.size == busyThreadNum) {
        if (queue.size > 0) {
          addThread
        }
      }
      lock.unlock

      //stop
      if (task == null && queue.isStopped) {
        _isDone = true
        return
      }

      //recude the thread
      if (task == null) {
        removeThread(t)
        return
      }

      try {
        task.call
      }
      catch (Err e) {
        e.trace
      }
      lock.lock
      --busyThreadNum
      lock.unlock
    }
  }
}