//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   12 Feb 10 Brian Frank  Creation
//
package fan.concurrent;

import java.util.concurrent.atomic.AtomicReference;

import fan.sys.*;

public final class AtomicRefPeer
{

  public static AtomicRefPeer make(AtomicRef self)
  {
    return new AtomicRefPeer();
  }

  public final Object val(AtomicRef self)
  {
    return val.get();
  }

  public final void val(AtomicRef self, Object v)
  {
    if (!FanObj.isImmutable(v)) throw NotImmutableErr.make();
    val.set(v);
  }

  public final Object getAndSet(AtomicRef self, Object v)
  {
    if (!FanObj.isImmutable(v)) throw NotImmutableErr.make();
    return val.getAndSet(v);
  }

  public final boolean compareAndSet(AtomicRef self, Object expect, Object update)
  {
    if (!FanObj.isImmutable(update)) throw NotImmutableErr.make();
    return val.compareAndSet(expect, update);
  }

  private final AtomicReference val = new AtomicReference();
}