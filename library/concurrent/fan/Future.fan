//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Mar 09  Brian Frank  Creation
//

**
** Future represents the result of an asynchronous computation.
**
** See [docLang::Actors]`docLang::Actors`
**
@Js
native abstract rtconst class Future
{

  **
  ** Construct a completable future instance in the pending state.
  ** This method is subject to change.
  **
  static Future makeCompletable() { return ActorFuture(null) }

  **
  ** Subclass constructor
  **
  protected new make() {}

  **
  ** Block current thread until result is ready.  If timeout occurs
  ** then TimeoutErr is raised.  A null timeout blocks forever.  If
  ** an exception was raised by the asynchronous computation, then it
  ** is raised to the caller of this method.
  **
  abstract Obj? get(Duration? timeout := null)

  **
  ** Current state of asynchronous computation
  **
  abstract FutureState state()

  **
  ** Deprecated, use 'state.isComplete'.
  **
  @NoDoc @Deprecated { msg = "Use Future.state" }
  Bool isDone() { state.isComplete }

  **
  ** Deprecated, use 'state.isCancelled'.
  **
  @NoDoc @Deprecated { msg = "Use Future.state" }
  Bool isCancelled() { state.isCancelled }

  **
  ** Cancel this computation if it has not begun processing.
  ** No guarantee is made that the computation will be cancelled.
  **
  abstract Void cancel()

  **
  ** Complete the future successfully with given value.  Raise
  ** an exception if value is not immutable or the future is
  ** already complete (ignore this call if cancelled).
  ** Raise UnsupportedErr if this future is not completable.
  ** Return this. This method is subject to change.
  **
  abstract This complete(Obj? val)

  **
  ** Complete the future with a failure condition using given
  ** exception.  Raise an exception if the future is already
  ** complete (ignore this call if cancelled).  Return this.
  ** Raise UnsupportedErr if this future is not completable.
  ** This method is subject to change.
  **
  abstract This completeErr(Err err)

  **
  ** If this future wraps another future
  **
  @NoDoc virtual Future? wraps() { null }

  **
  ** Block until this future transitions to a completed state (ok,
  ** err, or canceled).  If timeout is null then block forever, otherwise
  ** raise a TimeoutErr if timeout elapses.  Return this.
  **
  abstract This waitFor(Duration? timeout := null)

  **
  ** Block on a list of futures until they all transition to a completed
  ** state.  If timeout is null block forever, otherwise raise TimeoutErr
  ** if any one of the futures does not complete before the timeout
  ** elapses.
  **
  static Void waitForAll(Future[] list, Duration? timeout := null) {
    ActorFuture.waitForAll(list, timeout)
  }

}

**************************************************************************
** ActorFuture
**************************************************************************

