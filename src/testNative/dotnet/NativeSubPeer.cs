//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   3 Mar 06  Brian Frank  Creation
//

using Fan.Sys;

namespace Fan.TestNative
{
  /// <summary>
  /// Verify .NET native integration
  /// </summary>
  public class NativeSubPeer : NativePeer
  {

    public static NativeSubPeer make(NativeSub t)
    {
      NativeSubPeer peer = new NativeSubPeer();
      ((Native)t).m_peer = peer; // override base class's peer field
      return peer;
    }

    public void subCheckPeers(NativeSub self)
    {
      if (this != self.m_peer)
        throw new System.Exception("this != self.peer");
      if (this != ((Native)self).m_peer)
        throw new System.Exception("this != ((Native)self).peer");
    }

    public string subNative(NativeSub self)
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
}