//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Sep 05  Brian Frank  Creation
//

**
** Assembler assembles all the TypeDefs into their fcode representation.
**
class Assembler : FConst
{
   CompilerContext compiler
   
  
//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  new make(CompilerContext compiler)
  {
    this.compiler = compiler
  }

//////////////////////////////////////////////////////////////////////////
// Assemble
//////////////////////////////////////////////////////////////////////////

  FPod assemblePod()
  {
    fpod = FPod(compiler.ns, compiler.pod.name, null)

    fpod.name    = compiler.pod.name
    fpod.version = compiler.pod.version
    fpod.depends = compiler.pod.depends
    fpod.meta    = assembleMeta
    fpod.index   = compiler.pod.index

    fpod.ftypes = FType[,]
    compiler.pod.types.each |TypeDef t|
    {
      fpod.ftypes.add(assembleType(t))
    }

    return fpod
  }

  private Str:Str assembleMeta()
  {
    ts := DateTime.now.floor(1sec)
    pod := compiler.pod
    meta := pod.meta
    meta["pod.name"]       = pod.name
    meta["pod.version"]    = pod.version.toStr
    meta["pod.depends"]    = pod.depends.join(";")
    assert(meta["pod.summary"] != null)
    meta["pod.isScript"]   = compiler.input.isScript.toStr
    meta["pod.compileJs"]  = pod.compileJs.toStr
    meta["pod.fcode"] = (!compiler.pod.types.isEmpty).toStr
    meta["fcode.version"]  = FConst.FCodeVersion
    meta["build.host"]     = Env.cur.host
    meta["build.user"]     = Env.cur.user
    meta["build.ts"]       = ts.toJava.toStr
    meta["build.tsKey"]    = ts.toLocale("YYMMDDhhmmss")
    meta["build.compiler"] = this.typeof.pod.version.toStr
    meta["build.platform"] = Env.cur.platform
    return meta
  }

  private FType assembleType(TypeDef def)
  {
    t := FType(fpod)

    t.hollow   = false
    t.flags    = def.flags
    t.self     = typeRef(def.asRef)
    t.fbase    = (def.base == null) ? -1 : typeRef(def.base)
    t.fmixins  = def.mixins.map |CType m->Int| { typeRef(m) }
    t.ffields  = def.fieldDefs.map |FieldDef f->FField| { assembleField(t, f) }
    t.fmethods = def.methodDefs.map |MethodDef m->FMethod| { assembleMethod(t, m) }
    def.genericParameters.each |p| {
      t.genericParamNames.add(name(p.paramName))
      t.genericParamBounds.add(typeRef(p.bound))
    }

    attrs := AttrAsm(compiler, fpod)
    if (compiler.input.isScript)
      attrs.sourceFile(def.loc.fileUri)
    else
      attrs.sourceFile(def.loc.filename)
    attrs.lineNumber(def.loc.line)
    attrs.facets(def.facets)
    t.fattrs = attrs.attrs

    return t
  }

  FField assembleField(FType fparent, FieldDef def)
  {
    f := FField(fparent)
    f.nameIndex = name(def.name)
    f.flags     = def.flags
    f.typeRef   = typeRef(def.fieldType)

    attrs := AttrAsm(compiler, fpod)
    attrs.lineNumber(def.loc.line)
    attrs.facets(def.facets)
    if (def.enumDef != null) attrs.enumOrdinal(def.enumDef.ordinal)
    f.fattrs = attrs.attrs

    return f;
  }

  FMethod assembleMethod(FType fparent, MethodDef def)
  {
    //TODO
    //def.resetVarRegister
    
    attrs := AttrAsm(compiler, fpod)

    m := FMethod(fparent)

    m.nameIndex    = name(def.name)
    m.flags        = def.flags
    m.ret          = typeRef(def.ret)
    m.inheritedRet = typeRef(def.inheritedReturnType)
    m.paramCount   = def.params.size
    allVars := def.getAllVars
    m.localCount   = allVars.size - def.params.size

    if (m.localCount < 0) {
      throw Err("localCount is $m.localCount, method:$def.qname, params:$m.paramCount")
    }

    m.vars = allVars.map |MethodVar v->FMethodVar|
    {
      f := FMethodVar(m)
      f.nameIndex = name(v.name)
      f.typeRef   = typeRef(v.paramDef?.paramType ?: v.ctype)
      f.flags     = v.flags
      if (v.paramDef != null)
      {
        
        f.defNameIndex = name(ParamDefaultAttr)
        f.def = assembleExpr(v.paramDef.def)
        if (f.def != null) {
           f.flags = v.flags.or(FConst.ParamDefault)
        }
      }
      return f
    }

    m.code = assembleCode(def, attrs)

    attrs.lineNumber(def.loc.line)
    attrs.facets(def.facets)
    m.fattrs = attrs.attrs

    return m;
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  Int typeRef(CType type)
  {
    return fpod.addTypeRef(type)
  }

  Int name(Str val)
  {
    return fpod.addName(val)
  }

  private Buf? assembleCode(MethodDef def , AttrAsm attrs)
  {
    block := def.code
    if (block == null) return null

    asm := CodeAsm(compiler, def.loc, fpod, def)
    if (def.ctorChain != null) asm.expr(def.ctorChain)
    asm.block(block)

    if (asm.errCount > 0) attrs.add(ErrTableAttr, asm.finishErrTable)
    if (asm.lineCount > 0) attrs.add(LineNumbersAttr, asm.finishLines)

    return asm.finishCode
  }

  private Buf? assembleExpr(Expr? expr)
  {
    if (expr == null) return null
    asm := CodeAsm(compiler, expr.loc, fpod, null)
    asm.expr(expr)
    return asm.finishCode
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  FPod? fpod
}