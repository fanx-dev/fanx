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
 * FPod is the read/write fcode representation of sys::Pod.
 */
public class FPrinter
  extends PrintWriter
  implements FConst
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  public FPrinter(FPod pod, OutputStream out)
  {
    super(out);
    this.pod = pod;
  }

  public FPrinter(FPod pod)
  {
    this(pod, System.out);
  }

//////////////////////////////////////////////////////////////////////////
// Dump
//////////////////////////////////////////////////////////////////////////

  public void all()
  {
    tables();
    types();
    flush();
  }

//////////////////////////////////////////////////////////////////////////
// Const Tables
//////////////////////////////////////////////////////////////////////////

  public void tables()
  {
    println("##### Tables #####");
    println("--- names ---");      pod.names.dump(pod, this);
    println("--- typeRefs ---");   pod.typeRefs.dump(pod, this);
    println("--- fieldRefs ---");  pod.fieldRefs.dump(pod, this);
    println("--- methodRefs ---"); pod.methodRefs.dump(pod, this);
    println("--- ints ---");       pod.literals.ints.dump(pod, this);
    println("--- floats ---");     pod.literals.floats.dump(pod, this);
    println("--- strs ---");       pod.literals.strs.dump(pod, this);
    println("--- durations ---");  pod.literals.durations.dump(pod, this);
    println("--- uris ---");       pod.literals.uris.dump(pod, this);
    flush();
  }

//////////////////////////////////////////////////////////////////////////
// Types
//////////////////////////////////////////////////////////////////////////

  public void types()
  {
    println("##### Types #####");
    for (int i=0; i<pod.types.length; ++i)
      type(pod.types[i]);
    flush();
  }

  public void type(FType type)
  {
    println("--" + typeRef(type.self) + " extends " + typeRef(type.base) + "--");
    if (type.mixins.length > 0)
    {
      print("  mixin ");
      for (int i=0; i<type.mixins.length; ++i)
      {
        if (i > 0) print(", ");
        print(typeRef(type.mixins[i]));
      }
      println();
    }
    attrs(type.attrs);
    println();
    for (int i=0; i<type.fields.length; ++i)  field(type.fields[i]);
    for (int i=0; i<type.methods.length; ++i) method(type.methods[i]);
    flush();
  }

  public void slot(FSlot s)
  {
    if (s instanceof FField)
      field((FField)s);
    else
      method((FMethod)s);
    flush();
  }

  public void field(FField f)
  {
    println("  " + typeRef(f.type) + " " + f.name + " [" + StrUtil.flagsToString(f.flags).trim() + "]");
    attrs(f.attrs);
    println();
  }

  public void method(FMethod m)
  {
    print("  " + typeRef(m.ret) + " " + m.name + "(");
    FMethodVar[] params = m.params();
    for (int i=0; i<params.length; ++i)
    {
      FMethodVar p = params[i];
      if (i > 0) print(", ");
      print(typeRef(p.type) + " " + p.name);
    }
    println(") [" + StrUtil.flagsToString(m.flags).trim() + "]");
    for (int i=0; i<m.vars.length; ++i)
    {
      FMethodVar v = m.vars[i];
      String role = v.isParam() ?  "Param" : "Local";
      int reg = i + ((m.flags & FConst.Static) != 0 ? 0 : 1);
      println("    [" + role + " " + reg + "] " + v.name + ": " + typeRef(v.type));
      if (v.def != null) code(v.def);
    }
    if (m.code != null)
    {
      println("    [Code]");
      code(m.code);
    }
    attrs(m.attrs);
    println();
  }

  public void code(FBuf code)
  {
    if (!showCode) return;
    flush();
    new FCodePrinter(pod, out).code(code);
  }


//////////////////////////////////////////////////////////////////////////
// Facets
//////////////////////////////////////////////////////////////////////////

  public void attrs(FAttrs attrs)
  {
  }
  /*
    if (attrs == null) return;
    for (int i=0; i<attrs.length; ++i)
      attr(attrs[i]);
  }

  public void attr(FAttr attr)
  {
    String name = name(attr.name);
    if (name.equals(LineNumbersAttr) && !showLines) return;
    println("    [" + name + "] len=" + attr.data.len);
    if (name.equals(SourceFileAttr))  sourceFile(attr);
    if (name.equals(ErrTableAttr))    errTable(attr);
    if (name.equals(LineNumbersAttr)) lineNumbers(attr);
    if (name.equals(FacetsAttr))      facets(attr);
  }

  public void sourceFile(FAttr attr)
  {
    println("      " + attr.data.utf());
  }

  public void facets(FAttr attr)
  {
    println("     TODO");
  }

  public void errTable(FAttr attr)
  {
    byte[] buf = attr.data.buf;
    int len = attr.data.len;
    int count = buf[0] << 8 | buf[1];
    for (int i=2; i<len; i += 8)
    {
      int start   = buf[i+0] << 8 | buf[i+1];
      int end     = buf[i+2] << 8 | buf[i+3];
      int handler = buf[i+4] << 8 | buf[i+5];
      flush();
      String type = typeRef(buf[i+6] << 8 | buf[i+7]);
      println("      " + start + " to " + end + " -> " + handler + "  " + type);
    }
  }

  public void lineNumbers(FAttr attr)
  {
    byte[] buf = attr.data.buf;
    int len = attr.data.len;
    int count = buf[0] << 8 | buf[1];
    //println("      count=" + count);
    for (int i=2; i<len; i += 4)
    {
      int pc   = buf[i+0] << 8 | buf[i+1];
      int line = buf[i+2] << 8 | buf[i+3];
      println("      " + pc + ": " + line);
    }
  }
  */

//////////////////////////////////////////////////////////////////////////
// Dump Utils
//////////////////////////////////////////////////////////////////////////

  private String typeRef(int index)
  {
    if (index == 65535) return "null";
    return pod.typeRefs.toString(index) + showIndex(index);
  }

  private String name(int index)
  {
    return pod.name(index) + showIndex(index);
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
  public boolean showIndex = false;
  public boolean showCode  = true;
  public boolean showLines = false;

}