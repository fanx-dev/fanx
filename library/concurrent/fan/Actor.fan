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
@Js @JsNative
const class Actor
{
  private static const Unsafe<Obj?> idleMsg = Unsafe<Obj?>("_idle_");

  private const Unsafe<Context> context = Unsafe<Context>(Context(this)); // mutable world state of actor
  private const ActorPool _pool;                // pooled controller
  private const Func? _receive;                  // func to invoke on receive or null
  private const Lock lock = Lock();             // lock for message queue
  private const Unsafe<Queue> queue := Unsafe<Queue>(Queue());       // message queue linked list
  private const AtomicRef<Unsafe<Obj?>> curMsg = AtomicRef(idleMsg);          // if currently processing a message
  private const AtomicBool submitted := AtomicBool();         // is actor submitted to thread pool
  private const AtomicInt _receiveCount := AtomicInt();               // total number of messages received
  private const AtomicInt _receiveTicks := AtomicInt();               // total ticks spend in receive

  //coalescing
  private const |Obj? msg -> Obj?|? toKeyFunc
  private const |Obj? orig, Obj? incoming -> Obj?|? coalesceFunc
  private const Unsafe<[Obj:Obj?]?>? coalesceMap

  private static const ThreadLocal threadLocal := ThreadLocal()


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
  new make(ActorPool pool := ActorPool.defVal, |Obj? -> Obj?|? receive := null) {
    _pool = pool
    this._receive = receive

    // check receive method
    if (receive == null && this.typeof().qname().equals("concurrent::Actor"))
      throw ArgErr.make("must supply receive func or subclass Actor");
  }

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
                     |Obj? -> Obj? |? receive := null) {
    _pool = pool
    this._receive = receive
    this.toKeyFunc = toKey
    this.coalesceFunc = coalesce
    this.coalesceMap = Unsafe([:])
  }

//////////////////////////////////////////////////////////////////////////
// Messaging
//////////////////////////////////////////////////////////////////////////

  **
  ** The pool used to control execution of this actor.
  **
  ActorPool pool() { _pool }

  **
  ** Asynchronously send a message to this actor for processing.
  ** If msg is not immutable, then NotImmutableErr is thrown.
  ** Throw Err if this actor's pool has been stopped.  Return
  ** a future which may be used to obtain the result once it the
  ** actor has processed the message.  If the message is coalesced
  ** then this method returns the original message's future reference.
  ** Also see `sendLater` and `sendWhenComplete`.
  **
  Future send(Obj? msg) { _send(msg, null, null) }

  **
  ** Schedule a message for delivery after the specified period of
  ** duration has elapsed.  Once the period has elapsed the message is
  ** appended to the end of this actor's queue.  Accuracy of scheduling
  ** is dependent on thread coordination and pending messages in the queue.
  ** Scheduled messages are not guaranteed to be processed if the
  ** actor's pool is stopped.  Scheduled messages are never coalesced.
  ** Also see `send` and `sendWhenComplete`.
  **
  Future sendLater(Duration d, Obj? msg) { _send(msg, d, null) }

  **
  ** Schedule a message for delivery after the given future has completed.
  ** Completion may be due to the future returning a result, throwing an
  ** exception, or cancellation.  Send-when-complete messages are never
  ** coalesced.  The given future must be an actor based future.  Also
  ** see `send` and `sendLater`.
  **
  Future sendWhenComplete(Future f, Obj? msg) { _send(msg, null, f) }


  private Future _send(Obj? msg, Duration? dur, Future? whenDone)
  {
    // ensure immutable or safe copy
    msg = _safe(msg);

    // don't deliver new messages to a stopped pool
    if (pool.isStopped()) throw Err.make("ActorPool is stopped");

    // get the future instance to manage this message's lifecycle
    ActorFuture f = ActorFuture(msg);

    // either enqueue immediately or schedule with pool
    if (dur != null) {
      pool.schedule(this, dur, f);
    }
    else if (whenDone != null) {
      toWhenDoneFuture(whenDone).addSendWhenDone(this, f);
    }
    else {
      f = _enqueue(f, true);
    }

    return f;
  }

  private static ActorFuture toWhenDoneFuture(Future f)
  {
    if (f is ActorFuture) return (ActorFuture)f;
    Future? wraps = f.wraps();
    if (wraps is ActorFuture) return (ActorFuture)wraps;
    throw ArgErr.make("Only actor Futures supported for sendWhenComplete");
  }

  internal ActorFuture _enqueue(ActorFuture f, Bool _coalesce)
  {
    lock.lock
    try {
      // attempt to coalesce
      if (_coalesce)
      {
        ActorFuture? c = coalesce(f);
        if (c != null) return c;
      }

      // add to queue
      queue.val.add(f)
      updateCoalesce(f)

      // submit to thread pool if not submitted or current running
      if (!submitted.val)
      {
        submitted.val = true;
        pool.submit(this);
      }

      return f;
    }
    finally {
      lock.unlock
    }
  }

  ** Obsolete - use `sendWhenComplete`
  @NoDoc @Deprecated { msg = "Use sendWhenComplete" }
  Future sendWhenDone(Future f, Obj? msg) { sendWhenComplete(f, msg) }

  **
  ** The receive behavior for this actor is handled by overriding
  ** this method or by passing a function to the constructor.  Return
  ** the result made available by the Future.  If an exception
  ** is raised by this method, then it is raised by 'Future.get'.
  **
  protected virtual Obj? receive(Obj? msg) {
    if (_receive != null) return _receive.call(msg);
    echo("WARNING: " + this.typeof() + ".receive not overridden");
    return null;
  }

