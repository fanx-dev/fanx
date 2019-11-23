//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-5-18 Jed Young Creation
//
package fan.std;

import java.io.BufferedInputStream;
import java.io.DataInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PushbackInputStream;
import java.io.Reader;

import fan.sys.IOErr;

public class SysInStreamPeer {

  InputStream inputStream;

  static class JInputStream extends InputStream {
    InStream in;

    public JInputStream(InStream in) {
      this.in = in;
    }

    @Override
    public int read() throws IOException {
      return (int)in.read();
    }

    @Override
    public int read(byte b[], int off, int len) {
      byte[] ba = b;
      int res = (int)in.readBytes(ba, off, len);
      return res;
    }

    @Override
    public long skip(long n) {
      return (int)in.skip(n);
    }

    @Override
    public int available() {
      return (int)in.avail();
    }

    @Override
    public void close() {
      in.close();
    }
  }

  public static InputStream toJava(InStream in) {
    if (in instanceof SysInStream) {
      SysInStreamPeer peer = (SysInStreamPeer)((SysInStream)in).peer;
      return peer.inputStream;
    }
    return new JInputStream(in);
  }


  private void init(InputStream in) {
    inputStream = in;
//    java.nio.charset.Charset jcharset = java.nio.charset.Charset.forName(c.name);
//    inputReader = new InputStreamReader(in, jcharset);
//    dataStream = new DataInputStream(in);
  }

  static SysInStreamPeer make(SysInStream self) {
    return new SysInStreamPeer();
  }

  public static InStream fromJava(InputStream in) {
    return fromJava(in, Endian.big, Charset.utf8, 0);
  }

  public static InStream fromJava(InputStream in, long bufSize) {
    return fromJava(in, Endian.big, Charset.utf8, bufSize);
  }

  public static InStream fromJava(InputStream in, Endian e, Charset c, long bufSize) {
    SysInStream sin = SysInStream.make(e, c);
    if (bufSize > 0) {
      in = new BufferedInputStream(in, (int) bufSize);
    }
    ((SysInStreamPeer)sin.peer).init(in);
    return sin;
  }

  public long avail(SysInStream self) {
    try {
      return this.inputStream.available();
    } catch (IOException e) {
      throw IOErr.make(e);
    }
  }

  public long read(SysInStream self) {
    try {
      long res = this.inputStream.read();
//      if (res == -1) return FanInt.invalidVal;
      return res;
    } catch (IOException e) {
      throw IOErr.make(e);
    }
  }

  public long skip(SysInStream self, long n) {
    try
      {
        long skipped = 0;
        while (skipped < n)
        {
          long x = this.inputStream.skip(n-skipped);
          if (x < 0) break;
          skipped += x;
        }
        return skipped;
      }
      catch (IOException e)
      {
        throw IOErr.make(e);
      }
  }

  public long readBytes(SysInStream self, byte[] ba, long off, long len) {
    try {
      return this.inputStream.read(ba, (int)off, (int)len);
    } catch (IOException e) {
      throw IOErr.make(e);
    }
  }

  private void unreadF(int n) throws IOException {
    if (this.inputStream instanceof PushbackInputStream) {
      ((PushbackInputStream) this.inputStream).unread(n);
    } else {
      PushbackInputStream p = new PushbackInputStream(this.inputStream, 128);
      this.init(p);
      ((PushbackInputStream) this.inputStream).unread(n);
    }
  }

  public InStream unread(SysInStream self, long n) {
    try {
      unreadF((int) n);
      return self;
    } catch (IOException e) {
      throw IOErr.make(e);
    }
  }

  public boolean close(SysInStream self) {
    try {
      this.inputStream.close();
      return true;
    } catch (IOException e) {
      return false;
    }
  }

  //used by InStream
  public static long toSigned(long val, long num) {
    switch ((int)num) {
    case 1:
      return (byte)val;
    case 2:
      return (short)val;
    case 4:
      return (int)val;
    }
    return val;
  }
}