//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Dec 05  Brian Frank  Creation
//   06 Dec 07  Brian Frank  Rename from FTuple
//
package fanx.fcode;

import java.io.*;
import java.util.*;
import fanx.emit.*;

/**
 * FFieldRef is used to reference methods for a field access operation.
 * We use FFieldRef to encapsulate how Fantom field access opcodes are
 * emitted to Java bytecode.
 */
public class FFieldRef
  implements EmitConst, FConst
{

//////////////////////////////////////////////////////////////////////////
// Constructors
//////////////////////////////////////////////////////////////////////////

  /**
   * Construct from read.
   */
  private FFieldRef(FTypeRef parent, String name, FTypeRef type)
  {
    this.parent = parent;
    this.name   = name;
    this.type   = type;
  }

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  /**
   * Return qname
   */
  public String toString()
  {
    return parent + "." + name;
  }

//////////////////////////////////////////////////////////////////////////
// Emit
//////////////////////////////////////////////////////////////////////////

  public void emitLoadInstance(CodeEmit code)
  {
    int field = code.emit().field(jsig(false));
    code.op2(GETFIELD, field);
  }

  public void emitStoreInstance(CodeEmit code)
  {
    int field = code.emit().field(jsig(false));
    code.op2(PUTFIELD, field);
  }

  public void emitLoadStatic(CodeEmit code)
  {
    int field = code.emit().field(jsig(false));
    code.op2(GETSTATIC, field);
  }

  public void emitStoreStatic(CodeEmit code)
  {
    int field = code.emit().field(jsig(false));
    code.op2(PUTSTATIC, field);
  }

  public void emitLoadMixinStatic(CodeEmit code)
  {
    int field = code.emit().field(jsig(true));
    code.op2(GETSTATIC, field);
  }

  public void emitStoreMixinStatic(CodeEmit code)
  {
    int field = code.emit().field(jsig(true));
    code.op2(PUTSTATIC, field);
  }

//////////////////////////////////////////////////////////////////////////
// Fan-to-Java Mapping
//////////////////////////////////////////////////////////////////////////

  /**
   * Java assembler signature for this field:
   *   Lfan/foo/Bar.baz:Lfan/sys/Duration;
   */
  private String jsig(boolean mixin)
  {
    if (jsig == null)
    {
      StringBuilder s = new StringBuilder();
      s.append(parent.jimpl());
      if (mixin && !parent.isFFI()) s.append('$');
      s.append('.').append(name).append(':');
      type.jsig(s);
      jsig = s.toString();
    }
    return jsig;
  }

//////////////////////////////////////////////////////////////////////////
// IO
//////////////////////////////////////////////////////////////////////////

  /**
   * Parse from fcode constant pool format:
   *   fieldRef
   *   {
   *     u2 parent (typeRefs.def)
   *     u2 name   (names.def)
   *     u2 type   (typeRefs.def)
   *   }
   */
  public static FFieldRef read(FStore.Input in) throws IOException
  {
    FPod fpod = in.fpod;
    FTypeRef parent = fpod.typeRef(in.u2());
    String name     = fpod.name(in.u2());
    FTypeRef type   = fpod.typeRef(in.u2());
    return new FFieldRef(parent, name, type);
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  public final FTypeRef parent;
  public String name;
  public final FTypeRef type;
  private String jsig;

}