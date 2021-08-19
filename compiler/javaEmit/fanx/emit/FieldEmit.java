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
 * FieldEmit is used to emit a field to the class file definition.
 */
public class FieldEmit
  implements EmitConst
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  FieldEmit(Emitter emit, String sig, int name, int type, int flags)
  {
    this.emit  = emit;
    this.sig   = sig;
    this.name  = name;
    this.type  = type;
    this.flags = flags;
    this.attrs = null;
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
   * Get this field as a FieldRef constant pool index.
   */
  public int ref()
  {
    if (ref == 0) ref = emit.field(sig);
    return ref;
  }

  /**
   * Define a new attribute section for the field.
   * Use AttrEmit.info to populate the data.
   */
  public AttrEmit emitAttr(String name)
  {
    if (attrs == null) attrs = new ArrayList(4);
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
    if (attrs == null)
    {
      box.u2(0);
    }
    else
    {
      box.u2(attrs.size());
      for (int i=0; i<attrs.size(); ++i)
        ((AttrEmit)attrs.get(i)).pack(box);
    }
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  final Emitter emit;
  final String sig;
  final int name;
  final int type;
  final int flags;
  ArrayList attrs;
  int ref = 0;


}