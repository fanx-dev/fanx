//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Dec 05  Brian Frank  Creation
//   19 Aug 06  Brian Frank  Ported from Java to Fan
//

**
** FPrinter is used to pretty print fcode
**
class FPrinter : FConst
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(FPod pod, OutStream out := Env.cur.out)
  {
    this.pod = pod
    this.out = out
  }

//////////////////////////////////////////////////////////////////////////
// Dump
//////////////////////////////////////////////////////////////////////////

  Void all()
  {
    tables
    ftypes
    out.flush
  }

//////////////////////////////////////////////////////////////////////////
// Const Tables
//////////////////////////////////////////////////////////////////////////

  Void tables()
  {
    printLine("##### Tables #####");
    table("--- names ---",      pod.names)
    table("--- typeRefs ---",   pod.typeRefs)
    table("--- fieldRefs ---",  pod.fieldRefs)
    table("--- methodRefs ---", pod.methodRefs)
    table("--- ints ---",       pod.ints)
    table("--- floats ---",     pod.floats)
    table("--- strs ---",       pod.strs)
    table("--- durations ---",  pod.durations)
    table("--- uris ---",       pod.uris)
    out.flush
  }

  Void table(Str title, FTable table)
  {
    printLine(title)
    table.table.each |Obj obj, Int index|
    {
      s := ""
      if (obj isnot Str) {
         m := obj.typeof.method("format", false)
         s = m != null ? m.callList([obj, pod]) : obj.toStr
      } else {
         s = obj.toStr
      }
      printLine("  [$index]  $s")
    }
  }

//////////////////////////////////////////////////////////////////////////
// Types
//////////////////////////////////////////////////////////////////////////

  Void ftypes()
  {
    printLine("##### Types #####")
    pod.ftypes.each |FType t| { ftype(t) }
    out.flush
  }

  Void ftype(FType t)
  {
    printLine("--" + typeRef(t.self) + " : " + typeRef(t.fbase) + "--")
    if (!t.fmixins.isEmpty)
    {
      printLine("  mixin " + t.fmixins.join(", ") |Int m->Str| { typeRef(m) });
    }
    printLine("<"+t.genericParameters.join(",")+">")
    attrs(t.fattrs)
    printLine
    t.ffields.each |FField f| { field(f) }
    t.fmethods.each |FMethod m| { method(m) }
    out.flush
  }

  Void slot(FSlot s)
  {
    if (s is FField)
      field((FField)s)
    else
      method((FMethod)s)
    out.flush
  }

  Void field(FField f)
  {
    printLine("  " + name(f.nameIndex) + " -> " + typeRef(f.typeRef) + " [" + flags(f.flags) + "]")
    attrs(f.fattrs)
    printLine
  }

  Void method(FMethod m)
  {
    print("  " + name(m.nameIndex) + " (")
    print(m.fparams.join(", ") |FMethodVar p->Str| { typeRef(p.typeRef) + " " + name(p.nameIndex) })
    print(") -> " + typeRef(m.ret))
    if (m.ret != m.inheritedRet) print(" {" + typeRef(m.inheritedRet) + "}")
    printLine(" [" + flags(m.flags) + "]")
    m.vars.each |FMethodVar v, Int reg|
    {
      role := v.isParam ?  "Param" : "Local"
      if (m.flags.and(FConst.Static) == 0) reg++
      printLine("    [" + role + " " + reg + "] " + pod.n(v.nameIndex) + " -> " + typeRef(v.typeRef))
      if (v.hasDefault) code(v.def)
    }
    if (m.code != null)
    {
      printLine("    [Code]")
      code(m.code)
    }
    attrs(m.fattrs)
    printLine
  }

  Void code(Buf code)
  {
    if (!showCode) return;
    out.flush
    codePrinter := FCodePrinter(pod, out)
    codePrinter.showIndex = showIndex
    codePrinter.code(code)
  }

