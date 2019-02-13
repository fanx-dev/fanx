//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Dec 05  Brian Frank  Creation
//
package fanx.fcode;

import java.io.*;
import fanx.util.*;

/**
 * FBuf stores a byte buffer (such as executable fcode, or line numbers)
 */
public class FBuf
  implements FConst
{

//////////////////////////////////////////////////////////////////////////
// Constructors
//////////////////////////////////////////////////////////////////////////

  public FBuf(Box box)
  {
    this.buf = box.buf;
    this.len = box.len;
  }

  public FBuf(byte[] buf, int len)
  {
    this.buf = buf;
    this.len = len;
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  public int u2()
  {
    return buf[0] << 16 | buf[1];
  }

  public String utf()
  {
    try
    {
      DataInputStream in = new DataInputStream(new ByteArrayInputStream(buf, 0, len));
      return in.readUTF();
    }
    catch (IOException e)
    {
      throw new RuntimeException(e.toString(), e);
    }
  }

//////////////////////////////////////////////////////////////////////////
// IO
//////////////////////////////////////////////////////////////////////////

  public static FBuf read(FStore.Input in) throws IOException
  {
    int len = in.u2();
    if (len == 0) return null;

    byte[] buf = new byte[len];
    in.readFully(buf, 0, len);

    return new FBuf(buf, len);
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  public byte[] buf;
  public int len;

}
