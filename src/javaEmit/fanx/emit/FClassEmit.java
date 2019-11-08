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
 * FClassEmit emits a normal class type.
 */
public class FClassEmit
  extends FTypeEmit
  implements FConst
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  public FClassEmit(FType type)
  {
    super(type);
  }

//////////////////////////////////////////////////////////////////////////
// Overrides
//////////////////////////////////////////////////////////////////////////

  protected String base()
  {
    // if the base is a generic instance, then this must be a closure
    // func type (since we can't subclass List or Map).  We subclass
    // from one of the canned Func.Indirect inner classes.
    FTypeRef ref = pod.typeRef(type.base);
    if (ref.isGenericInstance())
    {
      if (ref.podName.equals("sys") && ref.typeName.equals("Func")) {
    	  isFuncType = true;
      }
//      this.funcType = (FuncType)Type.find(ref.signature, true);
//      int paramCount = funcType.params.length;
//      if (paramCount  > Func.MaxIndirectParams)
//        return "fan/sys/Func$IndirectX";
//      else
//        return "fan/sys/Func$Indirect" + paramCount;
    }
    
    String base = jname(type.base);
    if (base.equals("java/lang/Object")) return "fan/sys/FanObj";
    if (base.equals("fan/std/Type")) return "fanx/main/Type";
    return base;
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

}