//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Dec 05  Brian Frank  Creation
//
package fanx.fcode;

import java.io.*;
import java.util.*;

/**
 * FMethodVar models one parameter or local variable in a FMethod
 */
public class FMethodVar
  implements FConst
{

//////////////////////////////////////////////////////////////////////////
// Flags
//////////////////////////////////////////////////////////////////////////

  public boolean isParam() { return (flags & Param) != 0; }

//////////////////////////////////////////////////////////////////////////
// IO
//////////////////////////////////////////////////////////////////////////

  public FMethodVar read(FStore.Input in) throws IOException
  {
    name  = in.name();
    type  = in.u2();
    flags = in.u1();

    if (in.fpod.fcodeVer == 0 || in.fpod.fcodeVer > 113) {
      startPos = in.u2();
      scopeLen = in.u2();
    }

    int attrCount = in.u2();
    for (int i=0; i<attrCount; ++i)
    {
      String attrName = in.fpod.name(in.u2());
      FBuf attrBuf = FBuf.read(in);
      if (attrName.equals(ParamDefaultAttr))
        def = attrBuf;
    }
    return this;
  }
  
  public boolean hasDefault() { return (flags & ParamDefault) != 0; }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  public String name;   // variable name
  public int type;      // type qname index
  public int flags;     // method variable flags
  public FBuf def;      // default expression or null (only for params)

  public int startPos;   //start position in bytecode
  public int scopeLen;
}