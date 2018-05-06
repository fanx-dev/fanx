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
 * FMixinInterfaceEmit emits the interface of a mixin type.
 */
public class FMixinInterfaceEmit
  extends FTypeEmit
  implements FConst
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  public FMixinInterfaceEmit(FType type)
  {
    super(type);
  }

//////////////////////////////////////////////////////////////////////////
// Overrides
//////////////////////////////////////////////////////////////////////////

  public Box emit()
  {
    init(jname(type.self), base(), mixins(), jflags(type.flags));
    for (int i=0; i<type.methods.length; ++i) emit(type.methods[i]);
    return classFile = pack();
  }

  String[] mixins()
  {
    String[] mixins = new String[type.mixins.length];
    for (int i=0; i<mixins.length; ++i)
      mixins[i] = jname(type.mixins[i]);
    return mixins;
  }

  String base()
  {
    return "java/lang/Object";
  }

//////////////////////////////////////////////////////////////////////////
// Method
//////////////////////////////////////////////////////////////////////////

  private void emit(FMethod m)
  {
    new FMethodEmit(this, m).emitMixinInterface();
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

}