//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Sep 05  Brian Frank  Creation
//
package fanx.emit;

import java.util.*;
import fanx.util.*;

/**
 * CodeEmit is used to emit the bytecode implementation of a
 * method.  See Emitter.emitMethod and MethodEmit.emitCode().
 */
public class CodeEmit
  extends AttrEmit
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  CodeEmit(MethodEmit method)
  {
    super(method.emit, method.emit.utf("Code"));
    this.method = method;
    reset();
  }

  void reset()
  {
    // prefill the beginning of the info buffer
    // and backfill the values in pack()
    info.len = 0;
    info.u2(-1);  // max stack
    info.u2(-1);  // max locals
    info.u4(-1);  // code length
  }

//////////////////////////////////////////////////////////////////////////
// Convenience
//////////////////////////////////////////////////////////////////////////

  public Emitter emit()
  {
    return method.emit;
  }

//////////////////////////////////////////////////////////////////////////
// Attributes
//////////////////////////////////////////////////////////////////////////

  /**
   * Define a new attribute section for the code.
   * Use AttrEmit.info to populate the data.
   */
  public AttrEmit emitAttr(String name)
  {
    if (attrs == null) attrs = new ArrayList(4);
    AttrEmit attr = new AttrEmit(emit, emit.utf(name));
    attrs.add(attr);
    return attr;
  }

  /**
   * Emit a LineNumberTable attribute where the entire
   * method body has one line number.
   */
  public void emitLineNumber(int lineNum)
  {
    if (lineNum <= 0) return;
    AttrEmit attr = emitAttr("LineNumberTable");
    attr.info.u2(1);       // attribute_length
    attr.info.u2(0);       // start_pc
    attr.info.u2(lineNum); // line_number
  }

//////////////////////////////////////////////////////////////////////////
// Pack
//////////////////////////////////////////////////////////////////////////

  /**
   * Return the current position in bytecode which is the current
   * working length of the code buffer minus 8 bytes for the Header
   */
  public int pos()
  {
    return info.len - Header;
  }

  /**
   * Append the specified opcode.
   */
  public void op(int opcode)
  {
    info.u1(opcode);
  }

  /**
   * Append the specified opcode with a 1 byte arg
   */
  public void op1(int opcode, int arg)
  {
    info.u1(opcode);
    info.u1(arg);
  }

  /**
   * Append the specified opcode with a 2 byte arg
   */
  public void op2(int opcode, int arg)
  {
    info.u1(opcode);
    info.u2(arg);
  }

  /**
   * Append the specified opcode with a two 1 byte arguments
   */
  public void op11(int opcode, int arg1, int arg2)
  {
    info.u1(opcode);
    info.u1(arg1);
    info.u1(arg2);
  }

  /**
   * Pad to ensure next byte written is aligned on 4 byte
   * boundary (see tableswitch).
   */
  public final int padAlign4()
  {
    int pad = 3 - (info.len-1) % 4;
    for (int i=0; i<pad; ++i) info.u1(0);
    return pad;
  }

  /**
   * Append the specified branch opcode, and return
   * a label which may used to mark() the destination.
   */
  public int branch(int opcode)
  {
    int label = info.len+1;
    info.u1(opcode);
    info.u2(0xFFFF);
    return label;
  }

  /**
   * Mark the current location (next opcode) as the
   * destination of the specified label.
   */
  public void mark(int label)
  {
    int dest = info.len;
    int jump = dest - label + 1;

    if (jump < Short.MIN_VALUE || jump > Short.MAX_VALUE)
      throw new IllegalStateException("Jump exceeds two bytes: " + jump);

    info.u2(label, jump);
  }

  /**
   * Convenience for invoking specified static method.
   */
  public void invokeStatic(String method)
  {
    op2(INVOKESTATIC, emit.method(method));
  }

  /**
   * Convenience for invoking specified virtual method.
   */
  public void invokeVirtual(String method)
  {
    op2(INVOKEVIRTUAL, emit.method(method));
  }

//////////////////////////////////////////////////////////////////////////
// Pack
//////////////////////////////////////////////////////////////////////////

  void pack(Box box)
  {
    if (maxStack < 0 || maxLocals < 0)
    {
      System.out.println("maxStack, maxLocals not set " + method.emit.className + "." + method.sig);
      if (maxStack < 0) maxStack = 16;
      if (maxLocals < 0) maxLocals = 16;
    }

    // at this point the info buffer has some blank fields
    // at the beginning we need to backpatch, plus the actual
    // bytecode which was directly appended into info; for now
    // we the code length is current length minus the
    // first 3 fields lengths
    info.u2(0, maxStack);
    info.u2(2, maxLocals);
    info.u4(4, info.len-2-2-4);

    // code already appended into buffer

    // exception table
    if (exceptionTable != null)
      info.append(exceptionTable);
    else
      info.u2(0);

    // attributes
    if (attrs == null) info.u2(0);
    else
    {
      info.u2(attrs.size());
      for (int i=0; i<attrs.size(); ++i)
      {
        AttrEmit a = (AttrEmit)attrs.get(i);
        ((AttrEmit)attrs.get(i)).pack(info);
      }
    }

    // debug to see where lineNums are not being emitted
    /*
    boolean lineNums = false;
    for (int i=0; attrs != null && i<attrs.size(); ++i)
    {
      AttrEmit a = (AttrEmit)attrs.get(i);
      String n = emit.utfToStr(a.name);
      if (n.equals("LineNumberTable")) { lineNums = true; break; }
    }
    if (!lineNums) System.out.println(">> " + method.sig);
    */

    // now the info box is correctly populated, do
    // normal attribute packing
    super.pack(box);
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  // header size is 8 bytes = 2 max stack + 2 max locals + 4 code length
  public static final int Header = 8;

  final MethodEmit method;

  public int maxStack  = -1;
  public int maxLocals = -1;
  Box exceptionTable;
  ArrayList attrs;

}