//
// Copyright (c) 2012, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//    17 Feb 12  Brian Frank  Creation
//

**
** DasmClass models a single disassmbled Java classfile
**
class DasmClass
{
  ** It-block constructor, use `Dasm`
  internal new make(|This| f) { f(this) }

  ** Classfile 'major.minor' version
  const Version version

  ** Class access flags
  const DasmFlags flags

  ** This class name signature
  const DasmType thisClass

  ** Super class name signature (or null if object)
  const DasmType? superClass

  ** Interface signatures
  const DasmType[] interfaces

  ** Member fields
  const DasmField[] fields

  ** Member methods
  const DasmMethod[] methods

  ** Return 'thisClass.toStr'
  override Str toStr() { thisClass.toStr }

  ** Dump debug to output stream
  Void dump(OutStream out := Env.cur.out)
  {
    out.printLine("version:    $version")
    out.printLine("flags:      $flags")
    out.printLine("thisClass:  $thisClass")
    out.printLine("superClass: $superClass")
    out.printLine("interfaces: $interfaces")
    out.printLine("fields:")
    fields.each |f| { out.print("  ").printLine(f) }
    out.printLine("methods:")
    methods.each |m| { out.print("  ").printLine(m) }
    out.flush
  }
}

**************************************************************************
** DasmFlags
**************************************************************************

**
** DasmFlags model class/member Java access flags
**
const class DasmFlags
{
  new make(Int mask) { this.mask = mask }

  static const Int PUBLIC     := 0x0001
  static const Int PRIVATE    := 0x0002
  static const Int PROTECTED  := 0x0004
  static const Int STATIC     := 0x0008
  static const Int FINAL      := 0x0010
  static const Int SUPER      := 0x0020
  static const Int VOLATILE   := 0x0040
  static const Int INTERFACE  := 0x0200
  static const Int ABSTRACT   := 0x0400
  static const Int TRANSIENT  := 0x0800
  static const Int SYNTHETIC  := 0x1000
  static const Int ANNOTATION := 0x2000
  static const Int ENUM       := 0x4000

  Bool isPublic()     { mask.and(PUBLIC) != 0   }
  Bool isPrivate()    { mask.and(PRIVATE) != 0   }
  Bool isProtected()  { mask.and(PROTECTED) != 0 }
  Bool isStatic()     { mask.and(STATIC) != 0    }
  Bool isFinal()      { mask.and(FINAL) != 0     }
  Bool isSuper()      { mask.and(SUPER) != 0     }
  Bool isInterface()  { mask.and(INTERFACE) != 0 }
  Bool isAbstract()   { mask.and(ABSTRACT) != 0  }
  Bool isAnnotation() { mask.and(ANNOTATION) != 0  }

  override Str toStr()
  {
    s := StrBuf()
    this.typeof.methods.each |m|
    {
      if (m.parent == this.typeof && m.name.startsWith("is") && m.callOn(this, [,]))
        s.add(m.name[2..-1].lower).add(" ")
    }
    if (!s.isEmpty) s.remove(-1)
    return s.toStr
  }

  const Int mask
}


**************************************************************************
** DasmField
**************************************************************************

**
** DasmField models a disassembled Java field
**
const class DasmField
{
  new make(|This| f) { f(this) }

  const Str name
  const DasmFlags flags
  const DasmType type

  override Str toStr() { "$flags $type $name;" }
}

**************************************************************************
** DasmMethod
**************************************************************************

**
** DasmMethod models a disassembled Java method
**
const class DasmMethod
{
  new make(|This| f) { f(this) }

  const Str name
  const DasmFlags flags
  const DasmType returns
  const DasmType[] params

  override Str toStr()   { "$flags $returns $name(" + params.join(",") + ")" }
}

**************************************************************************
** DasmType
**************************************************************************

**
** DasmType models a type within a field or method descriptor
**
const class DasmType
{
  new make(Str sig)
  {
    for (i:=0; sig[i] == '['; ++i) rank++
    this.sig = sig
  }

  ** Java signature such as "Ljava/lang/String;" or "I"
  const Str sig

  ** If array, what is its rank (or zero if not an array)
  const Int rank

  ** Is this an array type
  Bool isArray() { rank > 0 }

  ** Is this a primitive type
  Bool isPrimitive() { sig.size == 1 }

  ** Get array's component type
  DasmType toComponentType()
  {
    if (rank == 0) throw ArgErr("Not an array: $sig")
    return make(sig[1..-1])
  }

  override Str toStr()
  {
    s := rank == 0 ? sig : sig[rank..-1]
    if (s[0] == 'L') s = s[1..-2].replace("/", ".")
    else if (s.size == 1) s = sigToPrimitive[s] ?: throw Err(s)
    rank.times { s = s += "[]" }
    return s
  }

  private static const Str:Str sigToPrimitive :=
  [
    "B": "byte",
    "C": "char",
    "D": "double",
    "F": "float",
    "I": "int",
    "J": "long",
    "S": "short",
    "V": "void",
    "Z": "boolean",
  ]
}

