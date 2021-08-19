//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   9 Jul 09  Andy Frank  Creation
//

using compilerx

**
** JsType
**
class JsType : JsNode
{
  new make(JsCompilerSupport s, TypeDef def) : super(s)
  {
    this.def         = def
    this.base        = def.base == null ? null : JsTypeRef(s, def.base, def.loc)
    this.qname       = qnameToJs(def.asRef)
    this.pod         = def.pod.name
    this.name        = def.name
    this.sig         = def.signature
    this.flags       = def.flags
    this.peer        = findPeer(s, def.asRef)
    this.isNative    = def.isNative || def.hasFacet("sys::JsNative")
    this.hasNatives  = null != def.slots.find |n| { n.isNative && n.parent.qname == def.qname }
    this.isMixin     = def.isMixin
    this.isSynthetic = def.isSynthetic
    this.facets      = def.facets?.map |f| { JsFacet(s, f) } ?: [,]
    this.mixins      = def.mixins.map |r| { JsTypeRef(s, r, def.loc) }
    this.fields      = def.fieldDefs.map |f| { JsField(s, f) }
    if (def.staticInit != null) this.staticInit = def.staticInit.name

    this.methods = JsMethod[,]
    def.methodDefs.each |m|
    {
      if (m.isInstanceInit) instanceInit = JsBlock(s, m.code)
      else this.methods.add(JsMethod(s, m))
    }
  }

  override CTypeDef? node() { super.node }

  static JsTypeRef? findPeer(JsCompilerSupport cs, CType def)
  {
    CType? t := def
    while (t != null)
    {
      slot := t.slots.find |s| { s.isNative && s.parent.qname == t.qname }
      if (slot != null)
        return JsTypeRef(cs, slot.parent.asRef, def is CNode ? ((CNode)def).loc : null)
      t = t.base
    }
    return null
  }

  override Void write(JsWriter out)
  {
    loc := def.loc

    // class/mixin
    if (isMixin) out.w("${qname} = function() {}", loc).nl
    else out.w("${qname} = fan.sys.Obj.\$extend($base.qname);", loc).nl
    mixins.each |m| { copyMixin(m, out) }

    // ctor
    out.w("${qname}.prototype.\$ctor = function()", loc).nl
    out.w("{").nl
    out.indent
    out.w("${base.qname}.prototype.\$ctor.call(this);", loc).nl
    if (peer != null) out.w("this.peer = new ${peer.qname}Peer(this);", loc).nl
    out.w("var \$this = this;", loc).nl
    instanceInit?.write(out)
    out.unindent
    out.w("}").nl

    // type
    if (!isSynthetic)
      out.w("${qname}.prototype.\$typeof = function() { return ${qname}.\$type; }", loc).nl

    // slots
    methods.each |m| { m.write(out) }
    fields.each |f| { f.write(out) }
  }

  // see JsPod.write
  Void writeStatic(JsWriter out)
  {
    // static inits
    if (staticInit != null)
      out.w("${qname}.static\$init();").nl
  }

  Void copyMixin(JsTypeRef ref, JsWriter out)
  {
    ref.slots.each |s|
    {
      if (s.parent == "fan.sys.Obj") return
      if (s.isAbstract) return
      if (s.isStatic) return
      //if (overrides(s)) return

      if (!s.isPrivate)
      {
        // check if this mixin's slot was resolved by the compiler as the implementation
        // for the corresponding slot on the this JsType
        resolved := def.slots.find { it.qname == s.cslot.qname }
        if (resolved == null) return
      }

      // use mixin implementation
      out.w("${qname}.prototype.${s.name} = ${s.parent}.prototype.${s.name};").nl
    }
  }

  override Str toStr() { sig }

  ** Return true if type is javascript safe
  static Bool isJsSafe(CType ctype)
  {
    if (ctype.typeDef.facetAnno("sys::NoJs") != null) return false
    if (ctype.podName == "sys" || ctype.isSynthetic || ctype.typeDef.facetAnno("sys::Js") != null) return true
    if (ctype.typeDef.pod.compileJs) return true
    return false
  }

  TypeDef def            // compiler TypeDef
  JsTypeRef? base        // base type qname
  Str qname              // type qname
  Str pod                // pod name for type
  Str name               // simple type name
  Str sig                // full type signature
  Int flags              // flags
  Bool isMixin           // is this type a mixin
  Bool isSynthetic       // is type synthetic
  JsTypeRef? peer        // peer type if has one
  Bool isNative          // is this a full native class
  Bool hasNatives        // does type have any native slots directly
  JsFacet[] facets       // facets for this type
  JsTypeRef[] mixins     // mixins for this type
  JsMethod[] methods     // methods
  JsField[] fields       // fields
  JsBlock? instanceInit  // instanceInit block
  Str? staticInit        // name of static initializer if has one - see JsPod
}

**************************************************************************
** JsTypeRef
**************************************************************************

**
** JsTypeRef
**
class JsTypeRef : JsNode
{
  static new make(JsCompilerSupport cs, CType ref, Loc loc)
  {
    key := ref.signature
    js  := cs.typeRef[key]
    if (js == null) cs.typeRef[key] = js = JsTypeRef.makePriv(cs, ref, loc)
    return js
  }

  private new makePriv(JsCompilerSupport cs, CType ref, Loc? loc) : super.make(cs)
  {
    this.qname = qnameToJs(ref)
    this.pod   = ref.podName
    this.name  = ref.name
    this.sig   = ref.signature
    this.slots = ref.slots.vals.map |CSlot s->JsSlotRef| { JsSlotRef(cs, s) }
    this.isSynthetic = ref.isSynthetic
    this.isNullable  = ref.isNullable
    this.isList = ref.isList
    this.isParameterized  = ref.isParameterized
    this.isFunc = ref.isFunc
    this.loc = loc

    deref := ref
    if (deref.isList) v = JsTypeRef.make(cs, deref.genericArgs[0], loc)
    if (deref.isMap)
    {
      k = JsTypeRef.make(cs, deref.genericArgs[0], loc)
      v = JsTypeRef.make(cs, deref.genericArgs[1], loc)
    }

    if (!JsType.isJsSafe(ref))
    {
      // TODO FIXIT: warn for now
      //cs.err("Type '$ref.qname' not available in Js", loc)
      cs.warn("Type '$ref.qname' not available in Js", loc)
    }
  }



  override Void write(JsWriter out)
  {
    out.w(qname, loc)
  }

  override Str toStr() { sig }

  Str qname          // qname of type ref
  Str pod            // pod name for type
  Str name           // simple type name
  Str sig            // full type signature
  JsSlotRef[] slots  // slots
  Bool isSynthetic   // is type synthetic
  Bool isNullable    // is type nullable
  Bool isList        // is type a sys::List
  Bool isParameterized    // is type a isParameterized
  Bool isFunc        // is type a sys::Func

  JsTypeRef? k       // only valid for MapType
  JsTypeRef? v       // only valid for ListType, MapType
}
