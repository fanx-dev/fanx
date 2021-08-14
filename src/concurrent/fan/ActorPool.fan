//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Mar 09  Brian Frank  Creation
//

**
** Controller for a group of actors which manages their
** execution using pooled thread resources.
**
** See [docLang::Actors]`docLang::Actors`
**
@Js
rtconst class ActorPool
{
  private ThreadPool threadPool;
  private Timer scheduler;
  Bool killed := false { private set }

  private static const ActorPool _defPool := make()
  static ActorPool defVal() { _defPool }

  **
  ** It-block constructor
  **
  new make(|This|? f := null) {
    f?.call(this)
    if (maxThreads < 1) throw ArgErr.make("ActorPool.maxThreads must be >= 1, not " + maxThreads);
    threadPool = ThreadPool(name, maxThreads)
    scheduler = Timer(name+"-Timer")
  }

  override Bool isImmutable() { true }

  **
  ** Return true if this pool has been stopped or killed.  Once a
  ** a pool is stopped, new messages may not be delivered to any of its
  ** actors.  A stopped pool is not necessarily done until all its
  ** actors have finished processing.  Also see `isDone` and `join`.
  **
  Bool isStopped() { threadPool.isStopped }

  **
  ** Return true if this pool has been stopped or killed and all
  ** its actors have completed processing.  If this pool was stopped
  ** then true indicates that all pending messages in the queues before
  ** the stop have been fully processed.  If this pool was killed,
  ** then this method returns true once all actors have exited their
  ** thread.  See `join` to block until done.
  **
  Bool isDone() { threadPool.isDone }

  **
  ** Perform an orderly shutdown.  Once stopped, no new messages may
  ** be sent to this pool's actors.  However, any pending messages
  ** will be processed.  Note that scheduled messages are *not*
  ** guaranteed to be processed, only those delivered with 'Actor.send'.
  **
  ** Use `join` to wait for all actors to complete their message queue.
  ** To perform an immediate shutdown use `kill`.  If the pool has
  ** already been stopped, then do nothing.  Return this.
  **
  This stop() {
    threadPool.stop
    scheduler.stop
    return this
  }

  **
  ** Perform an unorderly shutdown.  Any pending messages which have
  ** not started processing are cancelled.  Actors which are currently
  ** processing a message will be interrupted.  See `stop` to perform
  ** an orderly shutdown.  If the pool has already been killed,
  ** then do nothing.
  **
  This kill() {
    killed = true;
    scheduler.stop();
    threadPool.kill();
    return this;
  }

  **
  ** Wait for this pool's actors to fully terminate or until the
  ** given timeout occurs.  A null timeout blocks forever.  If this
  ** method times out, then TimeoutErr is thrown.  Throw Err if the
  ** pool is not stopped.  Return this.
  **
  This join(Duration? timeout := null) {
    if (!isStopped()) throw Err.make("ActorPool is not stopped");
    Int ms = timeout == null ? Int.maxVal : timeout.toMillis();
    threadPool.join(ms)
    return this
  }

  **
  ** Given a list of one or more actors, return the next actor to use
  ** to perform load balanced work. The default implemention returns
  ** the actor with the lowest number of messages in its queue.
  **
  ** NOTE: this is an experimental feature which is subject to change
  **
  @NoDoc virtual Actor balance(Actor[] actors) {
    Actor best = (Actor)actors.get(0);
    Int bestSize = best.queueSize();
    if (bestSize == 0) return best;

    for (i:=1; i<actors.size; ++i)
    {
      Actor x = (Actor)actors.get(i);
      Int xSize = x.queueSize();
      if (xSize < bestSize)
      {
        best = x;
        bestSize = xSize;
        if (bestSize == 0) return best;
      }
    }
    return best;
  }


  internal Bool hasPending()
  {
    return threadPool.hasPending();
  }

  internal Void submit(Actor actor)
  {
    threadPool.submit |->| { actor._work }
  }

  internal Void schedule(Actor actor, Duration d, ActorFuture future)
  {
    //echo("schedule: $actor, $d, $future")
    scheduler.schedule(d.toNanos) |->| {
      if (!future.isCancelled()) {
        if (isStopped) {
          future.cancel()
        }
        else {
          actor._enqueue(future, false);
        }
      }
    }
  }

  **
  ** Name to use for the pool and associated threads.
  **
  const Str name := "ActorPool"

  **
  ** Max number of threads which are used by this pool
  ** for concurrent actor execution.  This value must be
  ** at least one or greater.
  **
  const Int maxThreads := 100

  **
  ** Max duration an actor will work processing messages before yielding its
  ** thread.  Because actors require cooperative multi-tasking we don't
  ** want to let an actor hog a thread forever and potentially starve out
  ** other actors waiting for a thread.  Note its possible for an actor to
  ** work longer than this time (especially if its blocking on I/O).  However
  ** once this time has expired, the actor will not process subsequent messages
  ** in its queue.  As an optimization an actor will never yield unless
  ** the pool has other actors waiting for a thread.
  **
  ** NOTE: this method is marked as NoDoc, it is provided for low level
  ** access to tune the actor pool, but it is subject to change.
  **
  @NoDoc const Duration maxTimeBeforeYield := 1sec

}