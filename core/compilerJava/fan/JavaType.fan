//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   17 Nov 08  Brian Frank  Creation
//

using compiler

**
** JavaType is the implementation of CType for a Java class.
**
class JavaType : CType
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  new makeDasm(JavaPod pod, Str name, File classfile)
    : this.init(pod, name)
  {
    this.classfile = classfile
  }

  new makePrimitive(JavaPod pod, Str name, CType primitiveNullable)
    : this.init(pod, name)
  {
    this.primitiveNullable = primitiveNullable
  }

  new makeArray(JavaType of)
    : this.init(of.pod, "[" + of.name)
  {
    this.arrayRank = of.arrayRank + 1
    this.arrayOf   = of
  }

  private new init(JavaPod pod, Str name)
  {
    this.pod    = pod
    this.name   = name
    this.qname  = pod.name + "::" + name
    this.base   = ns.objType
    this.mixins = CType[,]
  }

//////////////////////////////////////////////////////////////////////////
// CType
//////////////////////////////////////////////////////////////////////////

  override CNamespace ns() { pod.ns }
  override JavaPod pod
  override const Str name
  override const Str qname
  override Str signature() { qname }
  override CFacet? facet(Str qname) { null }

  override CType? base { get { load; return &base } }
  override CType[] mixins { get { load; return &mixins } }
  override Int flags { get { load; return &flags } }

  override Bool isForeign() { true }
  override Bool isSupported() { arrayRank <= 1 } // multi-dimensional arrays unsupported

  override Bool isVal() { pod is JavaPrimitives }

  override Bool isNullable() { false }
  override once CType toNullable() { primitiveNullable ?: NullableType(this) }
  private CType? primitiveNullable

  override Bool isGeneric() { false }
  override Bool isParameterized() { false }
  override Bool isGenericParameter() { false }

  override once CType toListOf() { ListType(this) }

  override Str:CSlot slots := [:] { get { load; return &slots } private set }

  override once COperators operators() { COperators(this) }

  override CSlot? slot(Str name) { slots[name] }

  ** Handle the case where a field and method have the same
  ** name; in this case the field will always be first with
  ** a linked list to the overloaded methods
  override CMethod? method(Str name)
  {
    x := slots[name]
    if (x == null) return null
    if (x is JavaField) return ((JavaField)x).next
    return x
  }

  override CType inferredAs()
  {
    if (isPrimitive)
      return name == "float" ? ns.floatType : ns.intType

    if (isArray && !arrayOf.isPrimitive && !arrayOf.isArray)
      return inferredArrayOf.toListOf

    return this
  }

//////////////////////////////////////////////////////////////////////////
// Fits
//////////////////////////////////////////////////////////////////////////

  override Bool fits(CType t)
  {
    if (CType.super.fits(t)) return true
    t = t.toNonNullable
    if (t is JavaType) return fitsJava(t)
    return fitsFan(t)
  }

  private Bool fitsJava(JavaType t)
  {
    // * => java.lang.Object
    if (t.qname == "[java]java.lang::Object") return !isPrimitive

    // array => array
    if (isArray && t.isArray) return arrayOf.fits(t.arrayOf)

    // doesn't fit
    return false
  }

  private Bool fitsFan(CType t)
  {
    // floats => Float; byte,short,char,int => Int
    if (isPrimitive) return name == "float" ? t.isFloat : t.isInt

    // arrays => List
    if (isArray && t is ListType) return arrayOf.fits(((ListType)t).v)

    // doesn't fit
    return false
  }

