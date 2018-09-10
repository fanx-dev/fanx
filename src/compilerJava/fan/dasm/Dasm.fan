//
// Copyright (c) 2012, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//    17 Feb 12  Brian Frank  Creation
//

**
** Dasm is used to disassemble Java classfiles
**
class Dasm
{

//////////////////////////////////////////////////////////////////////////
// Public
//////////////////////////////////////////////////////////////////////////

  ** Constructr for given input stream
  new make(InStream in) { this.in = in }

  ** Read the classfile and close input stream
  DasmClass read()
  {
    try
    {
      readMagic
      readVersion
      readConstantPool
      readAccessFlags
      readThisClass
      readSuperClass
      readInterfaces
      readFields
      readMethods
      return makeClass
    }
    finally in.close
  }

//////////////////////////////////////////////////////////////////////////
// File Header
//////////////////////////////////////////////////////////////////////////

  private Void readMagic()
  {
    if (in.readU4 != 0xCAFEBABE) throw IOErr("Invalid magic, not a classfile")
  }

  private Void readVersion()
  {
    versionMinor := in.readU2
    versionMajor := in.readU2
    version = Version([versionMajor, versionMinor])
  }

//////////////////////////////////////////////////////////////////////////
// Constant Pool
//////////////////////////////////////////////////////////////////////////

  private Void readConstantPool()
  {
    // we only read the stuff required for compiler, ignore rest
    count := in.readU2
    cpClass.fill(null, count)
    cpUtf8.fill(null, count)
    for (i:=1; i<count; ++i)
    {
      tag := in.readU1
      switch (tag)
      {
        case CP_CLASS:          cpClass[i] = in.readU2
        case CP_FIELD:          skip(4)
        case CP_METHOD:         skip(4)
        case CP_INTERFACE:      skip(4)
        case CP_STRING:         skip(2)
        case CP_INTEGER:        skip(4)
        case CP_FLOAT:          skip(4)
        case CP_LONG:           skip(8); ++i
        case CP_DOUBLE:         skip(8); ++i
        case CP_NAMETYPE:       skip(4)
        case CP_UTF8:           cpUtf8[i] = in.readUtf
        case CP_METHODHANDLE:   skip(3)
        case CP_METHODTYPE:     skip(2)
        case CP_INVOKEDYNAMIC:  skip(4)
        default: throw IOErr("unknown tag $tag")
      }
    }
  }

//////////////////////////////////////////////////////////////////////////
// Class Summary
//////////////////////////////////////////////////////////////////////////

  private Void readAccessFlags()
  {
    flags = readFlags
  }

  private Void readThisClass()
  {
    clsName := readClass
    thisClass = DasmType("L${clsName};")
  }

  private Void readSuperClass()
  {
    clsName := readClass
    if (clsName != null)
      superClass = DasmType("L${clsName};")
  }

  private Void readInterfaces()
  {
    num := in.readU2
    interfaces = DasmType[,]
    interfaces.capacity = num
    for (i:=0; i<num; ++i)
    {
      clsName := readClass
      interfaces.add(DasmType("L${clsName};"))
    }
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private Void readFields()
  {
    num := in.readU2
    fields = DasmField[,]
    fields.capacity = num
    for (i:=0; i<num; ++i) fields.add(readField)
  }

  private DasmField readField()
  {
    flags := readFlags
    name  := readUtf
    descr := readUtf
    skipAttrs
    return DasmField
    {
      it.flags = flags
      it.name  = name
      it.type  = DasmType(descr)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  private Void readMethods()
  {
    num := in.readU2
    methods = DasmMethod[,]
    methods.capacity = num
    for (i:=0; i<num; ++i) methods.add(readMethod)
  }

  private DasmMethod readMethod()
  {
    flags := readFlags
    name  := readUtf
    descr := readUtf

    // parse (ABC)R
    i := 1
    params := DasmType[,]
    while (descr[i] != ')')
    {
      start := i
      while (descr[i] == '[') ++i
      if (descr[i] == 'L') { while (descr[i] != ';') ++i }
      params.add(DasmType(descr[start..i]))
      i++
    }
    returns := DasmType(descr[i+1..-1])

    skipAttrs
    return DasmMethod
    {
      it.flags = flags
      it.name  = name
      it.returns = returns
      it.params  = params
    }
  }

//////////////////////////////////////////////////////////////////////////
// Attributes
//////////////////////////////////////////////////////////////////////////

  private Void skipAttrs()
  {
    num := in.readU2
    for (i:=0; i<num; ++i)
    {
      name := readUtf
      size := in.readU4
      skip(size)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Make Class
//////////////////////////////////////////////////////////////////////////

  private DasmClass makeClass()
  {
    DasmClass
    {
      it.version    = this.version
      it.flags      = this.flags
      it.thisClass  = this.thisClass
      it.superClass = this.superClass
      it.interfaces = this.interfaces
      it.fields     = this.fields
      it.methods    = this.methods
    }
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  private DasmFlags readFlags()
  {
    return DasmFlags(in.readU2)
  }

  private Str readUtf()
  {
    cp := in.readU2
    return cpUtf8[cp]
  }

  private Str? readClass()
  {
    cp := in.readU2
    if (cp == 0) return null
    return cpUtf8[cpClass[cp]]
  }

  private Void skip(Int n)
  {
    if (in.skip(n) != n) throw Err("WTF")
  }

//////////////////////////////////////////////////////////////////////////
// Constants
//////////////////////////////////////////////////////////////////////////

  static const Int CP_CLASS         := 7
  static const Int CP_FIELD         := 9
  static const Int CP_METHOD        := 10
  static const Int CP_INTERFACE     := 11
  static const Int CP_STRING        := 8
  static const Int CP_INTEGER       := 3
  static const Int CP_FLOAT         := 4
  static const Int CP_LONG          := 5
  static const Int CP_DOUBLE        := 6
  static const Int CP_NAMETYPE      := 12
  static const Int CP_UTF8          := 1
  static const Int CP_METHODHANDLE  := 15
  static const Int CP_METHODTYPE    := 16
  static const Int CP_INVOKEDYNAMIC := 18

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private InStream in            // constructor
  private Version? version       // readVersion
  private Str?[] cpUtf8 := [,]   // readConstantPool
  private Int?[] cpClass := [,]  // readConstantPool
  private DasmFlags? flags       // readAccessFlags
  private DasmType? thisClass    // readThisClass
  private DasmType? superClass   // readSuperClass
  private DasmType[]? interfaces // readInterfaces
  private DasmField[]? fields    // readFields
  private DasmMethod[]? methods  // readMethods
}