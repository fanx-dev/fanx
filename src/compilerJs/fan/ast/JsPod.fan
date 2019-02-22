//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   10 Jul 09  Andy Frank  Creation
//

using compiler

**
** JsPod
**
class JsPod : JsNode
{
  new make(JsCompilerSupport s, PodDef pod, TypeDef[] defs) : super(s)
  {
    this.name  = pod.name
    this.meta  = pod.meta
    this.types = JsType[,]
    this.props = JsProps[,]

    // build native map
    this.natives = Str:File[:]
    s.compiler.jsFiles?.each |f| { natives[f.name] = f }
    jsOutput := s.compiler.input.output === CompilerOutputMode.js

    defs.each |TypeDef def|
    {
      // we inline closures directly, so no need to generate
      // anonymous types like we do in Java and .NET
      if (def.isClosure) return

      // TODO FIXIT: do we still need this?
      if (def.qname.contains("\$Cvars"))
      {
        echo("WARN: Cvar class: $def.qname")
        return
      }

      // check for @js facet or explicit js output
      if (def.hasFacet("sys::Js"))
        types.add(JsType(s,def))
      
      if ((s.compiler.input.compileJs || jsOutput) && !def.hasFacet("sys::NoJs")) {
        types.add(JsType(s,def))
      }
    }

    // resource files
    baseDir := s.compiler.input.baseDir
    if (baseDir != null)
    {
      s.compiler.resFiles.each |file|
      {
        if (file.ext != "props") return
        uri := file.uri.relTo(baseDir.uri)
        props.add(JsProps(pod, file, uri, s))
      }
    }
  }

  override Void write(JsWriter out)
  {
    // define namespace
    writeNs(out, this.name)

    // write types
    types.each |t|
    {
      if (t.isNative) writePeer(out, t, false)
      else
      {
        t.write(out)
        if (t.hasNatives) writePeer(out, t, true)
      }
    }

    userInit := natives["staticInit.js"]
    if (userInit != null) {
      in := userInit.in
      out.minify(in)
      in.close
      natives.remove("staticInit.js")
    }

    //---------------------------
    //init reflect info
    out.w("fan.${this.name}.initReflect\$ = function() {").nl
    out.indent

    // write type info
    writeTypeInfo(out)

    // write props resource files
    props.each |p| { p.write(out) }

    // write closure fields (must be after writeTypeInfo)
    writeClosureFields(out)

    out.unindent
    out.w("}").nl

    //---------------------------
    //init static
    out.w("fan.${this.name}.initStatic\$ = function() {").nl
    out.indent
    // write static init
    types.each |t| { if (!t.isNative) t.writeStatic(out) }
    out.unindent
    out.w("}").nl

    //---------------------------

    if (name == "std") {
      out.w("fan.sys.initReflect\$();").nl
      out.w("fan.sys.initStatic\$();").nl

      out.w("fan.${this.name}.initReflect\$();").nl
      out.w("fan.${this.name}.initStatic\$();").nl
    }
    else if (name != "sys") {
      out.w("fan.${this.name}.initReflect\$();").nl
      out.w("fan.${this.name}.initStatic\$();").nl
    }

    //---------------------------
    // write remaining natives
    natives.each |f|
    {
      in := f.in
      out.minify(in)
      in.close
    }
    out.w("}).call(this);").nl
    
    out.w("//# sourceMappingURL=/pod/${name}/${name}.js.map").nl
  }

  static Void writeNs(JsWriter out, Str name)
  {
    ns := "(function () {
           ${requireSys}
           if (typeof exports !== 'undefined') {
             fan.$name = exports;
           } else {
             fan.$name = root.fan.$name = {};
           }
           "
    ns.splitLines.each { out.w(it).nl }
  }

  static const Str requireSys :=
    "var root=this;
     var fan=root.fan;
     if (fan === undefined) {
        if (typeof exports !== 'undefined') {
          fan = exports;
        } else {
          fan = root.fan = {};
        }
     }
     if (!fan.sys && (typeof require !== 'undefined')) fan = require('sys.js');
     "

  Void writePeer(JsWriter out, JsType t, Bool isPeer)
  {
    key  := isPeer ? "${t.peer.name}Peer.js" : "${t.name}.js"
    file := natives[key]
    if (file == null)
    {
      support.warn("Missing native impl for $t.sig", Loc("${t.name}.fan"))
    }
    else
    {
      in := file.in
      out.minify(in)
      in.close
      natives.remove(key)
    }
  }

  Void writeTypeInfo(JsWriter out)
  {
    out.w("fan.${name}.\$pod = fan.std.Pod.\$add('$name');").nl
    out.w("with (fan.${name}.\$pod)").nl
    out.w("{").nl

    // filter out synthetic types from reflection
    reflect := types.findAll |t| { !t.isSynthetic }

    // write all types first
    reflect.each |t|
    {
      adder  := t.isMixin ? "\$am" : "\$at"
      base   := t.base == null ? "null" : "'$t.base.pod::$t.base.name'"
      mixins := t.mixins.join(",") |m| { "'$m.pod::$m.name'" }
      facets := t.facets.join(",") |f| { "'$f.type.sig':$f.val.toCode" }
      flags  := t->flags
      out.w("  fan.${t.pod}.${t.name}.\$type = $adder('$t.name',$base,[$mixins],{$facets},$flags);").nl
    }

    // then write slot info
    reflect.each |t|
    {
      if (t.fields.isEmpty && t.methods.isEmpty) return
      //out.w("  \$$i")
      out.w("  fan.${t.pod}.${t.name}.\$type")
      t.fields.each |f|
      {
        facets := f.facets.join(",") |x| { "'$x.type.sig':$x.val.toCode" }
        out.w(".\$af('$f.origName',$f.flags,'$f.ftype.sig',{$facets})")
      }
      t.methods.each |m|
      {
        if (m.isFieldAccessor) return
        params := m.params.join(",") |p| { "new fan.std.Param('$p.reflectName','$p.paramType.sig',$p.hasDef)" }
        facets := m.facets.join(",") |f| { "'$f.type.sig':$f.val.toCode" }
        out.w(".\$am('$m.origName',$m.flags,'$m.ret.sig',fan.sys.List.makeFromJs(fan.std.Param.\$type,[$params]),{$facets})")
      }
      out.w(";").nl
    }

    // pod meta
    out.indent
    out.w("m_meta = {};").nl
    meta.each |v, k|
    {
      out.w("m_meta[$k.toCode] = $v.toCode;").nl
      //if (k == "pod.version") out.w("m_version = fan.std.Version.fromStr($v.toCode);").nl
    }
    //out.w("m_meta = m_meta.toImmutable();").nl
    out.unindent

    // end with block
    out.w("}").nl
  }

  ** Write closure function spec fields
  Void writeClosureFields(JsWriter out)
  {
    support.podClosures.write(out)
  }

  Str name           // pod name
  Str:Str meta       // pod meta
  JsType[] types     // types in this pod
  Str:File natives   // natives
  JsProps[] props    // prop files in this pod
}