//////////////////////////////////////////////////////////////////////////
// Run
//////////////////////////////////////////////////////////////////////////

  internal Void _work()
  {
    // reset environment for this actor
    threadLocal.set(context.val.locals);
    Locale.setCur(context.val.locale);

    // process messages for maxTimeBeforeYield before yielding the thread
    Int maxTicks = pool.maxTimeBeforeYield.toNanos();
    Int startTicks = Duration.nowTicks();
    while (true)
    {
      // get next message, or if none pending we are done
      ActorFuture? future = null;
      lock.sync {
        future = queue.val.get
        lret null
      }
      if (future == null) break;

      // dispatch the messge
      this.curMsg.val = Unsafe<Obj?>(future.msg);
      _dispatch(future);
      this.curMsg.val = idleMsg;

      // if there are pending actors waiting for a thread,
      // then check if its time to yield our thread
      if (pool.hasPending())
      {
        Int curTicks = Duration.nowTicks();
        if (curTicks - startTicks >= maxTicks) break;
      }
    }

    // keep track of time between start and now; for efficiency we only
    // update this after a work cycle has ended - but this means its
    // possible to be stuck continously processing the queue if never have
    // to yield our thread, in which case we won't see this stat updated
    _receiveTicks.add(Duration.nowTicks() - startTicks);

    // flush environment back to context
    context.val.locale = Locale.cur();

    // done dispatching, either clear the submitted
    // flag or resubmit to the thread pool
    lock.sync
    {
      if (queue.val.size == 0)
      {
        submitted.val = false;
      }
      else
      {
        submitted.val = true;
        pool.submit(this);
      }
      lret null
    }

  }

  private Void _dispatch(ActorFuture future)
  {
    try
    {
      if (future.isCancelled()) return;
      if (pool.killed) { future.cancel(); return; }
      _receiveCount.increment
      future.complete(receive(future.msg));
    }
    catch (Err e)
    {
      future.completeErr(e);
    }
  }

  internal Void _kill()
  {
    // get/reset the pending queue
    Queue? queue;
    lock.lock
      queue = Queue();
      this.queue.val.swap(queue)
    lock.unlock

    // cancel all pending messages
    while (true)
    {
      Future? future = queue.get();
      if (future == null) break;
      future.cancel();
    }
  }

  internal static Obj? _safe(Obj? obj)
  {
    if (obj == null) return null
    return obj.toImmutable
  }

