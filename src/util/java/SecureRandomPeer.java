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

public class SecureRandomPeer extends SeededRandomPeer
{

  public static SecureRandomPeer make(SecureRandom self)
  {
    return new SecureRandomPeer();
  }

  public void init(SecureRandom self)
  {
    rand = new java.security.SecureRandom();
  }

  public long next(SecureRandom self, Range r)
  {
    return SeededRandomPeer.nextRange(rand.nextLong(), r);
  }

  public boolean nextBool(SecureRandom self)
  {
    return rand.nextBoolean();
  }

  public double nextFloat(SecureRandom self)
  {
    return rand.nextDouble();
  }

  public Buf nextBuf(SecureRandom self, long size)
  {
    byte[] b = new byte[(int)size];
    rand.nextBytes(b);
    return MemBuf.makeBuf(b);
  }

  java.util.Random rand;

}