//////////////////////////////////////////////////////////////////////////
// Load
//////////////////////////////////////////////////////////////////////////

  ** Classfile to use for loading
  const File? classfile

  private Void load()
  {
    if (loaded) return
    slots := Str:CSlot[:]
    if (isPrimitive)
    {
      flags = FConst.Public
    }
    else if (isArray)
    {
      flags = arrayOf.isPublic ? FConst.Public : FConst.Internal
    }
    else
    {
      // map Java members to slots using either Java reflection
      // or the new disassembler
      if (useReflection)
        JavaReflect.loadType(this, slots)
      else
        JavaDasmLoader(this, slots).load
    }
    this.slots = slots
    loaded = true
  }

  ** TODO: hook to fallback to old reflection loader in case
  ** we run into trouble with disassembler loader
  static const Bool useReflection := false
  static
  {
    try
    {
      useReflection = Env.cur.config(JavaType#.pod, "useReflection") == "true"
      if (useReflection) echo("<<< JavaType using reflection >>>")
    }
    catch (Err e) e.trace
  }

//////////////////////////////////////////////////////////////////////////
// Primitives
//////////////////////////////////////////////////////////////////////////

  Bool isPrimitive()
  {
    return pod === pod.bridge.primitives && arrayRank == 0
  }

  Bool isPrimitiveIntLike()
  {
    primitives := pod.bridge.primitives
    return this === primitives.intType ||
           this === primitives.charType ||
           this === primitives.shortType ||
           this === primitives.byteType
  }

  Bool isPrimitiveFloat()
  {
    primitives := pod.bridge.primitives
    return this === primitives.floatType
  }

//////////////////////////////////////////////////////////////////////////
// Arrays
//////////////////////////////////////////////////////////////////////////

  **
  ** Return if this is an interop array like
  ** 'fanx.interop.IntArray' which models 'int[]'.
  **
  Bool isInteropArray()
  {
    pod.isInterop && name.endsWith("Array")
  }

  **
  ** Is this a array type such as '[java]foo.bar::[Baz'
  **
  Bool isArray() {  arrayRank > 0 }

  **
  ** The rank of the array where 0 is not an array,
  ** 1 is one dimension, 2 is two dimensional, etc.
  **
  const Int arrayRank := 0

  **
  ** If this an array, this is the component type.
  **
  JavaType? arrayOf { private set }

  **
  ** The arrayOf field always stores a JavaType so that we
  ** can correctly resolve the FFI qname.  This means that
  ** that an array of java.lang.Object will have an arrayOf
  ** value of '[java]java.lang::Object'.  This method correctly
  ** maps the arrayOf map to its canonical Fantom type.
  **
  CType? inferredArrayOf()
  {
    if (arrayOf == null) return null
    CType x := JavaReflect.objectClassToDirectFanType(ns, arrayOf.toJavaClassName) ?: arrayOf
    return x.toNullable
  }

  **
  ** Get the type which is an array of this type.
  **
  once JavaType toArrayOf() { makeArray(this) }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  **
  ** Get this type's Java class name:
  **   [java]java.lang::Class  => java.lang.Class
  **   [java]java.lang::[Class => [Ljava.lang.Class;
  **
  once Str toJavaClassName()
  {
    s := StrBuf()
    if (isArray)
    {
      rank := arrayRank
      rank.times { s.addChar('[') }
      s.addChar('L')
      s.add(pod.packageName).addChar('.')
      s.add(name[rank .. -rank])
      s.addChar(';')
    }
    else
    {
      s.add(pod.packageName).addChar('.').add(name)
    }
    return s.toStr
  }

  **
  ** We use an implicit constructor called "<new>" on
  ** each type as the protocol for telling the Java runtime
  ** to perform a 'new' opcode for object allocation:
  **   CallNew Type.<new>  // allocate object
  **   args...             // arguments are pushed onto stack
  **   CallCtor <init>     // call to java constructor
  **
  once CMethod newMethod()
  {
    return JavaMethod(
      this,
      "<new>",
      FConst.Ctor + FConst.Public,
      this,
      JavaParam[,])
  }

  **
  ** We use an implicit method called "<class>" on
  ** each type as the protocol for telling the Java runtime
  ** to load a class literal
  **
  static CMethod classLiteral(JavaBridge bridge, CType base)
  {
    return JavaMethod(
      base,
      "<class>",
      FConst.Public + FConst.Static,
      bridge.classType,
      JavaParam[,])
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private Bool loaded := false
}