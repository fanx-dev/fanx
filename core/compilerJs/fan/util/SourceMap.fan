//
// Copyright (c) 2015, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   02 Jul 15  Matthew Giannini  Creation
//

using compiler

class SourceMap
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(JsCompilerSupport support)
  {
    this.support = support
    this.c = support.compiler
  }

//////////////////////////////////////////////////////////////////////////
// SourceMap
//////////////////////////////////////////////////////////////////////////

  This add(Str text, Loc genLoc, Loc srcLoc, Str? name := null)
  {
    // map source
    File? source := files.getOrAdd(srcLoc.file) |->File?| { findSource(srcLoc) }
    if (source == null) return this

    // add map field
    fields.add(MapField(text, genLoc, srcLoc, name))
    return this
  }

  private File? findSource(Loc loc)
  {
    c.srcFiles?.find { it.osPath == File.os(loc.file).osPath }
  }

//////////////////////////////////////////////////////////////////////////
// Output
//////////////////////////////////////////////////////////////////////////

  Void write(OutStream out := Env.cur.out)
  {
    pod := support.pod.name
    out.writeChars("{\n")
    out.writeChars("\"version\": 3,\n")
    out.writeChars("\"file\": \"${pod}.js\",\n")
    out.writeChars("\"sourceRoot\": \"/dev/${pod}/\",\n")
    writeSources(out)
    writeMappings(out)
    out.writeChars("}\n")
    out.flush
  }

  private Void writeSources(OutStream out)
  {
    // write sources
    out.writeChars("\"sources\": [")
    files.vals.each |file, i|
    {
      if (i > 0) out.writeChars(",")
      if (file == null) out.writeChars("null")
      else out.writeChars("\"${file.name}\"")
    }
    out.writeChars("],\n")

  }

  private Void writeMappings(OutStream out)
  {
    // map source index
    srcIdx := [Str:Int][:]
    files.keys.each |k, i| { srcIdx[k] = i }

    out.writeChars("\"mappings\": \"")
    prevFileIdx := 0
    prevSrcLine := 0
    prevSrcCol  := 0
    prevGenLine := 0
    prevGenCol  := 0
    MapField? prevField
    fields.each |MapField f, Int i|
    {
      fileIdx := srcIdx[f.srcLoc.file]
      genLine := f.genLoc.line
      genCol  := f.genLoc.col
      srcLine := f.srcLine
      srcCol  := f.srcCol
      if (genLine < prevGenLine) throw Err("${f} is before line ${prevGenLine}")

      // handle missing/blank lines
      if (genLine != prevGenLine)
      {
        prevGenCol = 0
        while (genLine != prevGenLine)
        {
          out.writeChar(';')
          ++prevGenLine
        }
      }
      else
      {
        if (i > 0)
        {
          if (genCol <= prevGenCol) throw Err("${genCol} is before col ${prevGenCol}")
          out.writeChar(',')
        }
      }

      // calculate diffs
      genColDiff  := genCol - prevGenCol
      fileDiff    := fileIdx - prevFileIdx
      srcLineDiff := srcLine - prevSrcLine
      srcColDiff  := srcCol - prevSrcCol

      // write segment field
      out.writeChars(Base64VLQ.encode(genColDiff))
         .writeChars(Base64VLQ.encode(fileDiff))
         .writeChars(Base64VLQ.encode(srcLineDiff))
         .writeChars(Base64VLQ.encode(srcColDiff))

      // update prev state
      prevGenCol  = genCol
      prevFileIdx = fileIdx
      prevSrcLine = srcLine
      prevSrcCol  = srcCol
    }
    out.writeChars(";\"\n")
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private JsCompilerSupport support
  private Compiler c
  private [Str:File?] files := [Str:File][:] { ordered = true }
  private MapField[] fields := [,]
}

class MapField
{
  new make(Str text, Loc genLoc, Loc srcLoc, Str? name)
  {
    this.text = text
    this.genLoc = genLoc
    this.srcLoc = srcLoc
    this.name = name
  }

  ** zero-indexed line from original source file
  Int srcLine() { srcLoc.line - 1 }
  ** zero-indexed column from original source file
  Int srcCol() { srcLoc.col - 1 }

  override Str toStr()
  {
    "${fname}
        $srcLine, $srcCol
        $genLoc.line, $genLoc.col
        $text
     "
  }

  Str fname()
  {
    i := srcLoc.file.indexr("/")
    return srcLoc.file[i+1..-1]
  }

  Str text
  Loc genLoc
  Loc srcLoc
  Str? name
}
