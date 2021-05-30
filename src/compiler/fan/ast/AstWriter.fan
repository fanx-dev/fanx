//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Sep 05  Brian Frank  Creation
//   24 Jun 06  Brian Frank  Ported from Java to Fan
//

**
** AstWriter
**
class AstWriter
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Make for specified output stream
  **
  new make(OutStream out := Env.cur.out)
  {
    this.out = out
  }

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  **
  ** Write and then return this.
  **
  AstWriter w(Obj o)
  {
    if (needIndent)
    {
      out.writeChars(Str.spaces(indentation*2))
      needIndent = false
    }
    out.writeChars(o.toStr)
    return this
  }

  **
  ** Write newline and then return this.
  **
  public AstWriter nl()
  {
    w("\n")
    needIndent = true
    out.flush
    return this
  }

  **
  ** Increment the indentation
  **
  AstWriter indent()
  {
    indentation++
    return this
  }

  **
  ** Decrement the indentation
  **
  AstWriter unindent()
  {
    indentation--
    if (indentation < 0) indentation = 0
    return this
  }

  **
  ** Write the source code for the mask of flags with a trailing space.
  **
  AstWriter flags(Int flags)
  {
    if (flags.and(FConst.Public)    != 0) w("public ")
    if (flags.and(FConst.Protected) != 0) w("protected ")
    if (flags.and(FConst.Private)   != 0) w("private ")
    if (flags.and(FConst.Internal)  != 0) w("internal ")
    if (flags.and(FConst.Native)    != 0) w("native ")
    if (flags.and(FConst.Enum)      != 0) w("enum ")
    if (flags.and(FConst.Mixin)     != 0) w("mixin ")
    if (flags.and(FConst.Final)     != 0) w("final ")
    if (flags.and(FConst.Ctor)      != 0) w("new ")
    if (flags.and(FConst.Override)  != 0) w("override ")
    if (flags.and(FConst.Abstract)  != 0) w("abstract ")
    if (flags.and(FConst.Static)    != 0) w("static ")
    if (flags.and(FConst.Storage)   != 0) w("storage ")
    if (flags.and(FConst.Virtual)   != 0) w("virtual ")
    if (flags.and(FConst.Struct)    != 0) w("struct ")
    if (flags.and(FConst.Extension) != 0) w("extension ")

    if (flags.and(FConst.Synthetic) != 0) w("synthetic ")
    if (flags.and(FConst.Getter)    != 0) w("getter ")
    if (flags.and(FConst.Setter)    != 0) w("setter ")
    if (flags.and(FConst.Once)      != 0) w("once ")
    return this
  }

  static Str flagsToStr(Int flags)
  {
    s := StrBuf()
    w := AstWriter(s.out).flags(flags)
    return s.toStr
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  OutStream out
  Int indentation := 0
  Bool needIndent := false

}