//////////////////////////////////////////////////////////////////////////
// Attributes
//////////////////////////////////////////////////////////////////////////

  Void attrs(FAttr[]? attrs)
  {
    if (attrs == null) return
    attrs.each |FAttr a| { attr(a) }
  }

  Void attr(FAttr attr)
  {
    name := name(attr.name)
    if (name == LineNumbersAttr && !showLines) return
    printLine("    [$name] size=$attr.data.size")
    if (name == SourceFileAttr)  sourceFileAttr(attr)
    if (name == ErrTableAttr)    errTableAttr(attr)
    if (name == LineNumberAttr)  lineNumberAttr(attr)
    if (name == LineNumbersAttr) lineNumbersAttr(attr)
    if (name == FacetsAttr)      facetsAttr(attr)
    if (name == EnumOrdinalAttr) enumOrdinalAttr(attr)
  }

  Void sourceFileAttr(FAttr attr)
  {
    printLine("       $attr.utf")
  }

 Void lineNumberAttr(FAttr attr)
  {
    printLine("       $attr.u2")
  }

  Void facetsAttr(FAttr attr)
  {
    buf := attr.data
    buf.seek(0)
    buf.readU2.times
    {
      type := pod.typeRef(buf.readU2)
      val  := buf.readUtf
      printLine("       @" + (val.isEmpty ? type : val))
    }
  }

 Void enumOrdinalAttr(FAttr attr)
  {
    printLine("       $attr.u2")
  }

  Void errTableAttr(FAttr attr)
  {
    buf := attr.data
    buf.seek(0)
    buf.readU2.times
    {
      start   := buf.readU2
      end     := buf.readU2
      handler := buf.readU2
      tr      := buf.readU2
      printLine("      $start  to $end -> $handler  " + typeRef(tr))
    }
  }

  Void lineNumbersAttr(FAttr attr)
  {
    buf := attr.data
    buf.seek(0)
    buf.readU2.times
    {
      pc   := buf.readU2
      line := buf.readU2
      printLine("       $pc: $line")
    }
  }

//////////////////////////////////////////////////////////////////////////
// Dump Utils
//////////////////////////////////////////////////////////////////////////

  Str typeRef(Int i)
  {
    if (i == 65535) return "null"
    return pod.typeRefStr(i) + index(i)
  }

  Str name(Int i)
  {
    return pod.n(i) + index(i)
  }

  Str flags(Int flags)
  {
    s := StrBuf.make
    if (flags.and(FConst.Abstract)  != 0) s.add("abstract ")
    if (flags.and(FConst.Const)     != 0) s.add("const ")
    if (flags.and(FConst.Ctor)      != 0) s.add("ctor ")
    if (flags.and(FConst.Enum)      != 0) s.add("enum ")
    if (flags.and(FConst.Final)     != 0) s.add("final ")
    if (flags.and(FConst.Getter)    != 0) s.add("getter ")
    if (flags.and(FConst.Internal)  != 0) s.add("internal ")
    if (flags.and(FConst.Mixin)     != 0) s.add("mixin ")
    if (flags.and(FConst.Native)    != 0) s.add("native ")
    if (flags.and(FConst.Override)  != 0) s.add("override ")
    if (flags.and(FConst.Private)   != 0) s.add("private ")
    if (flags.and(FConst.Protected) != 0) s.add("protected ")
    if (flags.and(FConst.Public)    != 0) s.add("public ")
    if (flags.and(FConst.Setter)    != 0) s.add("setter ")
    if (flags.and(FConst.Static)    != 0) s.add("static ")
    if (flags.and(FConst.Storage)   != 0) s.add("storage ")
    if (flags.and(FConst.Synthetic) != 0) s.add("synthetic ")
    if (flags.and(FConst.Virtual)   != 0) s.add("virtual ")
    if (flags.and(FConst.Struct)    != 0) s.add("struct ")
    if (flags.and(FConst.Extension) != 0) s.add("extension ")
    if (flags.and(FConst.RuntimeConst)!= 0) s.add("rtconst ")
    if (flags.and(FConst.Readonly)  != 0) s.add("readonly ")
    if (flags.and(FConst.Async)     != 0) s.add("async ")
    if (flags.and(FConst.Overload)  != 0) s.add("overload ")
    if (flags.and(FConst.Once)  != 0) s.add("once ")
    return s.toStr[0..-2]
  }

  Str index(Int index)
  {
    if (showIndex) return "[" + index + "]"
    return ""
  }

//////////////////////////////////////////////////////////////////////////
// Print
//////////////////////////////////////////////////////////////////////////

  FPrinter print(Obj obj) { out.print(obj); return this }
  FPrinter printLine(Obj obj := "") { out.printLine(obj); return this }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  FPod pod
  OutStream out
  Bool showIndex := false
  Bool showCode  := true
  Bool showLines := false

}