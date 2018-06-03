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
import fanx.util.*;

/**
 * FCodePrinter prints a human readable syntax for fcode
 */
public class FCodePrinter
  extends PrintWriter
  implements FConst
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  public FCodePrinter(FPod pod, OutputStream out)
  {
    super(out);
    this.pod = pod;
  }

  public FCodePrinter(FPod pod, Writer out)
  {
    super(out);
    this.pod = pod;
  }

  public FCodePrinter(FPod pod)
  {
    this(pod, System.out);
  }

//////////////////////////////////////////////////////////////////////////
// Print
//////////////////////////////////////////////////////////////////////////

  public void code(FBuf code)
  {
    try
    {
      this.code = code;
      this.in   = new DataInputStream(new ByteArrayInputStream(code.buf, 0, code.len));

      if (false)
      {
        int c;
        while ((c = in.read()) >= 0)
          println("  0x" + c);
        return;
      }

      int op;
      while ((op = in.read()) >= 0)
      {
        n++;
        op(op);
      }
    }
    catch (IOException e)
    {
      e.printStackTrace();
    }

    flush();

    this.code = null;
    this.in   = null;
  }

  private void op(int opcode)
    throws IOException
  {
    if (opcode >= ops.length)
      throw new IllegalStateException("Unknown opcode: " + opcode);
    Op op = ops[opcode];
    print("    " + StrUtil.padl(""+(n-1), 3) + ": " + StrUtil.padr(op.name,16) + " ");
    if (opcode == Switch) printSwitch();
    else switch (op.arg)
    {
      case None:     break;
      case Int:      print(integer()); break;
      case Float:    print(floatpt()); break;
      case Str:      print(str()); break;
      case Dur:      print(duration()); break;
      case Uri:      print(uri()); break;
      case Reg:      print(u2()); break;
      case Type:     print(type()); break;
      case Field:    print(field()); break;
      case Method:   print(method()); break;
      case Jmp:      print(jmp()); break;
      case Deciaml:  print(deciaml()); break;
      case Other: print("OTHER"); break;
      default: throw new IllegalStateException(op.sig);
    }
    println();
  }

  private void printSwitch()
    throws IOException
  {
    int count = u2();
    for (int i=0; i<count; ++i)
    {
      println();
      print("          " + i + " -> " + u2());
    }
  }

//////////////////////////////////////////////////////////////////////////
// Sig
//////////////////////////////////////////////////////////////////////////

  static final int None     = -1;
  static final int Int      = 0;
  static final int Float    = 1;
  static final int Str      = 2;
  static final int Dur      = 3;
  static final int Uri      = 4;
  static final int Reg      = 5;
  static final int Type     = 6;
  static final int Field    = 7;
  static final int Method   = 8;
  static final int Jmp      = 9;
  static final int Deciaml = 10;
  static final int Other = 11;

  static final Op[] ops;
  static
  {
    ops = new Op[OpNames.length];
    for (int i=0; i<ops.length; ++i)
      ops[i] = new Op(i);
  }

  static class Op
  {
    Op(int id)
    {
      this.id   = id;
      this.name = OpNames[id];
      this.sig  = OpSigs[id];
      arg = parseArg(sig);
    }

    int id;
    String name;
    String sig;
    int arg;
  }

  static int parseArg(String sig)
  {
    if (sig.equals("()"))       return None;
    if (sig.equals("(int)"))    return Int;
    if (sig.equals("(float)"))  return Float;
    if (sig.equals("(str)"))    return Str;
    if (sig.equals("(dur)"))    return Dur;
    if (sig.equals("(uri)"))    return Uri;
    if (sig.equals("(reg)"))    return Reg;
    if (sig.equals("(type)"))   return Type;
    if (sig.equals("(field)"))  return Field;
    if (sig.equals("(method)")) return Method;
    if (sig.equals("(jmp)"))    return Jmp;
    if (sig.equals("(decimal)"))    return Deciaml;
    return Other;
    //throw new IllegalStateException(sig);
  }

//////////////////////////////////////////////////////////////////////////
// IO
//////////////////////////////////////////////////////////////////////////

  private int u1()  throws IOException { n +=1; return in.readByte(); }
  private int u2()  throws IOException { n +=2; return in.readUnsignedShort(); }
  private int u4()  throws IOException { n +=4; return in.readInt(); }

  private String integer()
    throws IOException
  {
    int index = u2();
    try
    {
      return pod.literals.integer(index).toString() + showIndex(index);
    }
    catch (Exception e)
    {
      return "Error [" + index + "]";
    }
  }

  private String floatpt()
    throws IOException
  {
    int index = u2();
    try
    {
      return pod.literals.floats(index).toString() + showIndex(index);
    }
    catch (Exception e)
    {
      return "Error [" + index + "]";
    }
  }

  private String str()
    throws IOException
  {
    int index = u2();
    try
    {
      return pod.literals.str(index).toString() + showIndex(index);
    }
    catch (Exception e)
    {
      return "Error [" + index + "]";
    }
  }

  private String duration()
    throws IOException
  {
    int index = u2();
    try
    {
      return pod.literals.duration(index).toString() + showIndex(index);
    }
    catch (Exception e)
    {
      return "Error [" + index + "]";
    }
  }

  private String uri()
    throws IOException
  {
    int index = u2();
    try
    {
      return pod.literals.uri(index).toString() + showIndex(index);
    }
    catch (Exception e)
    {
      return "Error [" + index + "]";
    }
  }
  
  private String deciaml()
    throws IOException
  {
    int index = u2();
    try
    {
      return pod.literals.decimals(index).toString() + showIndex(index);
    }
    catch (Exception e)
    {
      return "Error [" + index + "]";
    }
  }

  private String type()
    throws IOException
  {
    int index = u2();
    try
    {
      return pod.typeRefs.toString(index) + showIndex(index);
    }
    catch (Exception e)
    {
      return "Error [" + index + "]";
    }
  }

  private String field()
    throws IOException
  {
    int index = u2();
    try
    {
      return pod.fieldRefs.toString(index) + showIndex(index);
    }
    catch (Exception e)
    {
      return "Error [" + index + "]";
    }
  }

  private String method()
    throws IOException
  {
    int index = u2();
    try
    {
      return pod.methodRefs.toString(index) + showIndex(index);
    }
    catch (Exception e)
    {
      return "Error [" + index + "]";
    }
  }

  private String jmp()
    throws IOException
  {
    int jmp = u2();
    return ""+jmp;
  }

  private String showIndex(int index)
  {
    if (showIndex) return "[" + index + "]";
    return "";
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  public final FPod pod;
  public boolean showIndex;
  private FBuf code;
  private DataInputStream in;
  private int n;


}