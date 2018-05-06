//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Dec 05  Brian Frank  Creation
//
package fanx.fcode;

import java.io.*;
import java.util.HashMap;

/**
 * FAttrs is meta-data for a FType of FSlot - we only decode
 * what we understand and ignore anything else.
 */
public class FAttrs
  implements FConst
{

//////////////////////////////////////////////////////////////////////////
// Read
//////////////////////////////////////////////////////////////////////////

  public static FAttrs read(FStore.Input in) throws IOException
  {
    int n = in.u2();
    if (n == 0) return none;
    FAttrs attrs = new FAttrs();
    for (int i=0; i<n; ++i)
    {
      String name = in.name();
      switch (name.charAt(0))
      {
        case 'E':
          if (name.equals(ErrTableAttr)) { attrs.errTable(in); continue; }
          break;
        case 'F':
          if (name.equals(FacetsAttr)) { attrs.facets(in); continue; }
          break;
        case 'L':
          if (name.equals(LineNumberAttr)) { attrs.lineNumber(in); continue; }
          if (name.equals(LineNumbersAttr)) { attrs.lineNumbers(in); continue; }
          break;
        case 'S':
          if (name.equals(SourceFileAttr)) { attrs.sourceFile(in); continue; }
          break;
      }
      int skip = in.u2();
      if (in.skip(skip) != skip) throw new IOException("Can't skip over attr " + name);
    }
    return attrs;
  }

  private void errTable(FStore.Input in) throws IOException
  {
    errTable = FBuf.read(in);
  }

  private void facets(FStore.Input in) throws IOException
  {
    in.u2();
    int n = in.u2();
    facets = new FFacet[n];
    for (int i=0; i<n; ++i)
    {
      FFacet f = facets[i] = new FFacet();
      f.type = in.u2();
      f.val  = in.utf();
    }
  }

  private void lineNumber(FStore.Input in) throws IOException
  {
    in.u2();
    lineNum = in.u2();
  }

  private void lineNumbers(FStore.Input in) throws IOException
  {
    lineNums = FBuf.read(in);
  }

  private void sourceFile(FStore.Input in) throws IOException
  {
    in.u2();
    sourceFile = in.utf();
  }

//////////////////////////////////////////////////////////////////////////
// FFacet
//////////////////////////////////////////////////////////////////////////

  public static class FFacet
  {
    public int type;      // facet type qname index
    public String val;    // serialized facet instance
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  static final FAttrs none = new FAttrs();

  public FBuf errTable;
  public FFacet[] facets;
  public int lineNum;
  public FBuf lineNums;
  public String sourceFile;

}