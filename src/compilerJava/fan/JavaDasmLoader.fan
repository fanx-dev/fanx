//
// Copyright (c) 2012, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 Feb 12  Brian Frank  Creation
//

using compiler
using [java] fanx.util

**
** JavaDasmLoader
**
internal class JavaDasmLoader
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(JavaType self, Str:CSlot slots)
  {
    this.self  = self
    this.slots = slots
    this.ns    = self.ns
    if (self.classfile == null) throw Err("classfile null: $self.qname")
  }

//////////////////////////////////////////////////////////////////////////
// Load
//////////////////////////////////////////////////////////////////////////

  **
  ** Map classfile structure to Fantom slots
  **
  Void load()
  {
    //TODO
    if (self.classfile.isDir) return

    // dassemble the classfile into memory
    cf := Dasm(self.classfile.in).read

    // map superclass
    CType? base
    if (cf.superClass != null)
       self.base = base = toFanType(self.bridge, cf.superClass).toNonNullable

    // map interfaces to mixins
    mixins := CType[,]
    cf.interfaces.each |t|
    {
      try
        mixins.add(toFanType(self.bridge, t).toNonNullable)
      catch (UnknownTypeErr e)
        errUnknownType(e)
    }
    if (cf.flags.isAnnotation) mixins.add(ns.facetType)
    self.mixins = mixins

    // map Java modifiers to Fantom flags
    self.flags = toClassFlags(cf.flags)

    // map Annotation element methods as fields so that
    // it looks like a Fantom facet
    if (cf.flags.isAnnotation) mapAnnotationFields(cf)

    // map Java fields to CSlots (public and protected)
    cf.fields.each |j| { mapField(j) }

    // map Java methods to CSlots (public and protected)
    cf.methods.each |j| { mapMethod(j) }

    // map all public/protected slots from my base types
    if (base != null) inherit(base)
    if (!cf.flags.isInterface && base != null) inherit(ns.resolveType("[java]java.lang::Object"))
    mixins.each |m| { inherit(m) }
    inherit(ns.objType)
  }

//////////////////////////////////////////////////////////////////////////
// Java Member -> Fantom CSlot
//////////////////////////////////////////////////////////////////////////

  Void mapField(DasmField java)
  {
    if (!java.flags.isPublic && !java.flags.isProtected) return
    try
    {
      fan := JavaField(
        self,
        java.name,
        toMemberFlags(java.flags),
        toFanType(self.bridge, java.type))
      addSlot(fan)
    }
    catch (UnknownTypeErr e) errUnknownType(e)
  }

  Void mapMethod(DasmMethod java)
  {
    if (!java.flags.isPublic && !java.flags.isProtected) return
    isCtor := java.name == "<init>"
    ctorFlags := isCtor ? FConst.Ctor : 0
    returns := isCtor ? self : toFanType(self.bridge, java.returns)
    try
    {
      fan := JavaMethod(
        self,
        java.name,
        toMemberFlags(java.flags).or(ctorFlags),
        returns)
      fan.setParamTypes(toFanTypes(self.bridge, java.params))
      addSlot(fan)
    }
    catch (UnknownTypeErr  e) errUnknownType(e)
  }

  Void inherit(CType t)
  {
    t.slots.each |slot|
    {
      // don't inherit constructors or non-public/non-protected slots
      if (slot.isCtor) return
      if (!slot.isPublic && !slot.isProtected) return

      // if not JavaSlot then its straight add
      java := slot as JavaSlot
      if (java == null) { addSlot(slot); return }

      // if JavaSlot when we need to ensure we add
      // whole copy of linked list
      while (java != null) { addSlot(java.dup); java = java.next }
    }
  }

  Void addSlot(CSlot slot)
  {
    // if we don't have a slot with this name already its simple
    name := slot.name
    dup := slots.get(name)
    if (dup == null) { slots.set(name, slot); return }

    // if the existing slot is not a JavaSlot then it
    // must come from a Fantom type so we just replace it
    x := dup as JavaSlot
    if (x == null) { slots.set(name, slot); return }

    // if slot we're adding is not JavaSlot replace
    if (slot isnot JavaMethod) return
    m := (JavaMethod)slot

    // check the linked list for methods with the exact same
    // signature (this can happen by inheriting abstract methods
    // from multiple interfaces)
    for (p := x; p != null; p = p.next)
    {
      if (p is JavaMethod && m.sigsEqual(p))
        return
    }

    // create linked list of overloads
    m.next = x.next
    x.next = m
  }

