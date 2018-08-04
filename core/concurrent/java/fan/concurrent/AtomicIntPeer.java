//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   12 Feb 10 Brian Frank  Creation
//
package fan.concurrent;

import java.util.concurrent.atomic.AtomicLong;

public final class AtomicIntPeer
{

  public static AtomicIntPeer make(AtomicInt self)
  {
    return new AtomicIntPeer();
  }

  public final long val(AtomicInt self)
  {
    return val.get();
  }

  public final void val(AtomicInt self, long v)
  {
    val.set(v);
  }

  public final long getAndSet(AtomicInt self, long v)
  {
    return val.getAndSet(v);
  }

  public final boolean compareAndSet(AtomicInt self, long expect, long update)
  {
    return val.compareAndSet(expect, update);
  }

  public final long getAndIncrement(AtomicInt self)
  {
    return val.getAndIncrement();
  }

  public final long getAndDecrement(AtomicInt self)
  {
    return val.getAndDecrement();
  }

  public final long getAndAdd(AtomicInt self, long delta)
  {
    return val.getAndAdd(delta);
  }

  public final long incrementAndGet(AtomicInt self)
  {
    return val.incrementAndGet();
  }

  public final long decrementAndGet(AtomicInt self)
  {
    return val.decrementAndGet();
  }

  public final long addAndGet(AtomicInt self, long delta)
  {
    return val.addAndGet(delta);
  }

  public final void increment(AtomicInt self)
  {
    val.incrementAndGet();
  }

  public final void decrement(AtomicInt self)
  {
    val.decrementAndGet();
  }

  public final void add(AtomicInt self, long delta)
  {
    val.addAndGet(delta);
  }

  private final AtomicLong val = new AtomicLong();
}