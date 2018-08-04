//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   12 Feb 10 Brian Frank  Creation
//
package fan.concurrent;

import java.util.concurrent.atomic.AtomicBoolean;

public final class AtomicBoolPeer
{

  public static AtomicBoolPeer make(AtomicBool self)
  {
    return new AtomicBoolPeer();
  }

  public final boolean val(AtomicBool self)
  {
    return val.get();
  }

  public final void val(AtomicBool self, boolean v)
  {
    val.set(v);
  }

  public final boolean getAndSet(AtomicBool self, boolean v)
  {
    return val.getAndSet(v);
  }

  public final boolean compareAndSet(AtomicBool self, boolean expect, boolean update)
  {
    return val.compareAndSet(expect, update);
  }

  private final AtomicBoolean val = new AtomicBoolean();
}