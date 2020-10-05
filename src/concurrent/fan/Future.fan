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
native abstract const class Future
{

  **
  ** Construct a completable future instance in the pending state.
  ** This method is subject to change.
  **
  static Future makeCompletable()

  **
  ** Subclass constructor
  **
  protected new make()

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
  Bool isDone()

  **
  ** Deprecated, use 'state.isCancelled'.
  **
  @NoDoc @Deprecated { msg = "Use Future.state" }
  Bool isCancelled()

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
  @NoDoc virtual Future? wraps()

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
  static Void waitForAll(Future[] futures, Duration? timeout := null)

}

**************************************************************************
** ActorFuture
**************************************************************************

** Actor implementation for future
internal native final const class ActorFuture  : Future
{
  override Obj? get(Duration? timeout := null)
  override FutureState state()
  override Void cancel()
  override This complete(Obj? val)
  override This completeErr(Err err)
  override This waitFor(Duration? timeout := null)

  internal Void _then(|->| f)
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


