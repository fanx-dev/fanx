//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   24 Mar 09  Andy Frank  Creation
//   20 May 09  Andy Frank  Refactor to new OO model
//


fan.sys.FConst = function() {};

//////////////////////////////////////////////////////////////////////////
// Flags
//////////////////////////////////////////////////////////////////////////

fan.sys.FConst.Abstract   = 0x00000001;
fan.sys.FConst.Const      = 0x00000002;
fan.sys.FConst.Ctor       = 0x00000004;
fan.sys.FConst.Enum       = 0x00000008;
fan.sys.FConst.Facet      = 0x00000010;
fan.sys.FConst.Final      = 0x00000020;
fan.sys.FConst.Getter     = 0x00000040;
fan.sys.FConst.Internal   = 0x00000080;
fan.sys.FConst.Mixin      = 0x00000100;
fan.sys.FConst.Native     = 0x00000200;
fan.sys.FConst.Override   = 0x00000400;
fan.sys.FConst.Private    = 0x00000800;
fan.sys.FConst.Protected  = 0x00001000;
fan.sys.FConst.Public     = 0x00002000;
fan.sys.FConst.Setter     = 0x00004000;
fan.sys.FConst.Static     = 0x00008000;
fan.sys.FConst.Storage    = 0x00010000;
fan.sys.FConst.Synthetic  = 0x00020000;
fan.sys.FConst.Virtual    = 0x00040000;
fan.sys.FConst.FlagsMask  = 0x0007ffff;