** Actor implementation for future
internal final rtconst class ActorFuture  : Future
{
  Obj? msg;          // message send to Actor
  ActorFuture? next; // linked list in Actor
  private FutureState _state := FutureState.pending; // processing state of message
  private Obj? result;       // result or exception of processing
  private Obj?[]? whenDone;  // list of messages to deliver when done
  private |->|? then;
  private Lock lock = Lock()
  private ConditionVar condVar := ConditionVar(lock)

  new make(Obj? msg) {
    this.msg = msg
  }

  override Bool isImmutable() { true }

  override Obj? get(Duration? timeout := null) {
    waitFor(timeout)

    // if canceled throw CancelErr
    if (state.isCancelled)
      throw CancelledErr.make("Future cancelled");

    // if error was raised, raise it to caller
    if (state.isErr)
      throw ((Err)result);

    // assign result to local variable for return
    Obj? r = result;

    // ensure immutable or safe copy
    return Actor._safe(r);
  }


  override FutureState state() { _state }

  override Void cancel() {
    List? wd;
    lock.sync {
      if (!state.isComplete) _state = FutureState.cancelled;
      msg = result = null;  // allow gc
      condVar.signalAll();
      wd = whenDone; whenDone = null;
      if (this.then != null) this.then.call();
      lret null
    }
    sendWhenDone(wd);
  }

  override This complete(Obj? val) {
    r := Actor._safe(val);
    List? wd;
    lock.lock
    try {
      if (state == FutureState.cancelled) return this;
      if (state != FutureState.pending) throw Err.make("Future already complete");
      _state = FutureState.ok;
      result = r;
      condVar.signalAll();
      wd = whenDone; whenDone = null;
      if (this.then != null) this.then.call();
    }
    finally {
      lock.unlock
    }
    sendWhenDone(wd);
    return this;
  }

  override This completeErr(Err err) {
    r := Actor._safe(err);
    List? wd;
    lock.lock 
    try {
      if (state == FutureState.cancelled) return this;
      if (state != FutureState.pending) throw Err.make("Future already complete");
      _state = FutureState.err;
      result = r;
      condVar.signalAll();
      wd = whenDone; whenDone = null;
      if (this.then != null) this.then.call();
    }
    finally {
      lock.unlock
    }
    sendWhenDone(wd);
    return this;
  }

  override This waitFor(Duration? timeout := null) {
    lock.lock
    try
    {
        // wait until we enter a done state, the only notifies
        // on this object should be from cancel, complete, or completeErr
        if (timeout == null)
        {
          // wait forever until done
          while (!state.isComplete) condVar.wait();
        }
        else
        {
          // if not done, then wait with timeout and then
          // if still not done throw a timeout exception
          if (!state.isComplete)
          {
            // compute deadline in millis
            deadline := TimePoint.nowMillis() + timeout.toMillis();

            // loop until we are done or our deadline has passed
            while (!state.isComplete)
            {
              left := deadline - TimePoint.nowMillis();
              if (left <= 0) break;
              condVar.wait(Duration.fromMillis(left));
            }

            // if we still aren't done this is a timeout
            if (!state.isComplete) throw TimeoutErr.make("Future.get timed out");
          }
        }

        return this
    }
    finally
    {
      lock.unlock
    }
  }

  static Void waitForAll(Future[] list, Duration? timeout := null) {
    if (timeout == null)
    {
      for (i:=0; i<list.size; ++i)
      {
        Future f = list.get(i);
        f.waitFor(null);
      }
    }
    else
    {
      deadline := TimePoint.nowMillis() + timeout.toMillis();
      for (i:=0; i<list.size; ++i)
      {
        Future f = list.get(i);
        left := deadline - TimePoint.nowMillis();
        f.waitFor(Duration.fromMillis(left));
      }
    }
  }

  internal Void _then(|->| f) {
    lock.sync {
      this.then = f;
      if (state().isComplete()) {
        this.then.call();
      }
      lret null
    }
  }

  internal Void addSendWhenDone(Actor actor, ActorFuture future) {
    // if already done, then set immediate flag
    // otherwise add to our when done list
    Bool immediate = false;
    lock.sync
    {
      if (isDone()) immediate = true;
      else
      {
        if (whenDone == null) whenDone = [,]
        whenDone.add |->| {
          actor._enqueue(future, false)
        }
      }
      lret null
    }

    // if immediate we are already done so enqueue immediately
    if (immediate)
    {
      try { actor._enqueue(future, false); }
      catch (Err e) { e.trace }
    }
  }

  internal static Void sendWhenDone(List? list)
  {
    if (list == null) return;
    for (i:=0; i<list.size; ++i)
    {
      Func f := list[i]
      try {
        f.call()
      }
      catch (Err e) {
        e.trace
      }
    }
  }
}

**************************************************************************
** FutureState
**************************************************************************

** State of a Future's asynchronous computation
@Js
enum class FutureState
{
  pending,
  ok,
  err,
  cancelled

  ** Return if pending state
  Bool isPending() { this === pending }

  ** Return if in any completed state: ok, err, or cancelled
  Bool isComplete() { this !== pending }

  ** Return if the ok state
  Bool isOk() { this === ok }

  ** Return if the err state
  Bool isErr() { this === err }

  ** Return if the cancelled state
  Bool isCancelled() { this === cancelled }
}


