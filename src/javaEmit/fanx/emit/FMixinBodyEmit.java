//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Mar 06  Brian Frank  Creation
//
package fanx.emit;

import java.util.*;
import fanx.fcode.*;
import fanx.util.*;

/**
 * FMixinBodyEmit emits the class body of a mixin type.
 */
public class FMixinBodyEmit
  extends FTypeEmit
  implements FConst
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  public FMixinBodyEmit(FType type)
  {
    super(type);
  }

//////////////////////////////////////////////////////////////////////////
// Overrides
//////////////////////////////////////////////////////////////////////////

  public Box emit()
  {
    init(jname(type.self)+"$", base(), new String[0], PUBLIC|FINAL);
    this.selfName = jname(type.self);
    for (int i=0; i<type.fields.length; ++i)  emit(type.fields[i]);
    for (int i=0; i<type.methods.length; ++i) emit(type.methods[i]);
    emitAttributes(type.attrs);
    emitTypeConstFields();
    return classFile = pack();
  }

  protected String base()
  {
    return "java/lang/Object";
  }

//////////////////////////////////////////////////////////////////////////
// Field
//////////////////////////////////////////////////////////////////////////

  /**
   * Only emit static fields (stored on body, not interface)
   */
  protected void emit(FField f)
  {
    if ((f.flags & FConst.Static) != 0)
      super.emit(f);
  }

//////////////////////////////////////////////////////////////////////////
// Method
//////////////////////////////////////////////////////////////////////////

  private void emit(FMethod m)
  {
    String name = m.name;
    if (name.equals("static$init"))   { emitStaticInit(m); return; }

    new FMethodEmit(this, m).emitMixinBody();
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

}