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
 * FField is the fcode representation of sys::Field.
 */
public class FField
  extends FSlot
{

  public FField read(FStore.Input in) throws IOException
  {
    super.readCommon(in);
    type = in.u2();
    super.readAttrs(in);
    return this;
  }

  public int type;       // type qname index

}