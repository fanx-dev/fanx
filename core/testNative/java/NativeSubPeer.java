//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   3 Mar 06  Brian Frank  Creation
//
package fan.testNative;

import fan.sys.*;

/**
 * Verify Java native integration
 */
public class NativeSubPeer extends NativePeer
{

  public static NativeSubPeer make(NativeSub t)
  {
    NativeSubPeer peer = new NativeSubPeer();
    ((Native)t).peer = peer; // override base class's peer field
    return peer;
  }

  public void subCheckPeers(NativeSub self)
  {
    if (this != self.peer)
      throw new RuntimeException("this != self.peer");
    if (this != ((Native)self).peer)
      throw new RuntimeException("this != ((Native)self).peer");
  }

  public String subNative(NativeSub self)
  {
    return "subNative working";
  }

  public long subfX(NativeSub self)
  {
    return fX(self);
  }

  public long subGetPeerZ(NativeSub self)
  {
    return getPeerZ(self);
  }

}