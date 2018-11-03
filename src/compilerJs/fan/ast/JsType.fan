//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   9 Jul 09  Andy Frank  Creation
//

using compiler

**
** JsType
**
class JsType : JsNode
{
  new make(JsCompilerSupport s, TypeDef def) : super(s)
  {
    this.def         = def
    this.base        = JsTypeRef(s, def.base, def.loc)
    this.qname       = qnameToJs(def)
    this.pod         = def.pod.name
    this.name        = def.name
    this.sig         = def.signature
    this.flags       = def.flags
    this.peer        = findPeer(s, def)
    this.isNative    = def.isNative
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

  override TypeDef? node() { super.node }

  static JsTypeRef? findPeer(JsCompilerSupport cs, CType def)
  {
    CType? t := def
    while (t != null)
    {
      slot := t.slots.find |s| { s.isNative && s.parent.qname == t.qname }
      if (slot != null)
        return JsTypeRef(cs, slot.parent, def is Node ? ((Node)def).loc : null)
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
      if (overrides(s)) return
      out.w("${qname}.prototype.${s.name} = ${s.parent}.prototype.${s.name};").nl
    }
  }

  Bool overrides(JsSlotRef ref)
  {
    v := methods.find |m| { m.name == ref.name }
    return v != null
  }

  override Str toStr() { sig }

  ** Return true if type is javascript safe
  static Bool isJsSafe(CType ctype)
  {
    if (ctype.facet("sys::NoJs") != null) return false
    // TODO FIXIT: don't check sys yet
    //ctype.pod.name == "sys" || ctype.isSynthetic || ctype.facet("sys::Js") != null
    return true
  }

  TypeDef def            // compiler TypeDef
  JsTypeRef base         // base type qname
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
    this.pod   = ref.pod.name
    this.name  = ref.name
    this.sig   = ref.signature
    this.slots = ref.slots.vals.map |CSlot s->JsSlotRef| { JsSlotRef(cs, s) }
    this.isSynthetic = ref.isSynthetic
    this.isNullable  = ref.isNullable
    this.isList = ref.isList
    this.isMap  = ref.isMap
    this.isFunc = ref.isFunc
    this.loc = loc

    deref := ref.deref
    if (deref is ListType) v = JsTypeRef.make(cs, deref->v, loc)
    if (deref is MapType)
    {
      k = JsTypeRef.make(cs, deref->k, loc)
      v = JsTypeRef.make(cs, deref->v, loc)
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
  Bool isMap         // is type a sys::Map
  Bool isFunc        // is type a sys::Func

  JsTypeRef? k       // only valid for MapType
  JsTypeRef? v       // only valid for ListType, MapType
}
