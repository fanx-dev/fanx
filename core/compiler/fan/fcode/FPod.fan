//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Dec 05  Brian Frank  Creation
//   19 Aug 06  Brian Frank  Ported from Java to Fan
//

**
** FPod is the read/write fcode representation of sys::Pod.  It's main job in
** life is to manage all the pod-wide constant tables for names, literals,
** type/slot references and type/slot definitions.
**
final class FPod : CPod, FConst
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(CNamespace ns, Str podName, Zip? zip)
  {
    this.ns         = ns
    this.version    = Version.defVal
    this.depends    = CDepend[,]
    this.name       = podName
    this.zip        = zip
    this.names      = FTable.makeStrs(this)
    this.typeRefs   = FTable.makeTypeRefs(this)
    this.fieldRefs  = FTable.makeFieldRefs(this)
    this.methodRefs = FTable.makeMethodRefs(this)
    this.ints       = FTable.makeInts(this)
    this.floats     = FTable.makeFloats(this)
    //this.decimals   = FTable.makeDecimals(this)
    this.strs       = FTable.makeStrs(this)
    //this.durations  = FTable.makeDurations(this)
    //this.uris       = FTable.makeStrs(this)
    this.meta       = Str:Str[:]
    this.index      = Str:Str[:]
  }

//////////////////////////////////////////////////////////////////////////
// CPod
//////////////////////////////////////////////////////////////////////////

  override File file() { zip.file }

  override CType? resolveType(Str name, Bool checked)
  {
    t := ftypesByName[name]
    if (t != null) return t
    if (checked) throw UnknownTypeErr("${this.name}::$name")
    return null
  }

  override CType[] types()
  {
    return ftypes
  }

  CType? toType(Int index)
  {
    if (index == 0xffff) return null
    r := typeRef(index)

    podName := n(r.podName)
    typeName := n(r.typeName)

    sig := podName + "::" + typeName + r.sig

    //echo("toType: $podName $typeName => $sig, $r.sig")
    return ns.resolveType(sig)
  }

  CType[] resolveTypes(Int[] indexes)
  {
    return indexes.map |Int index->CType| { toType(index) }
  }

//////////////////////////////////////////////////////////////////////////
// Convenience
//////////////////////////////////////////////////////////////////////////

  Str n(Int index)                { names[index] }
  FTypeRef typeRef(Int index)     { typeRefs[index] }
  FFieldRef fieldRef(Int index)   { fieldRefs[index] }
  FMethodRef methodRef(Int index) { methodRefs[index] }
  Int integer(Int index)          { ints[index] }
  Float float(Int index)          { floats[index] }
  //Decimal decimal(Int index)      { decimals[index] }
  Str str(Int index)              { strs[index] }
  //Duration duration(Int index)    { durations[index] }
  //Str uri(Int index)              { uris[index] }

  Str typeRefStr(Int index) { typeRef(index).format(this) }
  Str fieldRefStr(Int index) { fieldRef(index).format(this) }
  Str methodRefStr(Int index) { methodRef(index).format(this) }

//////////////////////////////////////////////////////////////////////////
// Compile Utils
//////////////////////////////////////////////////////////////////////////

  Int addName(Str val)
  {
    return names.add(val)
  }

  Int addTypeRef(CType t)
  {
    p   := addName(t.pod.name)
    n   := addName(t.name)
    sig := t.extName
    //if (t.isParameterized) sig = t.extName
    //else if (t.isNullable) sig = "?"
    //echo("addTypeRef $t.pod.name $t.name $sig signature:$t.signature")
    return typeRefs.add(FTypeRef(p, n, sig))
  }

  Int addFieldRef(CField field)
  {
    p := addTypeRef(field.parent)
    n := addName(field.name)
    t := addTypeRef(field.fieldType)
    return fieldRefs.add(FFieldRef(p, n, t))
  }

  Int addMethodRef(CMethod method, Int? argCount := null)
  {
    // if this is a generic instantiation, we want to call
    // against the original generic method using it's raw
    // types, since that is how the system library will
    // implement the type
    if (method.isParameterized) method = method.generic

    p := addTypeRef(method.parent)
    n := addName(method.name)
    r := addTypeRef(method.inheritedReturnType.raw)  // CLR can't deal with covariance
    Int[] params := method.params.map |CParam x->Int| { addTypeRef(x.paramType.raw) }
    if (argCount != null && argCount < params.size)
      params = params[0..<argCount]
    return methodRefs.add(FMethodRef(p, n, r, params))
  }

  Void dump(OutStream out := Env.cur.out)
  {
    p := FPrinter(this, out)
    p.showCode = true
    p.ftypes
  }

