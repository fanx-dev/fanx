//
// Copyright (c) 2007, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   30 Jan 07  Brian Frank  Creation
//   26 Mar 09  Brian Frank  Split from old ThreadTest
//

**
** ActorTest
**
class ActorTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Setup/Teardown
//////////////////////////////////////////////////////////////////////////

  ActorPool pool := ActorPool()

  override Void teardown() { pool.kill }

//////////////////////////////////////////////////////////////////////////
// Make
//////////////////////////////////////////////////////////////////////////

  Void testMake()
  {
    mutable := |Obj? msg->Obj?| { fail; return null }
    verifyErr(ArgErr#) { x := Actor(pool) }
    verifyErr(NotImmutableErr#) { x := Actor(pool, mutable) }

    verifyEq(ActorPool().maxThreads, 100)
    verifyEq(ActorPool { maxThreads = 2 }.maxThreads, 2)
    verifyErr(ArgErr#) { x := ActorPool() { maxThreads = 0 } }
    //verifyErr(ConstErr#) { x := ActorPool(); x.with { maxThreads = 0 } }
  }

//////////////////////////////////////////////////////////////////////////
// Basics
//////////////////////////////////////////////////////////////////////////

  Void testBasics()
  {
    // create actor which increments an Int
    g := ActorPool()
    a := Actor(pool, #incr.func)

    // verify basic identity
    verifyType(g, ActorPool#)
    verifyType(a, Actor#)
    verifySame(a.pool, pool)
    verifyEq(g.isStopped, false)
    verifyEq(g.isDone, false)

    // fire off a bunch of Ints and verify
    futures := Future[,]
    100.times |Int i| { futures.add(a.send(i)) }
    futures.each |Future f, Int i|
    {
      verifyType(f, ActorFuture#)
      verifyEq(f.typeof.base, Future#)
      verifyEq(f.get, i+1)
      verifySame(f.state, FutureState.ok)
      verifyEq(f.get, i+1)
    }
  }

  static Int incr(Int msg)
  {
    return msg+1
  }

//////////////////////////////////////////////////////////////////////////
// Ordering
//////////////////////////////////////////////////////////////////////////

  Void testOrdering()
  {
    // build a bunch actors
    actors := Actor[,]
    200.times { actors.add(Actor(pool, #order.func)) }

    // randomly send increasing ints to the actors
    100_000.times |Int i| { actors[Int.random(0..<actors.size)].send(i) }

    // get the results
    futures := Future[,]
    actors.each |Actor a, Int i| { futures.add(a.send("result-$i")) }

    futures.each |Future f, Int i|
    {
      Int[] r := f.get
      r.each |Int v, Int j| { if (j > 0) verify(v > r[j-1]) }
    }
  }

  static Obj? order(Obj msg)
  {
    Int[]? r := Actor.locals.get("foo")
    if (r == null) Actor.locals.set("foo", r = Int[,])
    if (msg.toStr.startsWith("result")) return r
    r.add(msg)
    return null
  }

//////////////////////////////////////////////////////////////////////////
// Messaging
//////////////////////////////////////////////////////////////////////////

  Void testMessaging()
  {
    a := Actor(pool, #messaging.func)

    // const
    f := a.send("const")
    verifySame(f.get, constObj)
    verifySame(f.get, constObj)
    verifySame(f.state, FutureState.ok)

    // not immutable
    verifyErr(NotImmutableErr#) { a.send(this) }
    verifyErr(NotImmutableErr#) { a.send(SerMsg { i = 123 }) }
    verifyErr(NotImmutableErr#) { a.send("serial").get }
    verifyErr(NotImmutableErr#) { a.send("mutable").get }

    // receive raises error
    f = a.send("throw")
    verifyErr(UnknownServiceErr#) { f.get }
    verifyErr(UnknownServiceErr#) { f.get }
    verifySame(f.state, FutureState.err)
  }

  static Obj? messaging(Str msg)
  {
    switch (msg)
    {
      case "const":   return constObj
      case "serial":  return SerMsg { i = 123 }
      case "throw":   throw UnknownServiceErr()
      case "mutable": return StrBuf()
      default: return "?"
    }
  }
  static const Obj constObj := [1, 2, 3]

//////////////////////////////////////////////////////////////////////////
// Timeout/Cancel
//////////////////////////////////////////////////////////////////////////

  Void testTimeoutCancel()
  {
    a := Actor(pool, #sleep.func)
    f := a.send(1sec)

    // get with timeout
    t1 := Duration.now
    verifyErr(TimeoutErr#) { f.get(50ms) }
    t2 := Duration.now
    verify(t2-t1 < 70ms, (t2-t1).toLocale)

    // launch an actor to cancel the future
    Actor(pool, |msg| {cancel(msg)}).send(f)

    // block on future until canceled
    verifyErr(CancelledErr#) { f.get }
    verifyErr(CancelledErr#) { f.get }
    verifySame(f.state, FutureState.cancelled)
  }

  static Obj? sleep(Obj? msg)
  {
    if (msg is Duration) Actor.sleep(msg)
    return msg
  }

  static Obj? cancel(Future f)
  {
    Actor.sleep(20ms)
    f.cancel
    return f
  }

//////////////////////////////////////////////////////////////////////////
// Stop
//////////////////////////////////////////////////////////////////////////

  Void testStop()
  {
    // launch a bunch of threads which sleep for a random time
    actors := Actor[,]
    durs := Duration[,]
    futures := Future[,]
    scheduled := Future[,]
    20.times |Int i|
    {
      actor := Actor(pool, #sleep.func)
      actors.add(actor)

      // send some dummy messages
      Int.random(100..<1000).times |Int j| { actor.send(j) }

      // send sleep duration 0 to 300ms
      dur := 1ms * Int.random(0..<300).toFloat
      if (i == 0) dur = 300ms
      durs.add(dur)
      futures.add(actor.send(dur))

      // schedule some messages in future well after we stop
      3.times |Int j| { scheduled.add(actor.sendLater(10sec + 1sec * j.toFloat, j)) }
    }

    // still running
    verifyEq(pool.isStopped, false)
    verifyEq(pool.isDone, false)
    verifyErr(Err#) { pool.join }
    verifyErr(Err#) { pool.join(5sec) }

    // join with timeout (depending on the underlying resolution
    // of the system timer and what is happening on the OS, this
    // may fail occasionally)
    t1 := Duration.now
    try { pool.stop.join(100ms) } catch (Err e) { e.trace }
    t2 := Duration.now
    //verify(t2 - t1 <= 140ms)
    verifyEq(pool.isStopped, true)
    //verifyEq(pool.isDone, false)

    // verify can't send or schedule anymore
    actors.each |Actor a|
    {
      verifyErr(Err#) { a.send(10sec) }
      verifyErr(Err#) { a.sendLater(1sec, 1sec) }
    }

    // stop again, join with no timeout
    pool.stop.join
    t2 = Duration.now
    verify(t2 - t1 <= 650ms, (t2-t1).toLocale)
    verifyEq(pool.isStopped, true)
    verifyEq(pool.isDone, true)

    // verify all futures have completed
    futures.each |Future f| { verify(f.state.isComplete) }
    futures.each |Future f, Int i| { verifyEq(f.get, durs[i]) }

    // verify all scheduled messages were canceled
    verifyAllCancelled(scheduled)
  }

  Void verifyAllCancelled(Future[] futures)
  {
    futures.each |Future f|
    {
      if (f.isCancelled == false) echo("err future: $f")
      verifySame(f.state, FutureState.cancelled)
      verifyErr(CancelledErr#) { f.get }
      verifyErr(CancelledErr#) { f.get(200ms) }
    }
  }

//////////////////////////////////////////////////////////////////////////
// Kill
//////////////////////////////////////////////////////////////////////////

  Void testKill()
  {
    // spawn off a bunch of actors and sleep messages
    futures := Future[,]
    durs := Duration[,]
    scheduled := Future[,]
    200.times |->|
    {
      actor := Actor(pool, #sleep.func)

      // send 6x 0ms - 50ms, max 600ms
      12.times |Int i|
      {
        dur := 1ms * Int.random(0..<50).toFloat
        futures.add(actor.send(dur))
        durs.add(dur)
      }

      // schedule some messages in future well after we stop
      scheduled.add(actor.sendLater(3sec, actor))
    }

    verifyEq(pool.isStopped, false)
    verifyEq(pool.isDone, false)

    // kill
    t1 := Duration.now
    pool.kill
    verifyEq(pool.isStopped, true)

    // verify can't send anymore
    verifyErr(Err#) { Actor(pool, #sleep.func).send(10sec) }

    // join
    pool.join
    t2 := Duration.now
    verify(t2-t1 < 150ms, (t2-t1).toLocale)
    verifyEq(pool.isStopped, true)
    verifyEq(pool.isDone, true)

    // verify all futures must now be done one of three ways:
    //  1) completed successfully
    //  2) were interrupted (if running during kill)
    //  3) were cancelled (if pending)
    futures.each |Future f, Int i| { verify(f.state.isComplete, "$i ${durs[i]}") }
    futures.each |Future f, Int i|
    {
      // each future either
      if (f.state == FutureState.cancelled)
      {
        verifyErr(CancelledErr#) { f.get }
      }
      else
      {
        try
          verifyEq(f.get, durs[i])
        catch (InterruptedErr e)
          verifyErr(InterruptedErr#) { f.get }
      }
    }

    // verify all scheduled messages were canceled
    verifyAllCancelled(scheduled)
  }

//////////////////////////////////////////////////////////////////////////
// Later
//////////////////////////////////////////////////////////////////////////
  
  Void testLaterSimple() {
    receive := |Obj? msg->Obj?| { returnNow(msg) }
    Duration now := returnNow(null)
    a := Actor(pool, receive).sendLater(200ms, "dummy")
    Duration t := a.get
    dt := (t - now)
    echo(dt)
    verify(dt > 100ms)
  }

  Void testLater()
  {
    // warm up a threads with dummy requests
    receive := |Obj? msg->Obj?| { returnNow(msg) }
    5.times { Actor(pool, receive).sendLater(10ms, "dummy") }

    start := Duration.now
    x100 := Actor(pool, receive).sendLater(100ms, null)
    x150 := Actor(pool, receive).sendLater(150ms, null)
    x200 := Actor(pool, receive).sendLater(200ms, null)
    x250 := Actor(pool, receive).sendLater(250ms, null)
    x300 := Actor(pool, receive).sendLater(300ms, null)
    verifyLater(start, x100, 100ms)
    verifyLater(start, x150, 150ms)
    verifyLater(start, x200, 200ms)
    verifyLater(start, x250, 250ms)
    verifyLater(start, x300, 300ms)

    start = Duration.now
    x100 = Actor(pool, |msg| {returnNow(msg)}).sendLater(100ms, null)
    verifyLater(start, x100, 100ms)

    start = Duration.now
    x300 = Actor(pool, receive).sendLater(300ms, null)
    x200 = Actor(pool, receive).sendLater(200ms, null)
    x100 = Actor(pool, receive).sendLater(100ms, null)
    x150 = Actor(pool, receive).sendLater(150ms, null)
    x250 = Actor(pool, receive).sendLater(250ms, null)
    verifyLater(start, x100, 100ms)
    verifyLater(start, x150, 150ms)
    verifyLater(start, x200, 200ms)
    verifyLater(start, x250, 250ms)
    verifyLater(start, x300, 300ms)
  }

  Void testLaterRand()
  {
    // warm up a threads with dummy requests
    5.times { Actor(pool, #returnNow.func).sendLater(10ms, "dummy") }

    // schedule a bunch of actors and messages with random times
    start := Duration.now
    actors := Actor[,]
    futures := Future[,]
    durs := Duration?[,]
    5.times |->|
    {
      a := Actor(pool, #returnNow.func)
      10.times |->|
      {
        // schedule something randonly between 0ms and 1sec
        Duration? dur := 1ms * Int.random(0..<1000).toFloat
        f := a.sendLater(dur, dur)

        // cancel some anything over 500ms
        if (dur > 500ms) { f.cancel; dur = null }

        durs.add(dur)
        futures.add(f)
      }
    }

    // verify cancellation or that scheduling was reasonably accurate
    futures.each |Future f, Int i| { verifyLater(start, f, durs[i], 100ms) }
  }

  Void verifyLater(Duration start, Future f, Duration? expected, Duration tolerance := 40ms)
  {
    if (expected == null)
    {
      verifySame(f.state, FutureState.cancelled)
      verifyErr(CancelledErr#) { f.get }
    }
    else
    {
      Duration actual := (Duration)f.get(3sec) - start
      diff := (expected - actual).abs
      // echo("$expected.toLocale != $actual.toLocale ($diff.toLocale)")
      verify(diff < tolerance, "$expected.toLocale != $actual.toLocale ($diff.toLocale)")
    }
  }

  static Obj? returnNow(Obj? msg) { Duration.now }

//////////////////////////////////////////////////////////////////////////
// When Complete
//////////////////////////////////////////////////////////////////////////

  Void testWhenComplete()
  {
    a := Actor(pool, #whenCompleteA.func)
    b := Actor(pool, #whenCompleteB.func)
    c := Actor(pool, #whenCompleteB.func)

    // send/complete normal,error,cancel on a
    a.send(50ms)
    a0 := a.send("start")
    a1 := a.send("throw")
    a2 := a.send("cancel")
    a2.cancel
    verifyEq(a0.get, "start")
    verifyErr(IndexErr#) { a1.get }
    verifyErr(CancelledErr#) { a2.get }

    // send some messages with futures already done
    b0 := b.sendWhenComplete(a0, a0); c0 := c.sendWhenComplete(a0, a0)
    b1 := b.sendWhenComplete(a1, a1); c1 := c.sendWhenComplete(a1, a1)
    b2 := b.sendWhenComplete(a2, a2); c2 := c.sendWhenComplete(a2, a2)

    // get some pending messages sent to a
    a.send(50ms)
    a3 := a.send("foo")
    a4 := a.send("bar")
    a5 := a.send("throw")
    ax := a.send("cancel again")
    a6 := a.send("baz")

    // send some messages with futures not done yet
    b3 := b.sendWhenComplete(a3, a3); c3 := c.sendWhenComplete(a3, a3)
    b4 := b.sendWhenComplete(a4, a4); c4 := c.sendWhenComplete(a4, a4)
    b5 := b.sendWhenComplete(a5, a5); c5 := c.sendWhenComplete(a5, a5)
    bx := b.sendWhenComplete(ax, ax); cx := c.sendWhenComplete(ax, ax)
    b6 := b.sendWhenComplete(a6, a6); c6 := c.sendWhenComplete(a6, a6)

    // cancel ax (this should happen before a3, a4, etc)
    ax.cancel

    // verify
    verifyWhenComplete(b0, c0, "start")
    verifyWhenComplete(b1, c1, "start,IndexErr")
    verifyWhenComplete(b2, c2, "start,IndexErr,CancelledErr")
    verifyWhenComplete(bx, cx, "start,IndexErr,CancelledErr,CancelledErr")
    verifyWhenComplete(b3, c3, "start,IndexErr,CancelledErr,CancelledErr,foo")
    verifyWhenComplete(b4, c4, "start,IndexErr,CancelledErr,CancelledErr,foo,bar")
    verifyWhenComplete(b5, c5, "start,IndexErr,CancelledErr,CancelledErr,foo,bar,IndexErr")
    verifyWhenComplete(b6, c6, "start,IndexErr,CancelledErr,CancelledErr,foo,bar,IndexErr,baz")
  }

  Void verifyWhenComplete(Future b, Future c, Str expected)
  {
    verifyEq(b.get(2sec), expected)
    verifyEq(c.get(2sec), expected)
  }

  static Obj? whenCompleteA(Obj? msg)
  {
    if (msg == "throw") throw IndexErr()
    if (msg is Duration) Actor.sleep(msg)
    return msg
  }

  static Obj? whenCompleteB(Future msg)
  {
    Str x := Actor.locals.get("x", "")
    if (!x.isEmpty) x += ","
    if (!msg.state.isComplete) throw Err("not done yet!")
    try
      x += msg.get.toStr
    catch (Err e)
      x += Type.of(e).name
    Actor.locals["x"] = x
    return x
  }

//////////////////////////////////////////////////////////////////////////
// Coalescing (no funcs)
//////////////////////////////////////////////////////////////////////////

  Void testCoalescing()
  {
    a := Actor.makeCoalescing(pool, null, null, #coalesce.func)
    fstart  := a.send(100ms)

    f1s := Future[,]
    f2s := Future[,]
    f3s := Future[,]
    f4s := Future[,]
    ferr := Future[,]
    fcancel := Future[,]

    f1s.add(a.send("one"))
    fcancel.add(a.send("cancel"))
    f2s.add(a.send("two"))
    f1s.add(a.send("one"))
    f2s.add(a.send("two"))
    f3s.add(a.send("three"))
    ferr.add(a.send("throw"))
    f4s.add(a.send("four"))
    fcancel.add(a.send("cancel"))
    f1s.add(a.send("one"))
    ferr.add(a.send("throw"))
    f4s.add(a.send("four"))
    fcancel.add(a.send("cancel"))
    fcancel.add(a.send("cancel"))
    f3s.add(a.send("three"))
    ferr.add(a.send("throw"))
    ferr.add(a.send("throw"))

    fcancel.first.cancel

    a.send(10ms).get(2sec) // wait until completed

    verifyAllSame(f1s)
    verifyAllSame(f2s)
    verifyAllSame(f3s)
    verifyAllSame(f4s)
    verifyAllSame(ferr)
    verifyAllSame(fcancel)

    f1s.each |Future f| { verify(f.state.isComplete); verifyEq(f.get, ["one"]) }
    f2s.each |Future f| { verify(f.state.isComplete); verifyEq(f.get, ["one", "two"]) }
    f3s.each |Future f| { verify(f.state.isComplete); verifyEq(f.get, ["one", "two", "three"]) }
    f4s.each |Future f| { verify(f.state.isComplete); verifyEq(f.get, ["one", "two", "three", "four"]) }
    ferr.each |Future f| { verify(f.state.isComplete); verifyErr(IndexErr#) { f.get } }
    verifyAllCancelled(fcancel)
  }

  static Obj? coalesce(Obj? msg)
  {
    if (msg is Duration) { Actor.sleep(msg); Actor.locals["msgs"] = Str[,]; return msg }
    if (msg == "throw") throw IndexErr("foo bar")
    Str[] msgs := Actor.locals["msgs"]
    msgs.add(msg)
    return msgs
  }

  Void verifyAllSame(Obj[] list)
  {
    x := list.first
    list.each |Obj y| { verifySame(x, y) }
  }

//////////////////////////////////////////////////////////////////////////
// Coalescing (with funcs)
//////////////////////////////////////////////////////////////////////////

  Void testCoalescingFunc()
  {
    a := Actor.makeCoalescing(pool,
      #coalesceKey.func,
      #coalesceCoalesce.func,
      #coalesceReceive.func)

    fstart  := a.send(100ms)

    f1s := Future[,]
    f2s := Future[,]
    f3s := Future[,]
    ferr := Future[,]
    fcancel := Future[,]

    ferr.add(a.send(["throw"]))
    f1s.add(a.send(["1", 1]))
    f2s.add(a.send(["2", 10]))
    f2s.add(a.send(["2", 20]))
    ferr.add(a.send(["throw"]))
    f2s.add(a.send(["2", 30]))
    fcancel.add(a.send(["cancel"]))
    fcancel.add(a.send(["cancel"]))
    f3s.add(a.send(["3", 100]))
    f1s.add(a.send(["1", 2]))
    f3s.add(a.send(["3", 200]))
    fcancel.add(a.send(["cancel"]))
    ferr.add(a.send(["throw"]))

    fcancel.first.cancel

    a.send(10ms).get(2sec) // wait until completed

    verifyAllSame(f1s)
    verifyAllSame(f2s)
    verifyAllSame(f3s)
    verifyAllSame(ferr)
    verifyAllSame(fcancel)

    f1s.each |Future f| { verify(f.state.isComplete); verifyEq(f.get, ["1", 1, 2]) }
    f2s.each |Future f| { verify(f.state.isComplete); verifyEq(f.get, ["2", 10, 20, 30]) }
    f3s.each |Future f| { verify(f.state.isComplete); verifyEq(f.get, ["3", 100, 200]) }
    ferr.each |Future f| { verify(f.state.isComplete); verifyErr(IndexErr#) { f.get } }
    verifyAllCancelled(fcancel)
  }

  static Obj? coalesceKey(Obj? msg)
  {
    msg is List ? msg->get(0): null
  }

  static Obj? coalesceCoalesce(Obj[] a, Obj[] b)
  {
    Obj[,].add(a[0]).addAll(a[1..-1]).addAll(b[1..-1])
  }

  static Obj? coalesceReceive(Obj? msg)
  {
    if (msg is Duration) { Actor.sleep(msg); return msg }
    if (msg->first == "throw") throw IndexErr("foo bar")
    return msg
  }

//////////////////////////////////////////////////////////////////////////
// Locals
//////////////////////////////////////////////////////////////////////////

  Void testLocals()
  {
    // schedule a bunch of actors (more than thread pool)
    actors := Actor[,]
    locales := Locale[,]
    localesPool := [Locale("en-US"), Locale("en-UK"), Locale("fr"), Locale("ja")]
    300.times |Int i|
    {
      locale := localesPool[Int.random(0..<localesPool.size)]
      actors.add(Actor(pool, |msg| { locals(i, locale, msg) }))
      locales.add(locale)
      actors.last.send("bar")
    }

    actors.each |Actor a, Int i|
    {
      verifyEq(a.send("foo").get, "$i " + locales[i])
    }
  }

  static Obj? locals(Int num, Locale locale, Obj? msg)
  {
    // first time thru
    if (Actor.locals["testLocal"] == null)
    {
      Actor.locals["testLocal"] = num
      Locale.setCur(locale)
    }

    return Actor.locals["testLocal"].toStr + " " + Locale.cur
  }

//////////////////////////////////////////////////////////////////////////
// Futures
//////////////////////////////////////////////////////////////////////////

  Void testFuture()
  {
    f := Future.makeCompletable
    verifyEq(f.state, FutureState.pending)
    verifySame(f.typeof, ActorFuture#)
    verifySame(f.typeof.base, Future#)

    // can only complete with immutable value
    verifyErr(NotImmutableErr#) { f.complete(this) }
    verifySame(f.state, FutureState.pending)

    // verify complete
    f.complete("done!")
    verifySame(f.state, FutureState.ok)
    verifyEq(f.get, "done!")

    // can only complete once
    verifyErr(Err#) { f.complete("no!") }
    verifyErr(Err#) { f.completeErr(Err()) }
    verifySame(f.state, FutureState.ok)
    verifyEq(f.get, "done!")

    // verify completeErr
    f = Future.makeCompletable
    verifyEq(f.state, FutureState.pending)
    err := CastErr()
    f.completeErr(err)
    verifySame(f.state, FutureState.err)
    verifyErr(CastErr#) { f.get }
    verifyErr(Err#) { f.complete("no!") }
    verifyErr(Err#) { f.completeErr(Err()) }
    verifySame(f.state, FutureState.err)
    verifyErr(CastErr#) { f.get }

    // verify cancel;
    f = Future.makeCompletable
    f.cancel
    verifySame(f.state, FutureState.cancelled)
    verifyErr(CancelledErr#) { f.get }
    f.complete("no!")
    f.completeErr(IOErr())
    verifySame(f.state, FutureState.cancelled)
    verifyErr(CancelledErr#) { f.get }
  }

//////////////////////////////////////////////////////////////////////////
// WaitFor
//////////////////////////////////////////////////////////////////////////

  Void testFutureWaitFor()
  {
    pool := ActorPool()
    a := spawnSleeper(pool)

    // wait => ok
    f := a.send(100ms)
    verifySame(f.state, FutureState.pending)
    f.waitFor
    verifySame(f.state, FutureState.ok)
    verifyEq(f.get, 100ms)
    f.waitFor
    f.waitFor(1min)

    // wait => error
    f = a.send(66ms)
    verifySame(f.state, FutureState.pending)
    f.waitFor(1min)
    verifySame(f.state, FutureState.err)
    verifyErr(UnsupportedErr#) { f.get }

    // wait => cancel
    f = a.send(3min)
    verifySame(f.state, FutureState.pending)
    f.cancel
    f.waitFor
    verifySame(f.state, FutureState.cancelled)
    verifyErr(CancelledErr#) { f.get }

    // wait  timeout
    f = a.send(1min)
    verifyErr(TimeoutErr#) { f.waitFor(100ms) }
    verifySame(f.state, FutureState.pending)

    // waitAll
    t1 := Duration.now
    f1 := spawnSleeper(pool).send(200ms)
    f2 := spawnSleeper(pool).send(300ms)
    f3 := spawnSleeper(pool).send(100ms)
    f4 := spawnSleeper(pool).send(50ms)
    Future.waitForAll([f1, f2, f3, f4])
    t2 := Duration.now
    dur := t2 - t1
    fudge := 25ms
    verify(300ms <= dur && dur <= 300ms+fudge)

    // waitAll w/ timeout
    t1 = Duration.now
    f1 = spawnSleeper(pool).send(200ms)
    f2 = spawnSleeper(pool).send(50ms)
    f3 = spawnSleeper(pool).send(300ms)
    f4 = spawnSleeper(pool).send(100ms)
    verifyErr(TimeoutErr#) { Future.waitForAll([f1, f2, f3, f4], 250ms) }
    t2 = Duration.now
    dur = t2 - t1
    verify(250ms <= dur && dur <= 250ms+fudge)
  }

  Actor spawnSleeper(ActorPool pool)
  {
    Actor(pool) |msg|
    {
      Actor.sleep(msg);
      if (msg == 66ms) throw UnsupportedErr("bad!")
      return msg
    }
  }

//////////////////////////////////////////////////////////////////////////
// Yields
//////////////////////////////////////////////////////////////////////////

  Void testYields()
  {
    pool := ActorPool { maxThreads = 1; maxTimeBeforeYield = 100ms }
    a := Actor(pool) |msg| { Actor.sleep(50ms); return msg }
    verifyEq(a.threadState, "idle")
    5.times |i| { a.send(null) }

    b := Actor(pool) |msg| { "ret: $msg" }
    t1 := Duration.now
    f := b.send("x")
    Actor.sleep(20ms)
    verifyEq(a.threadState, "running")
    verifyEq(b.threadState, "pending")
    verifyEq(f.get, "ret: x")
    t2 := Duration.now
    verify(t2 - t1 < 150ms)
  }

//////////////////////////////////////////////////////////////////////////
// Balance
//////////////////////////////////////////////////////////////////////////

  Void testBalance()
  {
    pool := ActorPool {}
    a := Actor(pool) |msg| { if (msg != "start") Actor.sleep(300ms); return msg }
    b := Actor(pool) |msg| { if (msg != "start") Actor.sleep(300ms); return msg }
    c := Actor(pool) |msg| { if (msg != "start") Actor.sleep(300ms); return msg }
    d := Actor(pool) |msg| { if (msg != "start") Actor.sleep(300ms); return msg }
    e := Actor(pool) |msg| { return msg }

    a.send("start").get; 4.times |x| { a.send(x) }
    b.send("start").get; 3.times |x| { b.send(x) }
    c.send("start").get; 5.times |x| { c.send(x) }
    d.send("start").get; 3.times |x| { d.send(x) }

    Actor.sleep(5ms)

    verifyEq(a.queueSize, 3)
    verifyEq(b.queueSize, 2)
    verifyEq(c.queueSize, 4)
    verifyEq(d.queueSize, 2)
    verifyEq(e.queueSize, 0)

    verifySame(pool.balance([a]), a)
    verifySame(pool.balance([e]), e)
    verifySame(pool.balance([a, b]), b)
    verifySame(pool.balance([a, b, c]), b)
    verifySame(pool.balance([c, a, b]), b)
    verifySame(pool.balance([c, d, a, b]), d)
    verifySame(pool.balance([a, b, c, d]), b)
    verifySame(pool.balance([d, c, b, a]), d)
    verifySame(pool.balance([e, d, c, b, a]), e)
    verifySame(pool.balance([a, b, c, d, e]), e)
    verifySame(pool.balance([a, b, e, c, d]), e)

    verifyErr(IndexErr#) { pool.balance(Actor[,]) }
  }

//////////////////////////////////////////////////////////////////////////
// Diagnostics
//////////////////////////////////////////////////////////////////////////

  Void testDiagnostics()
  {
    pool := ActorPool {}
    a := Actor(pool) |msg| { Actor.sleep(msg); return msg }
    verifyDiagnostics(a, 0, 0, 0, 0ms)
    a.send(100ms)
    a.send(100ms)
    Actor.sleep(10ms)
    verifyDiagnostics(a, 1, 2, 1, 0ms)
    Actor.sleep(250ms)
    verifyDiagnostics(a, 0, 2, 2, 200ms)
  }

  private Void verifyDiagnostics(Actor a, Int queueSize, Int queuePeak, Int receiveCount, Duration receiveTicks)
  {
    verifyEq(a.queueSize,    queueSize)
    verifyEq(a.queuePeak,    queuePeak)
    verifyEq(a.receiveCount, receiveCount)
    diff := Duration.fromNanos((receiveTicks.toNanos - a.receiveTicks).abs)
    verify(diff < 50ms)
  }
}

**************************************************************************
** SerA
**************************************************************************

@Serializable
internal class SerMsg
{
  override Int hash() { i }
  override Bool equals(Obj? that) { that is SerMsg && i == that->i }
  Int i := 7
}


