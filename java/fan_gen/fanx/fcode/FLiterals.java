//
// Copyright (c) 2007, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   30 Dec 07  Brian Frank  Creation
//
package fanx.fcode;

import java.io.*;
import java.math.*;
import java.util.*;
import java.util.zip.*;
import fanx.util.*;

/**
 * FLiterals manages the Int, Float, Duration, Str,
 * and Uri literal constants.
 */
public final class FLiterals
  implements FConst
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  public FLiterals(FPod fpod)
  {
    this.fpod = fpod;
    this.ints       = new FTable.Ints(fpod);
    this.floats     = new FTable.Floats(fpod);
//    this.decimals   = new FTable.Decimals(fpod);
    this.strs       = new FTable.Strs(fpod);
//    this.durations  = new FTable.Durations(fpod);
//    this.uris       = new FTable.Uris(fpod);
  }

//////////////////////////////////////////////////////////////////////////
// Read
//////////////////////////////////////////////////////////////////////////

  public FLiterals read() throws IOException
  {
    ints.read(fpod.store.read("fcode/ints.def"));
    floats.read(fpod.store.read("fcode/floats.def"));
//    decimals.read(fpod.store.read("fcode/decimals.def"));
    strs.read(fpod.store.read("fcode/strs.def"));
//    durations.read(fpod.store.read("fcode/durations.def"));
//    uris.read(fpod.store.read("fcode/uris.def"));
    return this;
  }

//////////////////////////////////////////////////////////////////////////
// Tables
//////////////////////////////////////////////////////////////////////////

  public final Long integer(int index)      { return (Long)ints.get(index); }
  public final Double floats(int index)     { return (Double)floats.get(index); }
//  public final BigDecimal decimals(int index) { return (BigDecimal)decimals.get(index); }
  public final String str(int index)        { return (String)strs.get(index); }
//  public final String duration(int index) { return (String)durations.get(index); }
//  public final String uri(int index)           { return (String)uris.get(index); }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  public FPod fpod;         // parent pod
  public FTable ints;       // Long literals
  public FTable floats;     // Float literals
//  public FTable decimals;   // Decimal literals
  public FTable strs;       // String literals
//  public FTable durations;  // Duration literals
//  public FTable uris;       // Uri literals

}