//////////////////////////////////////////////////////////////////////////
// Read
//////////////////////////////////////////////////////////////////////////

  **
  ** Read the just the pod and type meta-data, but
  ** not each type's full definition
  **
  Void read()
  {
    // echo("     FPod.reading [$zip.file]...")

    // read pod meta-data
    meta = this.in(`/meta.props`).readProps
    name = meta.get("pod.name") ?: throw IOErr("Missing meta pod.name")
    version = Version(meta.get("pod.version"))
    d := meta.get("pod.depends")
    depends = d.isEmpty ? CDepend[,] : d.split(';').map |s->CDepend| { CDepend.fromStr(s) }

    // read tables
    names.read(in(`/fcode/names.def`))
    typeRefs.read(in(`/fcode/typeRefs.def`))
    fieldRefs.read(in(`/fcode/fieldRefs.def`))
    methodRefs.read(in(`/fcode/methodRefs.def`))
    ints.read(in(`/fcode/ints.def`))
    floats.read(in(`/fcode/floats.def`))
    //decimals.read(in(`/fcode/decimals.def`))
    strs.read(in(`/fcode/strs.def`))
    //durations.read(in(`/fcode/durations.def`))
    //uris.read(in(`/fcode/uris.def`))

    // read type meta-data
    in := this.in(`/fcode/types.def`)
    ftypes = FType[,]
    ftypesByName = Str:FType[:]
    if (in != null)
    {
      in.readU2.times
      {
        ftype := FType(this).readMeta(in)
        ftypes.add(ftype)
        ftypesByName[ftype.name] = ftype
        ns.typeCache[ftype.qname] = ftype
      }
      in.close
    }
  }

  **
  ** Read the entire pod into memory (including full type specifications)
  **
  Void readFully()
  {
    ftypes.each |FType t| { t.read }
  }

//////////////////////////////////////////////////////////////////////////
// Write
//////////////////////////////////////////////////////////////////////////

  **
  ** Write the tables and type files out to zip storage
  **
  Void write(Zip zip := this.zip)
  {
    this.zip = zip

    // write pod meta, index props
    writeMeta(`/meta.props`)
    writeIndex(`/index.props`)

    // write non-empty tables
    if (!names.isEmpty)      names.write(out(`/fcode/names.def`))
    if (!typeRefs.isEmpty)   typeRefs.write(out(`/fcode/typeRefs.def`))
    if (!fieldRefs.isEmpty)  fieldRefs.write(out(`/fcode/fieldRefs.def`))
    if (!methodRefs.isEmpty) methodRefs.write(out(`/fcode/methodRefs.def`))
    if (!ints.isEmpty)       ints.write(out(`/fcode/ints.def`))
    if (!floats.isEmpty)     floats.write(out(`/fcode/floats.def`))
    //if (!decimals.isEmpty)   decimals.write(out(`/fcode/decimals.def`))
    if (!strs.isEmpty)       strs.write(out(`/fcode/strs.def`))
    //if (!durations.isEmpty)  durations.write(out(`/fcode/durations.def`))
    //if (!uris.isEmpty)       uris.write(out(`/fcode/uris.def`))

    // write type meta-data
    if (!ftypes.isEmpty)
    {
      out := this.out(`/fcode/types.def`)
      out.writeI2(ftypes.size)
      ftypes.each |FType t| { t.writeMeta(out) }
      out.close
    }

    // write type full fcode
    ftypes.each |FType t| { t.write }
  }

  private Void writeMeta(Uri uri)
  {
    out := out(uri)
    out.writeProps(meta)
    out.close
  }

  private Void writeIndex(Uri uri)
  {
    if (index.isEmpty) return
    out := out(uri)
    index.each |v, n|
    {
      if (v is Str)
        prop(out, n, v)
      else
        ((Str[])v).each |vi| { prop(out, n, vi) }
    }
    out.close
  }

  private Void prop(OutStream out, Str n, Str v)
  {
    out.print(n.toCode(null, true))
       .print("=")
       .print(v.toCode(null, true))
       .print("\n")
  }

//////////////////////////////////////////////////////////////////////////
// Zip
//////////////////////////////////////////////////////////////////////////

  **
  ** Get input stream to read the specified file from zip storage.
  **
  InStream? in(Uri uri)
  {
    file := zip.contents[uri]
    if (file == null) return null
    return file.in
  }

  **
  ** Get output stream to write the specified file to zip storage.
  **
  OutStream out(Uri uri) { zip.writeNext(uri) }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  override CNamespace ns    // compiler's namespace
  override Str name         // pod's unique name
  override Version version  // pod version
  override CDepend[] depends // pod dependencies
  Str:Str meta              // pod meta
  Str:Obj index             // pod index
  Zip? zip                  // zipped storage
  FType[]? ftypes           // pod's declared types
  FTable names              // identifier names: foo
  FTable typeRefs           // types refs:   [pod,type,sig]
  FTable fieldRefs          // fields refs:  [parent,name,type]
  FTable methodRefs         // methods refs: [parent,name,ret,params]
  FTable ints               // Int literals
  FTable floats             // Float literals
  //FTable decimals           // Decimal literals
  FTable strs               // Str literals
  //FTable durations          // Duration literals
  //FTable uris               // Uri literals
  [Str:FType]? ftypesByName // if loaded

}