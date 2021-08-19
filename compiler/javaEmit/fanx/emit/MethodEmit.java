//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Sep 05  Brian Frank  Creation
//
package fanx.emit;

import java.util.*;
import fanx.util.*;

/**
 * MethodEmit is used to emit a method for the class file.
 */
public class MethodEmit
  implements EmitConst
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  MethodEmit(Emitter emit, String sig, int name, int type, int flags)
  {
    this.emit  = emit;
    this.sig   = sig;
    this.name  = name;
    this.type  = type;
    this.flags = flags;
    this.attrs = new ArrayList(4);
  }

//////////////////////////////////////////////////////////////////////////
// Public
//////////////////////////////////////////////////////////////////////////

  /**
   * Get top level Emitter instance.
   */
  public Emitter getEmitter()
  {
    return emit;
  }

  /**
   * Get this field as a MethodRef constant pool index.
   */
  public int ref()
  {
    if (ref == 0) ref = emit.method(sig);
    return ref;
  }

  /**
   * Get the CodeEmit instance used to emit the byte
   * code to execute for this method.
   */
  public CodeEmit emitCode()
  {
    if (code != null) throw new IllegalStateException();
    code  = new CodeEmit(this);
    attrs.add(code);
    return code;
  }

  /**
   * Define a new attribute section for the method.
   * Use AttrEmit.info to populate the data.
   */
  public AttrEmit emitAttr(String name)
  {
    AttrEmit attr = new AttrEmit(emit, emit.utf(name));
    attrs.add(attr);
    return attr;
  }

  /**
   * String signature.
   */
  public String toString()
  {
    return sig;
  }

//////////////////////////////////////////////////////////////////////////
// Pack
//////////////////////////////////////////////////////////////////////////

  void pack(Box box)
  {
    box.u2(flags);
    box.u2(name);
    box.u2(type);
    box.u2(attrs.size());
    for (int i=0; i<attrs.size(); ++i)
      ((AttrEmit)attrs.get(i)).pack(box);
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  final Emitter emit;
  final String sig;
  final int name;
  final int type;
  final int flags;
  final ArrayList attrs;
  int ref = 0;
  private CodeEmit code;

}