//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Aug 06  Brian Frank  Creation
//

**
** FUtil provides fcode encoding and decoding utilities.
**
class FUtil : FConst
{

//////////////////////////////////////////////////////////////////////////
// Buf
//////////////////////////////////////////////////////////////////////////

  static Void writeBuf(OutStream? out, Buf? buf)
  {
    if (buf == null)
    {
      out.writeI2(0)
    }
    else
    {
      out.writeI2(buf.size)
      out.writeBuf(buf.seek(0))
    }
  }

  static Buf? readBuf(InStream in)
  {
    size := in.readU2
    if (size == 0) return null
    return in.readBufFully(null, size)
  }

//////////////////////////////////////////////////////////////////////////
// Attrs
//////////////////////////////////////////////////////////////////////////

  static Void writeAttrs(OutStream out, FAttr[]? fattrs)
  {
    if (fattrs == null)
    {
      out.writeI2(0)
    }
    else
    {
      out.writeI2(fattrs.size)
      fattrs.each |FAttr a| { a.write(out) }
    }
  }

  static FAttr[] readAttrs(InStream in)
  {
    size := in.readU2
    if (size == 0) return FAttr#.emptyList
    fattrs := FAttr[,]
    fattrs.capacity = size
    size.times { fattrs.add(FAttr.make.read(in)) }
    return fattrs
  }

//////////////////////////////////////////////////////////////////////////
// Doc
//////////////////////////////////////////////////////////////////////////

  **
  ** Write a fandoc item to the specified output stream.  The fandoc file
  ** format is an extremely simple plan text format with left justified
  ** type/slot qnames, followed by the fandoc content indented two spaces.
  **
  static Void writeDoc(OutStream out, Str key, Str? doc)
  {
    if (doc == null) return
    out.print(key).print("\n").print("  ")
    doc.each |Int ch|
    {
      if (ch == '\r') throw ArgErr.make
      out.writeChar(ch)
      if (ch == '\n') out.print("  ")
    }
    out.print("\n\n")
  }

}