//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Mar 09  Brian Frank  Creation
//

**
** Actor is a worker who processes messages asynchronously.
**
** See [docLang::Actors]`docLang::Actors` and
** [examples]`examples::concurrent-actors`.
**
@Js
native const class Actor
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Create an actor whose execution is controlled by the given ActorPool.
  ** If receive is non-null, then it is used to process messages sent to
  ** this actor.  If receive is specified then it must be an immutable
  ** function (it cannot capture state from the calling thread), otherwise
  ** NotImmutableErr is thrown.  If receive is null, then you must subclass
  ** Actor and override the `receive` method.
  **
  new make(ActorPool pool, |Obj? -> Obj?|? receive := null)

  **
  ** Create an actor with a coalescing message loop.  This constructor
  ** follows the same semantics as `make`, but has the ability to coalesce
  ** the messages pending in the thread's message queue.  Coalesced
  ** messages are merged into a single pending message with a shared
  ** Future.
  **
  ** The 'toKey' function is used to derive a key for each message,
  ** or if null then the message itself is used as the key.  If the 'toKey'
  ** function returns null, then the message is not considered for coalescing.
  ** Internally messages are indexed by key for efficient coalescing.
  **
  ** If an incoming message has the same key as a pending message
  ** in the queue, then the 'coalesce' function is called to coalesce
  ** the messages into a new merged message.  If 'coalesce' function itself
  ** is null, then we use the incoming message (last one wins).  The coalesced
  ** message occupies the same position in the queue as the original
  ** and reuses the original message's Future instance.
  **
  ** Both the 'toKey' and 'coalesce' functions are called while holding
  ** an internal lock on the queue.  So the functions must be efficient
  ** and never attempt to interact with other actors.
  **
  new makeCoalescing(ActorPool pool,
                     |Obj? msg -> Obj?|? toKey,
                     |Obj? orig, Obj? incoming -> Obj?|? coalesce,
                     |Obj? -> Obj? |? receive := null)

//////////////////////////////////////////////////////////////////////////
// Messaging
//////////////////////////////////////////////////////////////////////////

  **
  ** The pool used to control execution of this actor.
  **
  ActorPool pool()

  **
  ** Asynchronously send a message to this actor for processing.
  ** If msg is not immutable or serializable, then IOErr is thrown.
  ** Throw Err if this actor's pool has been stopped.  Return
  ** a future which may be used to obtain the result once it the
  ** actor has processed the message.  If the message is coalesced
  ** then this method returns the original message's future reference.
  ** Also see `sendLater` and `sendWhenComplete`.
  **
  Future send(Obj? msg)

  **
  ** Schedule a message for delivery after the specified period of
  ** duration has elapsed.  Once the period has elapsed the message is
  ** appended to the end of this actor's queue.  Accuracy of scheduling
  ** is dependent on thread coordination and pending messages in the queue.
  ** Scheduled messages are not guaranteed to be processed if the
  ** actor's pool is stopped.  Scheduled messages are never coalesced.
  ** Also see `send` and `sendWhenComplete`.
  **
  Future sendLater(Duration d, Obj? msg)

  **
  ** Schedule a message for delivery after the given future has completed.
  ** Completion may be due to the future returning a result, throwing an
  ** exception, or cancellation.  Send-when-complete messages are never
  ** coalesced.  Also see `send` and `sendLater`.
  **
  Future sendWhenComplete(Future f, Obj? msg)

  ** Obsolete - use `sendWhenComplete`
  @Deprecated { msg = "Use sendWhenComplete" }
  Future sendWhenDone(Future f, Obj? msg)

  **
  ** The receive behavior for this actor is handled by overriding
  ** this method or by passing a function to the constructor.  Return
  ** the result made available by the Future.  If an exception
  ** is raised by this method, then it is raised by 'Future.get'.
  **
  protected virtual Obj? receive(Obj? msg)

  **
  ** Get the current number of messages pending on the message queue.
  **
  ** NOTE: this method is marked as NoDoc, it is provided for low level
  ** access to monitor the actor, but it is subject to change.
  **
  @NoDoc Int queueSize()

  **
  ** Get the peak number of messages queued.
  **
  ** NOTE: this method is marked as NoDoc, it is provided for low level
  ** access to monitor the actor, but it is subject to change.
  **
  @NoDoc Int queuePeak()

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  **
  ** Put the currently executing actor thread to sleep for the
  ** specified period.  If the thread is interrupted for any
  ** reason while sleeping, then InterruptedErr is thrown.
  **
  static Void sleep(Duration duration)

  **
  ** Return the map of "global" variables visibile only to the current
  ** actor (similar to how thread locals work in Java).  These variables
  ** are keyed by a string name - by convention use a dotted notation
  ** beginning with your pod name to avoid naming collisions.
  **
  static Str:Obj? locals()

}