//////////////////////////////////////////////////////////////////////////
// Annotations
//////////////////////////////////////////////////////////////////////////

  private Void mapAnnotationFields(DasmClass cf)
  {
    // Java annotations declare their "elements" as abstract public
    // methods, but in Fantom facets are declared with const fields;
    // so we here we fake it out so that a Java annotation type looks
    // like a Fantom facet from the compiler's perspective
    cf.methods.each |m|
    {
      if (!m.flags.isPublic || !m.flags.isAbstract) return
      try
      {

        fan := JavaField(
          self,
          m.name,
          FConst.Public.or(FConst.Const),
          toAnnotationType(m))
        slots.set(fan.name, fan)
      }
      catch (UnknownTypeErr e) errUnknownType(e)
    }
  }

  private CType toAnnotationType(DasmMethod m)
  {
    switch (m.returns.sig)
    {
      case "Ljava/lang/Class;":  return ns.typeType
      case "[Ljava/lang/Class;": return ns.typeType.toListOf
      case "[Z":                 return ns.boolType.toListOf
      case "[B":
      case "[S":
      case "[I":
      case "[J":                 return ns.intType.toListOf
      case "[F":
      case "[D":                 return ns.floatType.toListOf
      default:                   return toFanType(self.bridge, m.returns)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  **
  ** Map an list of DasmTypes to their CType representations.
  **
  static CType[] toFanTypes(JavaBridge bridge, DasmType[] types)
  {
    types.map |t->CType| { toFanType(bridge, t) }
  }

  **
  ** Map DasmType to its CType representation.
  **
  static CType toFanType(JavaBridge bridge, DasmType t, Bool multiDim := false)
  {
    ns := bridge.ns
    primitives := bridge.primitives

    // primitives
    if (t.isPrimitive)
    {
      switch (t.sig[0])
      {
        case 'V': return ns.voidType
        case 'Z': return multiDim ? primitives.booleanType : ns.boolType
        case 'J': return multiDim ? primitives.longType    : ns.intType
        case 'D': return multiDim ? primitives.doubleType  : ns.floatType
        case 'I': return primitives.intType
        case 'B': return primitives.byteType
        case 'S': return primitives.shortType
        case 'C': return primitives.charType
        case 'F': return primitives.floatType
      }
      throw Err(t.toStr)
    }

    // arrays [java]foo.bar::[Baz
    if (t.isArray)
    {
      // if a primary array
      if (t.sig.size == 2 && !multiDim)
      {
        switch (t.sig)
        {
          case "[Z": return ns.resolveType("[java]fanx.interop::BooleanArray?")
          case "[B": return ns.resolveType("[java]fanx.interop::ByteArray?")
          case "[S": return ns.resolveType("[java]fanx.interop::ShortArray?")
          case "[C": return ns.resolveType("[java]fanx.interop::CharArray?")
          case "[I": return ns.resolveType("[java]fanx.interop::IntArray?")
          case "[J": return ns.resolveType("[java]fanx.interop::LongArray?")
          case "[F": return ns.resolveType("[java]fanx.interop::FloatArray?")
          case "[D": return ns.resolveType("[java]fanx.interop::DoubleArray?")
        }
        throw Err(t.sig)
      }

      // return "[java] foo.bar::[Baz"
      compType := t.toComponentType
      comp := toFanType(bridge, compType, true).toNonNullable
      if (comp isnot JavaType) throw Err("Not JavaType: $compType -> $comp")
      return ((JavaType)comp).toArrayOf.toNullable
    }

    // check for direct mappings of Obj/Str/Decimal (considered nullable)
    if (!multiDim)
    {
      switch (t.sig)
      {
        case "Ljava/lang/Object;":     return ns.objType.toNullable
        case "Ljava/lang/String;":     return ns.strType.toNullable
        case "Ljava/math/BigDecimal;": return ns.decimalType.toNullable
        case "Lfanx/main/Type;":       return ns.typeType.toNullable
        case "Ljava/lang/Long;":       return ns.intType.toNullable
        case "Ljava/lang/Double;":     return ns.floatType.toNullable
        case "Ljava/lang/Boolean;":    return ns.boolType.toNullable
        case "Ljava/lang/Number;":     return ns.resolveType("sys::Num").toNullable
      }
    }

    // parse signature into
    if (t.sig[0] != 'L') throw Err(t.sig)
    slash := t.sig.indexr("/")
    package := t.sig[1..<slash].replace("/", ".")
    name := t.sig[slash+1..-2]

    // anything in fan.sys package is really a sys pod type
    if (package == "fan.sys") return ns.resolveType("sys::$name?")
    if (package == "fan.std") return ns.resolveType("std::$name?")

    // Java FFI
    sig := "[java]${package}::${name}?"
    return ns.resolveType(sig)
  }

  **
  ** Convert Java class modifiers to Fantom flags.
  **
  static Int toClassFlags(DasmFlags flags)
  {
    FanUtil.classModifiersToFanFlags(flags.mask)
  }

  **
  ** Convert Java member modifiers to Fantom flags.
  **
  static Int toMemberFlags(DasmFlags flags)
  {
    FanUtil.memberModifiersToFanFlags(flags.mask)
  }

  **
  ** Handle an error during the Java mapping process - if we
  ** can't map a given Java member we just output a warning
  ** rather than have the whole compilation fail.
  **
  static Void errUnknownType(UnknownTypeErr e)
  {
    // just print a warning and ignore problematic APIs
    echo("WARNING: Cannot map Java type: $e.msg")
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  CNamespace ns
  JavaType self
  Str:CSlot slots
}