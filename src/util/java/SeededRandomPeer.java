//
// Copyright (c) 2011, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   3 Jan 11  Brian Frank  Creation
//
package fan.util;

import fan.sys.*;
import fan.std.*;

public class SeededRandomPeer
{

  public static SeededRandomPeer make(SeededRandom self)
  {
    return new SeededRandomPeer();
  }

  public void init(SeededRandom self)
  {
    rand = new java.util.Random(self.seed);
  }

  public long next(SeededRandom self, Range r)
  {
    return nextRange(rand.nextLong(), r);
  }

  public static long nextRange(long v, Range r)
  {
    if (r == null) return v;
    if (v < 0) v = -v;
    long start = r.start();
    long end   = r.end();
    if (r.inclusive()) ++end;
    if (end <= start) throw ArgErr.make("Range end < start: " + r);
    return start + (v % (end-start));
  }

  public boolean nextBool(SeededRandom self)
  {
    return rand.nextBoolean();
  }

  public double nextFloat(SeededRandom self)
  {
    return rand.nextDouble();
  }

  public Buf nextBuf(SeededRandom self, long size)
  {
    byte[] b = new byte[(int)size];
    rand.nextBytes(b);
    return MemBuf.makeBuf(b);
  }

  java.util.Random rand;
}