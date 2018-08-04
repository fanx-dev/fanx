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
native const class ActorPool
{
  static ActorPool defVal()

  **
  ** It-block constructor
  **
  new make(|This|? f := null)

  **
  ** Return true if this pool has been stopped or killed.  Once a
  ** a pool is stopped, new messages may not be delivered to any of its
  ** actors.  A stopped pool is not necessarily done until all its
  ** actors have finished processing.  Also see `isDone` and `join`.
  **
  Bool isStopped()

  **
  ** Return true if this pool has been stopped or killed and all
  ** its actors have completed processing.  If this pool was stopped
  ** then true indicates that all pending messages in the queues before
  ** the stop have been fully processed.  If this pool was killed,
  ** then this method returns true once all actors have exited their
  ** thread.  See `join` to block until done.
  **
  Bool isDone()

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
  This stop()

  **
  ** Perform an unorderly shutdown.  Any pending messages which have
  ** not started processing are cancelled.  Actors which are currently
  ** processing a message will be interrupted.  See `stop` to perform
  ** an orderly shutdown.  If the pool has already been killed,
  ** then do nothing.
  **
  This kill()

  **
  ** Wait for this pool's actors to fully terminate or until the
  ** given timeout occurs.  A null timeout blocks forever.  If this
  ** method times out, then TimeoutErr is thrown.  Throw Err if the
  ** pool is not stopped.  Return this.
  **
  This join(Duration? timeout := null)

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
  ** Max number of messages processed by an actor before the actor yields
  ** the thread another actor.  A high number allows processing lots of
  ** quick messages to avoid excessive thread context switching.  A smaller
  ** number can be used for long message processing where the thread context
  ** switching might be less significant.
  **
  ** NOTE: this method is marked as NoDoc, it is provided for low level
  ** access to tune the actor pool, but it is subject to change.
  **
  @NoDoc const Int maxMsgsBeforeYield := 100

}