//////////////////////////////////////////////////////////////////////////
// coalesce
//////////////////////////////////////////////////////////////////////////

  private Obj? toKey(Obj? obj)
  {
    return toKeyFunc == null ? obj : toKeyFunc.call(obj);
  }

  private Obj? coalesceCall(Obj? orig, Obj? incoming)
  {
    return coalesceFunc == null ? incoming : coalesceFunc.call(orig, incoming);
  }

  private Void updateCoalesce(ActorFuture incoming) {
    if (coalesceMap != null) {
      Obj? key = toKey(incoming.msg);
      if (key == null) return;
      coalesceMap.val[key] = incoming
    }
  }

  private ActorFuture? coalesce(ActorFuture incoming) {
      if (coalesceMap == null) return null
      Obj? key = toKey(incoming.msg);
      if (key == null) return null;

      ActorFuture? orig = coalesceMap.val.get(key);
      if (orig == null) return null;

      orig.msg = coalesceCall(orig.msg, incoming.msg);
      return orig;
  }

//////////////////////////////////////////////////////////////////////////
// Diagnostics
//////////////////////////////////////////////////////////////////////////

  // NOTE: these methods are marked as NoDoc, they are provided for
  // low level access to monitor the actor, but they are subject to change.

  **
  ** Return debug string for the current state of this actor:
  **   - idle: no messages queued
  **   - running: currently assigned a thread and processing messages
  **   - pending: messages are queued and waiting for thread
  **
  @NoDoc Str threadState() {
    if (curMsg.val != idleMsg) return "running";
    if (submitted.val) return "pending";
    return "idle";
  }

  **
  ** Get the current number of messages pending on the message queue.
  **
  @NoDoc Int queueSize() { queue.val.size }

  **
  ** Get the peak number of messages queued.
  **
  @NoDoc Int queuePeak() { queue.val.peak }

  **
  ** Get the total number of messages processed by receive method.
  **
  @NoDoc Int receiveCount() { _receiveCount.val }

  **
  ** Get the total number of nanosecond ticks spent in the receive
  ** method processing messages.  Note that this value might lag until
  ** the actor yields it thread.
  **
  @NoDoc Int receiveTicks() { _receiveTicks.val }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  **
  ** Put the currently executing actor thread to sleep for the
  ** specified period.  If the thread is interrupted for any
  ** reason while sleeping, then InterruptedErr is thrown.
  **
  static Void sleep(Duration duration) { Thread.sleep(duration) }

  **
  ** Return the map of "global" variables visibile only to the current
  ** actor (similar to how thread locals work in Java).  These variables
  ** are keyed by a string name - by convention use a dotted notation
  ** beginning with your pod name to avoid naming collisions.
  **
  static [Str:Obj?] locals() {
    d := threadLocal.get
    if (d == null) {
      d = [:]
      threadLocal.set(d)
    }
    return d
  }

}

internal class Context
{
  new make(Actor actor) { this.actor = actor; }
  Actor actor;
  Map locals = Map.make();
  Locale locale = Locale.cur();
}

internal class Queue
{
  public ActorFuture? get()
  {
    if (head == null) return null;
    ActorFuture f = head;
    head = f.next;
    if (head == null) tail = null;
    f.next = null;
    size--;
    return f;
  }

  Void add(ActorFuture f)
  {
    if (f.next != null) {
      e := ArgErr("already in queue: $f").trace
      throw e
    }
    if (tail == null) { head = tail = f; f.next = null; }
    else { tail.next = f; tail = f; }
    size++;
    if (size > peak) peak = size;
  }

  Void dump(OutStream out)
  {
    Int num = 0;
    Int max = 50;
    for (ActorFuture? x = head; x != null; x = x.next)
    {
      if (num < max) out.print("  ").printLine(x.msg);
      num++;
    }
    if (num > max) out.print("  " + (num-max) + " more messages...");
  }

  Void swap(Queue that) {
    h := head
    t := tail
    s := size
    p := peak
    head = that.head
    tail = that.tail
    size = that.size
    peak = that.peak
    that.head = h
    that.tail = t
    that.size = s
    that.peak = p
  }

  ActorFuture? head
  ActorFuture? tail;
  Int size;
  Int peak;
}
