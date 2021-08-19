//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   9 Jul 09  Andy Frank  Creation
//

using compilerx

**
** JsWriter.
**
class JsWriter
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Make for specified output stream
  **
  new make(OutStream out)
  {
    this.out = out
  }

  new makeSourceMap(OutStream out, SourceMap sourcemap)
  {
    this.out = out
    this.sourcemap = sourcemap
  }

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  **
  ** Write and then return this. If loc is not null, the text will be
  ** added to the generated source map.
  **
  JsWriter w(Obj o, Loc? loc := null, Str? name := null)
  {
    if (needIndent)
    {
      spaces := indentation * 2
      out.writeChars(Str.spaces(spaces))
      col += spaces
      needIndent = false
    }
    str := o.toStr
    if (str.containsChar('\n')) throw Err("w str with newline: ${str}")
    if (loc != null)
    {
      sourcemap?.add(str, Loc(loc.file, line, col), loc, name)
    }
    out.writeChars(str)
    col += str.size
    return this
  }

  JsWriter sig(JsMethodParam[] pars)
  {
    w("(")
    pars.each |p,i|
    {
      if (i > 0) w(",")
      p.write(this)
    }
    w(")")
    return this
  }

  **
  ** Write newline and then return this.
  **
  public JsWriter nl()
  {
    out.writeChar('\n')
    ++line
    col = 0
    needIndent = true
    out.flush
    return this
  }

  **
  ** Increment the indentation.
  **
  JsWriter indent()
  {
    indentation++
    return this
  }

  **
  ** Decrement the indentation.
  **
  JsWriter unindent()
  {
    indentation--
    if (indentation < 0) indentation = 0
    return this
  }

//////////////////////////////////////////////////////////////////////////
// Minify
//////////////////////////////////////////////////////////////////////////

  **
  ** Write the minified content of the InSteam.
  **
  Void minify(InStream in)
  {
    inBlock := false
    in.readAllLines.each |line|
    {
      // TODO: temp hack for inlining already minified js
      if (line.size > 1024) { w(line).nl; return }

      s := line
      // line comments
      if (s.size > 1 && (s[0] == '/' && s[1] == '/')) return
// need to check if inside str
//      i := s.index("//")
//      if (i != null) s = s[0..<i]
      // block comments
      temp := s
      a := temp.index("/*")
      if (a != null)
      {
        s = temp[0..<a]
        inBlock = true
      }
      if (inBlock)
      {
        b := temp.index("*/")
        if (b != null)
        {
          s = (a == null) ? temp[b+2..-1] : s + temp[b+2..-1]
          inBlock = false
        }
      }
      // trim and print
      s = s.trimEnd
      if (inBlock) return
      if (s.size == 0) return
      w(s).nl
    }
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private OutStream out
  SourceMap? sourcemap
  Int indentation := 0
  Bool needIndent := false
  Int line := 0
  Int col  := 0

}
