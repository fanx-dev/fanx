//
// Copyright (c) 2011, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   11 Aug 11  Brian Frank  Creation
//

**
** ApiDocWriter is used to write out an AST definition in
** the Fantom API doc formatted used by compilerDoc.
** See 'compilerDoc::ApiDocParser' for formal definition.
**
class ApiDocWriter
{
  new make(OutStream out) { this.out = out }

  Bool close() { out.close }

//////////////////////////////////////////////////////////////////////////
// Type
//////////////////////////////////////////////////////////////////////////

  This writeType(TypeDef t)
  {
    // name
    w(typePrefix).w(t.name).w("\n")

    // attributes
    writeAttr("base",   encodeBase(t))
    writeAttr("mixins", encodeMixins(t))
    writeAttr("flags",  encodeFlags(t.flags))
    writeAttr("loc",    encodeLoc(t, true))

    // facets
    writeFacets(t.facets)

    // doc
    writeDoc(t)

    // slots
    t.slotDefs.each |slot|
    {
      if (slot.isDocumented) writeSlot(slot)
    }
    return this
  }

//////////////////////////////////////////////////////////////////////////
// Slots
//////////////////////////////////////////////////////////////////////////

  private Void writeSlot(SlotDef s)
  {
    // slot or method specific
    if (s is FieldDef)
      writeFieldStart(s)
    else
      writeMethodStart(s)

    // common attributes
    writeAttr("flags", encodeFlags(s.flags))
    writeAttr("loc",   encodeLoc(s, false))

    // facets
    writeFacets(s.facets)

    // doc
    writeDoc(s)
  }

  private Void writeFieldStart(FieldDef f)
  {
    w(slotPrefix).w(f.name).w(" ").w(f.fieldType.signature)
    if (f.init != null) w(":=").w(encodeExpr(f.init))
    w("\n")

    if (f.setter != null && f.flags.and(protectionMask) != f.setter.flags.and(protectionMask))
      writeAttr("set", encodeFlags(f.setter.flags.and(protectionMask)))
  }

  private Void writeMethodStart(MethodDef m)
  {
    w(slotPrefix).w(m.name).w("(\n")
    m.paramDefs.each |p, i|
    {
      w(p.name).w(" ").w(p.paramType.signature)
      if (p.def != null) w(":=").w(encodeExpr(p.def))
      w("\n")
    }
    w(") ").w(m.returnType.signature).w("\n")
  }

//////////////////////////////////////////////////////////////////////////
// Write Utils
//////////////////////////////////////////////////////////////////////////

  private Void writeAttr(Str name, Obj? val)
  {
    if (val == null) return
    w(name).w("=").w(val.toStr).w("\n")
  }

  private Void writeFacets(FacetDef[]? facets)
  {
    if (facets == null) return
    facets.each |facet| { writeFacet(facet) }
  }

  private Void writeFacet(FacetDef facet)
  {
    w("@").w(facet.type.signature)
    if (!facet.names.isEmpty)
    {
      w("{\n")
      facet.names.each |name, i|
      {
        w(name).w("=").w(encodeExpr(facet.vals[i]))
        w("\n")
      }
      w("}")
    }
    w("\n")
  }

  private Void writeDoc(DefNode node)
  {
    w("\n")
    if (node.doc == null) return
    node.doc.lines.each |line|
    {
      if (line.startsWith(slotPrefix)) w(slotPrefix[0..0])
      w(line).w("\n")
    }
    w("\n")
  }

  This w(Str x) { out.print(x); return this }

//////////////////////////////////////////////////////////////////////////
// Str Encodings
//////////////////////////////////////////////////////////////////////////

  private Str? encodeBase(TypeDef t)
  {
    if (t.isMixin) return null
    s := StrBuf()
    b := t.base
    while (b != null)
    {
      s.join(b.signature)
      b = b.base
    }
    return s.isEmpty ? null : s.toStr
  }

  private Str? encodeMixins(TypeDef t)
  {
    if (t.mixins.isEmpty) return null
    s := StrBuf()
    t.mixins.each |m|
    {
      if (!m.isNoDoc) s.join(m.signature)
    }
    return s.isEmpty ? null : s.toStr
  }

  private Str? encodeLoc(DefNode n, Bool includeFile)
  {
    s := StrBuf()
    if (includeFile) s.add(n.loc.filename)
    if (n.loc.line != null)
    {
      s.add(":").add(n.loc.line)
      if (n.doc != null && n.doc.loc.line != null)
        s.add("/").add(n.doc.loc.line)
    }
    return s.isEmpty ? null : s.toStr
  }

  private static Str encodeExpr(Expr expr)
  {
    // this string must never have a newline since that
    // is how we determine end of expressions in parser
    expr.toDocStr ?: "..."
  }

  private static Str encodeFlags(Int flags)
  {
    s := StrBuf()
    if (flags.and(FConst.Abstract)  != 0) s.join("abstract")
    if (flags.and(FConst.Const)     != 0) s.join("const")
    if (flags.and(FConst.Enum)      != 0) s.join("enum")
    if (flags.and(FConst.Facet)     != 0) s.join("facet")
    if (flags.and(FConst.Final)     != 0) s.join("final")
    if (flags.and(FConst.Internal)  != 0) s.join("internal")
    if (flags.and(FConst.Mixin)     != 0) s.join("mixin")
    if (flags.and(FConst.Native)    != 0) s.join("native")
    if (flags.and(FConst.Override)  != 0) s.join("override")
    if (flags.and(FConst.Private)   != 0) s.join("private")
    if (flags.and(FConst.Protected) != 0) s.join("protected")
    if (flags.and(FConst.Public)    != 0) s.join("public")
    if (flags.and(FConst.Static)    != 0) s.join("static")
    if (flags.and(FConst.Synthetic) != 0) s.join("synthetic")
    if (flags.and(FConst.Virtual)   != 0) s.join("virtual")
    if (flags.and(FConst.Ctor)      != 0) s.join("new")
    if (flags.and(FConst.Extension) != 0) s.join("extesion")
    if (flags.and(FConst.Struct)    != 0) s.join("struct")
    return s.toStr
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private const static Str typePrefix := "== "
  private const static Str slotPrefix := "-- "
  private const static Int protectionMask := (FConst.Public).or(FConst.Protected).or(FConst.Private).or(FConst.Internal)

  OutStream out
}