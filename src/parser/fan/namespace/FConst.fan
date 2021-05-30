//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   09 Sep 10  Auto-generated by /adm/genfcode.rb
//

**
** FConst provides all the fcode constants
**
mixin FConst
{

//////////////////////////////////////////////////////////////////////////
// Stuff
//////////////////////////////////////////////////////////////////////////

  const static Str FCodeVersion := "1.1.3"

//////////////////////////////////////////////////////////////////////////
// Flags
//////////////////////////////////////////////////////////////////////////

  const static Int Abstract   := 0x00000001
  const static Int Const      := 0x00000002
  const static Int Ctor       := 0x00000004
  const static Int Enum       := 0x00000008
  const static Int Facet      := 0x00000010
  const static Int Final      := 0x00000020
  const static Int Getter     := 0x00000040
  const static Int Internal   := 0x00000080
  const static Int Mixin      := 0x00000100
  const static Int Native     := 0x00000200
  const static Int Override   := 0x00000400
  const static Int Private    := 0x00000800
  const static Int Protected  := 0x00001000
  const static Int Public     := 0x00002000
  const static Int Setter     := 0x00004000
  const static Int Static     := 0x00008000
  const static Int Storage    := 0x00010000
  const static Int Synthetic  := 0x00020000
  const static Int Virtual    := 0x00040000
  const static Int Struct     := 0x00080000
  const static Int Extension  := 0x00100000
  const static Int RuntimeConst:=0x00200000
  const static Int Readonly   := 0x00400000
  const static Int Async      := 0x00800000
  const static Int Overload   := 0x01000000 //imples param default by Overload
  const static Int Closure    := 0x02000000
  const static Int Once       := 0x04000000
  const static Int FlagsMask  := 0x0fffffff
  
//////////////////////////////////////////////////////////////////////////
// Parser Flags
//////////////////////////////////////////////////////////////////////////

  // These are flags used only by the parser we merge with FConst
  // flags by starting from most significant bit and working down
  const static Int Data     := 0x4000_0000

  // Bitwise and this mask to clear all protection scope flags
  const static Int ProtectionMask := (FConst.Public).or(FConst.Protected).or(FConst.Private).or(FConst.Internal).not

//////////////////////////////////////////////////////////////////////////
// MethodVarFlags
//////////////////////////////////////////////////////////////////////////

  const static Int Param := 0x0001  // parameter or local variable
  const static Int ParamDefault:= 0x0002 //the param has default

//////////////////////////////////////////////////////////////////////////
// MethodRefFlags
//////////////////////////////////////////////////////////////////////////
  const static Int RefOverload := 0x0001
  const static Int RefSetter := 0x0002

//////////////////////////////////////////////////////////////////////////
// Attributes
//////////////////////////////////////////////////////////////////////////

  const static Str ErrTableAttr     := "ErrTable"
  const static Str FacetsAttr       := "Facets"
  const static Str LineNumberAttr   := "LineNumber"
  const static Str LineNumbersAttr  := "LineNumbers"
  const static Str SourceFileAttr   := "SourceFile"
  const static Str ParamDefaultAttr := "ParamDefault"
  const static Str EnumOrdinalAttr  := "EnumOrdinal"

}