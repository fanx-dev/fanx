//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   27 Dec 05  Brian Frank  Creation
//
package fanx.emit;

import java.util.*;
import fanx.fcode.*;
import fanx.main.Sys;
import fanx.util.*;

/**
 * FCodeEmit translates FCode fcode to Java bytecode.
 */
public class FCodeEmit
  implements EmitConst, FConst
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  public FCodeEmit(FTypeEmit parent, FMethod fmethod, CodeEmit code)
  {
    this(parent, fmethod.code, code,
         initRegs(parent, fmethod.isStatic(), fmethod.vars),
         parent.pod.typeRef(fmethod.ret));
    this.fmethod  = fmethod;
    code.maxStack = fmethod.maxStack * 2; // TODO: how should we handle wide items on stack?
  }

  public FCodeEmit(FTypeEmit parent, FBuf fcode, CodeEmit code, Reg[] regs, FTypeRef ret)
  {
    this.pod        = parent.pod;
    this.parent     = parent;
    this.buf        = fcode.buf;
    this.len        = fcode.len;
    this.emit       = code.emit;
    this.code       = code;
    this.podClass   = "fan/" + pod.podName + "/$Pod";
    this.reloc      = new int[len];
    this.regs       = regs;
    this.ret        = ret;
    code.maxLocals  = maxLocals(regs);
  }

//////////////////////////////////////////////////////////////////////////
// Overrides
//////////////////////////////////////////////////////////////////////////

  /**
   * Translate fcode to Java bytecode.
   */
  public void emit()
  {
    emitInstructions();
    backpatch();
    errTable();
    lineTable();
    localVarTable();
  }

  /**
   * Map fcode instructions to Java bytecode instructions.
   */
  private void emitInstructions()
  {
    while (pos < len)
    {
      int opcode = consumeOp();
      switch (opcode)
      {
        case Nop:                 code.op(NOP); break;
        case LoadNull:            code.op(ACONST_NULL); break;
        case LoadFalse:           loadFalse(); break;
        case LoadTrue:            loadTrue(); break;
        case LoadInt:             loadInt(); break;
        case LoadFloat:           loadFloat(); break;
        case LoadDecimal:         loadDecimal(); break;
        case LoadStr:             loadStr(); break;
        case LoadDuration:        loadDuration(); break;
        case LoadUri:             loadUri(); break;
        case LoadType:            loadType(); break;

        case LoadVar:             loadVar(); break;
        case StoreVar:            storeVar(); break;

        // route field access to FFieldRef
        case LoadInstance:        pod.fieldRef(u2()).emitLoadInstance(code); break;
        case StoreInstance:       pod.fieldRef(u2()).emitStoreInstance(code); break;
        case LoadStatic:          pod.fieldRef(u2()).emitLoadStatic(code); break;
        case StoreStatic:         pod.fieldRef(u2()).emitStoreStatic(code); break;
        case LoadMixinStatic:     pod.fieldRef(u2()).emitLoadMixinStatic(code); break;
        case StoreMixinStatic:    pod.fieldRef(u2()).emitStoreMixinStatic(code); break;

        // route method calls to FMethodRef
        case CallNew:             pod.methodRef(u2()).emitCallNew(code); break;
        case CallCtor:            pod.methodRef(u2()).emitCallCtor(code); break;
        case CallStatic:          pod.methodRef(u2()).emitCallStatic(code); break;
        case CallVirtual:         pod.methodRef(u2()).emitCallVirtual(code); break;
        case CallNonVirtual:      pod.methodRef(u2()).emitCallNonVirtual(code, parent.type); break;
        case CallSuper:           pod.methodRef(u2()).emitCallSuper(code, parent.type); break;
        case CallMixinStatic:     pod.methodRef(u2()).emitCallMixinStatic(code); break;
        case CallMixinVirtual:    pod.methodRef(u2()).emitCallMixinVirtual(code); break;
        case CallMixinNonVirtual: pod.methodRef(u2()).emitCallMixinNonVirtual(code); break;

        case Jump:                jump(); break;
        case JumpTrue:            jumpTrue(); break;
        case JumpFalse:           jumpFalse(); break;

        case CompareEQ:           compareEQ(); break;
        case CompareNE:           compareNE(); break;
        case Compare:             compare(); break;
        case CompareLT:           compareLT(); break;
        case CompareLE:           compareLE(); break;
        case CompareGE:           compareGE(); break;
        case CompareGT:           compareGT(); break;
        case CompareSame:         compareSame(); break;
        case CompareNotSame:      compareNotSame(); break;
        case CompareNull:         compareNull(); break;
        case CompareNotNull:      compareNotNull(); break;

        case Return:              returnOp(); break;
        case Pop:                 pop(); break;
        case Dup:                 dup(); break;
        case Is:                  is(); break;
        case As:                  as(); break;
        case Coerce:              coerce(); break;
        case Switch:              tableswitch(); break;

        case Throw:               doThrow(); break;
        case Leave:               jump(); break;  // no diff than Jump in Java
        case _JumpFinally:        jumpFinally(); break;
        case CatchAllStart:       code.op(POP); break;
        case CatchErrStart:       catchErrStart(); break;
        case _CatchEnd:           break;
        case FinallyStart:        finallyStart(); break;
        case FinallyEnd:          finallyEnd(); break;

        default: throw new IllegalStateException(opcode < OpNames.length ? OpNames[opcode] : "bad opcode=" + opcode);
      }
    }
  }

  /**
   * Back patch fcode to bytecode jumps
   */
  private void backpatch()
  {
    JumpNode j = jumps;
    while (j != null)
    {
      int javaLoc = reloc[j.fcodeLoc];
      int jsrOffset = j.isFinally ? 8 : 0;  // see startFinally()
      if (j.size == 2)
        code.info.u2(j.javaMark+CodeEmit.Header, javaLoc-j.javaFrom+jsrOffset);
      else
        code.info.u4(j.javaMark+CodeEmit.Header, javaLoc-j.javaFrom);
      j = j.next;
    }
  }

//////////////////////////////////////////////////////////////////////////
// Attribute Tables
//////////////////////////////////////////////////////////////////////////

  /**
   * Process error table (if specified).  We handle catches of Err using
   * a catch any (0 class index).  We also need to add extra entries into
   * the exception table for special exceptions - for example NullErr get's
   * mapped as fan.sys.NullErr and java.lang.NullPointerException.
   */
  private void errTable()
  {
    if (fmethod == null) return;
    FBuf ferrs = fmethod.attrs.errTable;
    if (ferrs== null) return;

    int len = ferrs.len;
    byte[] buf = ferrs.buf;
    int count = (len-2)/8;
    Box java = new Box(new byte[len], 0);
    java.u2(count);

    for (int i=2; i<len; i += 8)
    {
      int start = reloc[(buf[i+0] & 0xFF) << 8 | (buf[i+1] & 0xFF)];
      int end   = reloc[(buf[i+2] & 0xFF) << 8 | (buf[i+3] & 0xFF)];
      int trap  = reloc[(buf[i+4] & 0xFF) << 8 | (buf[i+5] & 0xFF)];

      java.u2(start);
      java.u2(end);
      java.u2(trap);

      int typeRefId = (buf[i+6] & 0xFF) << 8 | (buf[i+7] & 0xFF);
      FTypeRef typeRef = pod.typeRef(typeRefId);
      if (typeRef.isErr())
      {
        java.u2(0);
      }
      else
      {
        int jtype = emit.cls(typeRef.jname());
        java.u2(jtype);
        String javaEx = FanUtil.errfanToJava(typeRef.jname());
        if (javaEx != null)
        {
          java.u2(0, ++count);
          java.u2(start);
          java.u2(end);
          java.u2(trap);
          java.u2(emit.cls(javaEx));
        }
      }
    }

    code.exceptionTable = java;
  }

  /**
   * Process line number table (if specified), we just reuse the
   * fcode line table buffer and replace the fcode pc with bytecode
   * pc since they are the same sized data structures.
   */
  private void lineTable()
  {
    if (fmethod == null) return;
    FBuf flines = fmethod.attrs.lineNums;
    if (flines == null)
    {
      code.emitLineNumber(fmethod.attrs.lineNum);
      return;
    }

    int len = flines.len;
    byte[] buf = flines.buf;
    for (int i=2; i<len; i += 4)
    {
      reloc(buf, i);
    }

    AttrEmit attr = code.emitAttr("LineNumberTable");
    attr.info.len = len;
    attr.info.buf = buf;
  }

  private void reloc(byte[] buf, int offset)
  {
    int fpos = (buf[offset] & 0xFF) << 8 | (buf[offset+1] & 0xFF);
    int jpos = reloc[fpos];
    buf[offset+0] = (byte)(jpos >>> 8);
    buf[offset+1] = (byte)(jpos >>> 0);
  }

  /**
   * If debug is turned on, then generate a local variable table.
   */
  private void localVarTable()
  {
//    if (!Sys.debug) return;
    if (fmethod == null) return;

    AttrEmit attr = code.emitAttr("LocalVariableTable");
    Box info = attr.info;

    // Fantom variables never reuse stack registers, so
    // we can declare their scope across entire method
    int start = 0;
    int end = code.info.len-2-2-4; // max stack, max locals, code len

    info.u2(regs.length);
    info.grow(info.len + regs.length*10);
    for (int i=0; i<regs.length; ++i)
    {
      Reg reg = regs[i];
      info.u2(start);
      info.u2(end);
      info.u2(code.emit.utf(reg.name));
      info.u2(code.emit.utf(reg.typeRef.jsig()));
      info.u2(reg.jindex);
    }
  }

//////////////////////////////////////////////////////////////////////////
// Load/Store
//////////////////////////////////////////////////////////////////////////

  private void loadFalse()
  {
    code.op(ICONST_0);
  }

  private void loadTrue()
  {
    code.op(ICONST_1);
  }

  private void loadInt()
  {
    try
    {
      Long val = pod.readLiterals().integer(u2());
      long i = val.longValue();
      if (i == 0L) code.op(LCONST_0);
      else if (i == 1L) code.op(LCONST_1);
      else code.op2(LDC2_W, emit.longConst(val));
    }
    catch (java.io.IOException e)
    {
      throw new RuntimeException(e.toString(), e);
    }
  }

  private void loadFloat()
  {
    try
    {
      Double val = pod.readLiterals().floats(u2());
      double d = val.doubleValue();
      if (d == 0.0) code.op(DCONST_0);
      else if (d == 1.0) code.op(DCONST_1);
      else code.op2(LDC2_W, emit.doubleConst(val));
    }
    catch (java.io.IOException e)
    {
      throw new RuntimeException(e.toString(), e);
    }
  }

  private void loadStr()
  {
    try
    {
      String val = pod.readLiterals().str(u2());
      int cp = emit.strConst(val);
      if (cp < 255)
        code.op1(LDC, cp);
      else
        code.op2(LDC_W, cp);
    }
    catch (java.io.IOException e)
    {
      throw new RuntimeException(e.toString(), e);
    }
  }

  private void loadDecimal()
  {
    int index = u2();
    int field = emit.field(podClass + ".D" + index + ":Ljava/math/BigDecimal;");
    code.op2(GETSTATIC, field);
  }

  private void loadDuration()
  {
    int index = u2();
    int field = emit.field(podClass + ".Dur" + index + ":Lfan/std/Duration;");
    code.op2(GETSTATIC, field);
  }

  private void loadUri()
  {
    int index = u2();
    int field = emit.field(podClass + ".U" + index + ":Lfan/std/Uri;");
    code.op2(GETSTATIC, field);
  }

  private void loadType()
  {
    loadType(pod.typeRef(u2()));
  }

  private void loadType(FTypeRef ref)
  {
    String podName  = ref.podName;
    String typeName = ref.typeName;

    // if pod is "sys", then we can perform a shortcut and use
    // one of the predefined fields in Sys
//    if (!ref.isGenericInstance() && podName.equals("sys"))
//    {
//      code.op2(GETSTATIC, emit.field("fan/sys/Sys." + typeName + "Type:"+Sys.TypeClassJsig+""));
//      if (ref.isNullable()) typeToNullable();
//      return;
//    }

    // if type is [java]... FFI type, then we access as static field
    // on the pod class since we don't have any bootstrap issues
    if (ref.isFFI())
    {
      code.op2(GETSTATIC, emit.field(podClass + ".Type" + ref.id + ":"+ Sys.TypeClassJsig));
      if (ref.isNullable()) typeToNullable();
      return;
    }

    // lazy allocate my parent's type literal map: sig -> fieldName
    if (parent.typeLiteralFields == null) parent.typeLiteralFields= new HashMap();
    HashMap map = parent.typeLiteralFields;

    // types are lazy loaded and then cached in a private static field called
    // type$literal$count which will get generated by FTypeEmit (we keep track of signature
    // to fieldname in the typeConstFields map)
    String sig = ref.signature;
    String fieldName = (String)map.get(sig);
    if (fieldName == null)
    {
      fieldName = "type$literal$" + map.size();
      map.put(sig, fieldName);
    }
    int fieldRef = emit.field(parent.className + "." + fieldName + ":"+ Sys.TypeClassJsig);

    code.op2(GETSTATIC, fieldRef);
    code.op(DUP);
    int nonNull = code.branch(IFNONNULL);
    code.op(POP);
    code.op2(LDC_W, emit.strConst(sig));
    code.op(ICONST_1);
    code.op2(INVOKESTATIC, parent.typeFind());
    code.op(DUP);
    code.op2(PUTSTATIC, fieldRef);
    code.mark(nonNull);
  }

//////////////////////////////////////////////////////////////////////////
// Load Var
//////////////////////////////////////////////////////////////////////////

  private void loadVar()
  {
    Reg reg = reg(u2());
    loadVar(code, reg.stackType, reg.jindex);
  }

  /** Load variable onto stack using Java type and java index (which might
      not map to Fantom index.  Return next available java index */
  static int loadVar(CodeEmit code, int stackType, int jindex)
  {
    switch (stackType)
    {
      case FTypeRef.BOOL:
      case FTypeRef.BYTE:
      case FTypeRef.SHORT:
      case FTypeRef.CHAR:
      case FTypeRef.INT:
        return loadVarInt(code, jindex);

      case FTypeRef.LONG:
        return loadVarLong(code, jindex);

      case FTypeRef.FLOAT:
        return loadVarFloat(code, jindex);

      case FTypeRef.DOUBLE:
        return loadVarDouble(code, jindex);

      case FTypeRef.OBJ:
        return loadVarObj(code, jindex);

      default:
        throw new IllegalStateException("Register " + jindex + " " + (char)stackType);
    }
  }

  private static int loadVarInt(CodeEmit code, int jindex)
  {
    switch (jindex)
    {
      case 0:  code.op(ILOAD_0); break;
      case 1:  code.op(ILOAD_1); break;
      case 2:  code.op(ILOAD_2); break;
      case 3:  code.op(ILOAD_3); break;
      default: code.op1(ILOAD, jindex); break;
    }
    return jindex+1;
  }

  private static int loadVarLong(CodeEmit code, int jindex)
  {
    switch (jindex)
    {
      case 0:  code.op(LLOAD_0); break;
      case 1:  code.op(LLOAD_1); break;
      case 2:  code.op(LLOAD_2); break;
      case 3:  code.op(LLOAD_3); break;
      default: code.op1(LLOAD, jindex); break;
    }
    return jindex+2;
  }

  private static int loadVarFloat(CodeEmit code, int jindex)
  {
    switch (jindex)
    {
      case 0:  code.op(FLOAD_0); break;
      case 1:  code.op(FLOAD_1); break;
      case 2:  code.op(FLOAD_2); break;
      case 3:  code.op(FLOAD_3); break;
      default: code.op1(FLOAD, jindex); break;
    }
    return jindex+2;
  }

  private static int loadVarDouble(CodeEmit code, int jindex)
  {
    switch (jindex)
    {
      case 0:  code.op(DLOAD_0); break;
      case 1:  code.op(DLOAD_1); break;
      case 2:  code.op(DLOAD_2); break;
      case 3:  code.op(DLOAD_3); break;
      default: code.op1(DLOAD, jindex); break;
    }
    return jindex+2;
  }

  private static int loadVarObj(CodeEmit code, int jindex)
  {
    switch (jindex)
    {
      case 0:  code.op(ALOAD_0); break;
      case 1:  code.op(ALOAD_1); break;
      case 2:  code.op(ALOAD_2); break;
      case 3:  code.op(ALOAD_3); break;
      default: code.op1(ALOAD, jindex); break;
    }
    return jindex+1;
  }

//////////////////////////////////////////////////////////////////////////
// Store Var
//////////////////////////////////////////////////////////////////////////

  private void storeVar()
  {
    Reg reg = reg(u2());
    storeVar(reg.stackType, reg.jindex);
  }

  private void storeVar(int stackType, int jindex)
  {
    switch (stackType)
    {
      case FTypeRef.BOOL:
      case FTypeRef.BYTE:
      case FTypeRef.SHORT:
      case FTypeRef.CHAR:
      case FTypeRef.INT:
        storeVarInt(jindex);
        break;

      case FTypeRef.LONG:
        storeVarLong(jindex);
        break;

      case FTypeRef.FLOAT:
        storeVarFloat(jindex);
        break;

      case FTypeRef.DOUBLE:
        storeVarDouble(jindex);
        break;

      case FTypeRef.OBJ:
        storeVarObj(jindex);
        break;

      default: throw new IllegalStateException("Register " + jindex + " " + (char)stackType);
    }
  }

  private void storeVarInt(int jindex)
  {
    switch (jindex)
    {
      case 0:  code.op(ISTORE_0); break;
      case 1:  code.op(ISTORE_1); break;
      case 2:  code.op(ISTORE_2); break;
      case 3:  code.op(ISTORE_3); break;
      default: code.op1(ISTORE, jindex); break;
    }
  }

  private void storeVarLong(int jindex)
  {
    switch (jindex)
    {
      case 0:  code.op(LSTORE_0); break;
      case 1:  code.op(LSTORE_1); break;
      case 2:  code.op(LSTORE_2); break;
      case 3:  code.op(LSTORE_3); break;
      default: code.op1(LSTORE, jindex); break;
    }
  }

  private void storeVarFloat(int jindex)
  {
    switch (jindex)
    {
      case 0:  code.op(FSTORE_0); break;
      case 1:  code.op(FSTORE_1); break;
      case 2:  code.op(FSTORE_2); break;
      case 3:  code.op(FSTORE_3); break;
      default: code.op1(FSTORE, jindex); break;
    }
  }

  private void storeVarDouble(int jindex)
  {
    switch (jindex)
    {
      case 0:  code.op(DSTORE_0); break;
      case 1:  code.op(DSTORE_1); break;
      case 2:  code.op(DSTORE_2); break;
      case 3:  code.op(DSTORE_3); break;
      default: code.op1(DSTORE, jindex); break;
    }
  }

  private void storeVarObj(int jindex)
  {
    switch (jindex)
    {
      case 0:  code.op(ASTORE_0); break;
      case 1:  code.op(ASTORE_1); break;
      case 2:  code.op(ASTORE_2); break;
      case 3:  code.op(ASTORE_3); break;
      default: code.op1(ASTORE, jindex); break;
    }
  }


//////////////////////////////////////////////////////////////////////////
// Jump
//////////////////////////////////////////////////////////////////////////

  private void jumpTrue()
  {
    code.op(IFNE);
    branch();
  }

  private void jumpFalse()
  {
    code.op(IFEQ);
    branch();
  }

  private void jump()
  {
    code.op(GOTO);
    branch();
  }

  private JumpNode branch()
  {
    // at this point we don't know how fcode locations (abs) will
    // map to Java bytecode locations (rel offsets), so we just
    // keep track of locations to backpatch in a linked list
    JumpNode j = new JumpNode();
    j.fcodeLoc = u2();
    j.javaFrom = code.pos() - 1;
    j.javaMark = code.pos();
    j.next = jumps;
    jumps = j;

    // leave two bytes to back patch later
    code.info.u2(0xFFFF);

    // return jump node
    return j;
  }

//////////////////////////////////////////////////////////////////////////
// Compare
//////////////////////////////////////////////////////////////////////////

  private void compareEQ()
  {
    FTypeRef lhs = pod.typeRef(u2());
    FTypeRef rhs = pod.typeRef(u2());

    // if this is a.equals(b) and we know a is non-null, then just call equals
    if (lhs.isRef() && !lhs.isNullable() && rhs.isRef())
    {
      code.op2(INVOKEVIRTUAL, emit.method("java/lang/Object.equals(Ljava/lang/Object;)Z"));
      return;
    }

    doCompare("EQ", lhs, rhs);
  }

  private void compareNE() { doCompare("NE"); }

  private void compareLT() { doCompare("LT"); }

  private void compareLE() { doCompare("LE"); }

  private void compareGE() { doCompare("GE"); }

  private void compareGT() { doCompare("GT"); }

  private void compare() { doCompare(""); }

  private void doCompare(String suffix)
  {
    doCompare(suffix, pod.typeRef(u2()), pod.typeRef(u2()));
  }

  private void doCompare(String suffix, FTypeRef lhs, FTypeRef rhs)
  {
    // compute the right method call signature
    StringBuilder s = new StringBuilder();
    s.append("fanx/util/OpUtil.compare").append(suffix).append('(');
    if (lhs.isRef()) s.append("Ljava/lang/Object;"); else lhs.jsig(s);
    if (rhs.isRef()) s.append("Ljava/lang/Object;"); else rhs.jsig(s);
    s.append(')');
    if (suffix == "") s.append('J'); else s.append('Z');

    code.op2(INVOKESTATIC, emit.method(s.toString()));
  }

  private void compareSame()
  {
    int peek = peekOp();
    switch (peek)
    {
      case JumpFalse:
        consumeOp();
        code.op(IF_ACMPNE);
        branch();
        break;
      case JumpTrue:
        consumeOp();
        code.op(IF_ACMPEQ);
        branch();
        break;
      default:
        int label = code.branch(IF_ACMPEQ);
        code.op(ICONST_0);
        int end = code.branch(GOTO);
        code.mark(label);
        code.op(ICONST_1);
        code.mark(end);
        break;
    }
  }

  private void compareNotSame()
  {
    int peek = peekOp();
    switch (peek)
    {
      case JumpFalse:
        consumeOp();
        code.op(IF_ACMPEQ);
        branch();
        break;
      case JumpTrue:
        consumeOp();
        code.op(IF_ACMPNE);
        branch();
        break;
      default:
        int label = code.branch(IF_ACMPNE);
        code.op(ICONST_0);
        int end = code.branch(GOTO);
        code.mark(label);
        code.op(ICONST_1);
        code.mark(end);
        break;
    }
  }

  private void compareNull()
  {
    u2(); // ignore type
    int peek = peekOp();
    switch (peek)
    {
      case JumpFalse:
        consumeOp();
        code.op(IFNONNULL);
        branch();
        break;
      case JumpTrue:
        consumeOp();
        code.op(IFNULL);
        branch();
        break;
      default:
        int label = code.branch(IFNULL);
        code.op(ICONST_0);
        int end = code.branch(GOTO);
        code.mark(label);
        code.op(ICONST_1);
        code.mark(end);
        break;
    }
  }

  private void compareNotNull()
  {
    u2(); // ignore type
    int peek = peekOp();
    switch (peek)
    {
      case JumpFalse:
        consumeOp();
        code.op(IFNULL);
        branch();
        break;
      case JumpTrue:
        consumeOp();
        code.op(IFNONNULL);
        branch();
        break;
      default:
        int label = code.branch(IFNONNULL);
        code.op(ICONST_0);
        int end = code.branch(GOTO);
        code.mark(label);
        code.op(ICONST_1);
        code.mark(end);
        break;
    }
  }

//////////////////////////////////////////////////////////////////////////
// Stack Manipulation
//////////////////////////////////////////////////////////////////////////

  private void returnOp()  { code.op(returnOp(ret)); }

  static int returnOp(FTypeRef ret) { return returnOp(ret.stackType); }

  static int returnOp(int retStackType)
  {
    switch (retStackType)
    {
      case 'A': return ARETURN;
      case 'F': return FRETURN;
      case 'D': return DRETURN;
      case 'J': return LRETURN;
      case 'B':
      case 'C':
      case 'S':
      case 'Z':
      case 'I': return IRETURN;
      case 'V': return RETURN;
      default: throw new IllegalStateException(""+(char)retStackType);
    }
  }

  private void dup()
  {
    FTypeRef typeRef = pod.typeRef(u2());
    code.op(typeRef.isWide() ? DUP2 : DUP);
  }

  private void pop()
  {
    FTypeRef typeRef = pod.typeRef(u2());
    code.op(typeRef.isWide() ? POP2 : POP);
  }

//////////////////////////////////////////////////////////////////////////
// Is/As
//////////////////////////////////////////////////////////////////////////

  private void is()
  {
    FTypeRef typeRef = pod.typeRef(u2());

    // if a generic instance, we have to use a method call
    // because Fantom types don't map to Java classes exactly;
    // otherwise we can use straight bytecode
//    if (typeRef.podName.equals("sys") && typeRef.isGenericInstance())
//    {
//      if (parent.IsViaType == 0) parent.IsViaType = emit.method("fanx/util/OpUtil.is(Ljava/lang/Object;"+Sys.TypeClassJsig+")Z");
//      loadType(typeRef);
//      code.op2(INVOKESTATIC, parent.IsViaType);
//    }
//    else
    {
      int cls = emit.cls(typeRef.jnameBoxed());
      code.op2(INSTANCEOF, cls);
    }
  }

  private void as()
  {
    FTypeRef typeRef = pod.typeRef(u2());
    int cls = emit.cls(typeRef.jnameBoxed());
    code.op(DUP);
    code.op2(INSTANCEOF, cls);
    int is = code.branch(IFNE);
    code.op(POP);
    code.op(ACONST_NULL);
    int end = code.branch(GOTO);
    code.mark(is);
    code.op2(CHECKCAST, cls);
    code.mark(end);
  }

//////////////////////////////////////////////////////////////////////////
// Switch
//////////////////////////////////////////////////////////////////////////

  private void tableswitch()
  {
    int count = u2();

    code.op(L2I);
    int start = code.pos();
    code.op(TABLESWITCH);
    int pad = code.padAlign4();
    code.info.u4(1+pad+12+count*4); // default is always fall thru
    code.info.u4(0);
    code.info.u4(count-1);

    // at this point we don't know how fcode locations (abs) will
    // map to Java bytecode locations (rel offsets), so we just
    // keep track of locations to backpatch in a linked list
    for (int i=0; i<count; ++i)
    {
      JumpNode j = new JumpNode();
      j.fcodeLoc = u2();
      j.size     = 4;
      j.javaFrom = start;
      j.javaMark = code.info.len-CodeEmit.Header;
      j.next = jumps;
      jumps = j;
      code.info.u4(-1);  // place holder for backpatch
    }
  }

//////////////////////////////////////////////////////////////////////////
// Coercion
//////////////////////////////////////////////////////////////////////////

  private void coerce()
  {
    FTypeRef from = pod.typeRef(u2());
    FTypeRef to   = pod.typeRef(u2());

    // if types exactly the same then print warning;
    // the compiler should not emit such a coerce
    if (from == to)
    {
      System.out.println("WARNING: " + parent.selfName + " " + fmethod.name + " Coerce: " + from + " => " + to);
      return;
    }

    // handle primitives
    if (to.isPrimitive())   { coerceToPrimitive(from, to); return; }
    if (from.isPrimitive()) { coerceFromPrimitive(from, to); return; }

    // check nullable => non-nullable
    if (from.isNullable() && !to.isNullable())
    {
      code.op(DUP);
      int nonnull = code.branch(IFNONNULL);
      if (parent.NullErrMakeCoerce == 0)
        parent.NullErrMakeCoerce = emit.method("fan/sys/NullErr.makeCoerce()Lfan/sys/NullErr;");
      code.op2(INVOKESTATIC, parent.NullErrMakeCoerce);
      code.op(ATHROW);
      code.mark(nonnull);
    }

    // don't bother casting to obj
    if (to.isObj()) return;

    code.op2(CHECKCAST, emit.cls(to.jname()));
  }

  private void coerceToPrimitive(FTypeRef from, FTypeRef to)
  {
    // Boolean -> boolean
    if (to.isPrimitiveBool())
    {
      if (from.isRef()) { boolUnbox(!from.isBool()); return; }
    }

    // Long, int -> long
    if (to.isPrimitiveLong())
    {
      if (from.isRef()) { intUnbox(!from.isInt()); return; }
      if (from.isPrimitiveIntLike()) { code.op(I2L); return; }
      if (from.isPrimitiveLong()) return;
    }

    // Double, float -> double
    if (to.isPrimitiveDouble())
    {
      if (from.isRef()) { floatUnbox(!from.isFloat()); return; }
      if (from.isPrimitiveFloat()) { code.op(F2D); return; }
      if (from.isPrimitiveDouble()) return;
    }

    // long, Long -> int, byte, short
    if (to.isPrimitiveIntLike())
    {
      if (from.isRef() || from.isPrimitiveLong())
      {
        if (from.isRef()) intUnbox(!from.isInt());
        code.op(L2I);
        if (to.isPrimitiveByte()) code.op(I2B);
        else if (to.isPrimitiveShort()) code.op(I2S);
        else if (to.isPrimitiveChar()) code.op(I2C);
        return;
      }
    }

    // double, Double -> float
    if (to.isPrimitiveFloat())
    {
      if (from.isPrimitiveDouble()) { code.op(D2F); return; }
      if (from.isRef()) { floatUnbox(!from.isFloat()); code.op(D2F); return; }
    }

    throw new IllegalStateException("Coerce " + from  + " => " + to);
  }

  private void coerceFromPrimitive(FTypeRef from, FTypeRef to)
  {
    // at this point we've already handled any cases where to is
    // a primitive in the coerceToPrimitive() method - so this
    // method is strictly about boxing from a primitive
    if (to.isRef())
      boxToObj(from);
    else
      throw new IllegalStateException("Coerce " + from  + " => " + to);
  }

  void boxToObj(FTypeRef from)
  {
    if (!from.isPrimitive())       { return; }
    if (from.isPrimitiveBool())    { boolBox(); return; }
    if (from.isPrimitiveLong())    { intBox(); return; }
    if (from.isPrimitiveDouble())  { floatBox(); return; }
    if (from.isPrimitiveIntLike()) { code.op(I2L); intBox(); return; }
    if (from.isPrimitiveFloat())   { code.op(F2D); floatBox(); return; }
    throw new IllegalStateException("boxToObj " + from);
  }

  private void cast()
  {
    int cls = emit.cls(pod.typeRef(u2()).jname());
    code.op2(CHECKCAST, cls);
  }

//////////////////////////////////////////////////////////////////////////
// Misc
//////////////////////////////////////////////////////////////////////////

  private void doThrow()
  {
    code.op(ATHROW);
  }

  private void catchErrStart()
  {
    // there is already a java.lang.Exception on the stack, but
    // we need to map into a sys::Err type
    if (parent.ErrMake == 0) parent.ErrMake = emit.method("fan/sys/Err.make(Ljava/lang/Throwable;)Lfan/sys/Err;");
    code.op2(INVOKESTATIC, parent.ErrMake);
    cast();
  }

  private void jumpFinally()
  {
	  if (pod.fcodeVer == 110) {
	    code.op(JSR);
	    JumpNode j = branch();
	    j.isFinally = true;
	  }
  }

  private void finallyStart()
  {
	if (pod.fcodeVer == 110) {
	    // create a new temporary local variable to stash stack pointer
	    if (finallyEx < 0)
	    {
	      finallyEx = code.maxLocals;
	      finallySp = code.maxLocals+1;
	      code.maxLocals += 2;
	    }
	
	    // generate the "catch all" block - this section of code
	    // is always 8 bytes, hence the eight byte offset we have to
	    // add to the JumpFinally/JSR offset to skip it to get the
	    // real finally block start instruction
	    code.op1(ASTORE, finallyEx); // stash exception (ensure fixed width instr)
	    code.op2(JSR, 6);            // call finally "subroutine"
	    code.op1(ALOAD, finallyEx);  // stash exception (ensure fixed width instr)
	    code.op(ATHROW);             // rethrow it
	
	    // generate start of finally block
	    code.op1(ASTORE, finallySp); // stash stack pointer
	}
	else {
		if (finallyEx < 0)
	    {
	      finallyEx = code.maxLocals;
	      code.maxLocals += 1;
	    }
		code.op1(ASTORE, finallyEx);
	}
  }

  private void finallyEnd()
  {
	  if (pod.fcodeVer == 110) {
		  code.op1(RET, finallySp);
	  }
	  else {
		  code.op1(ALOAD, finallyEx);
		  code.op(ATHROW);
	  }
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  private void boolBox()
  {
    if (parent.BoolBox == 0) parent.BoolBox = emit.method("java/lang/Boolean.valueOf(Z)Ljava/lang/Boolean;");
    code.op2(INVOKESTATIC, parent.BoolBox);
  }

  private void boolUnbox(boolean cast)
  {
    if (cast) code.op2(CHECKCAST, emit.cls("java/lang/Boolean"));
    if (parent.BoolUnbox== 0) parent.BoolUnbox = emit.method("java/lang/Boolean.booleanValue()Z");
    code.op2(INVOKEVIRTUAL, parent.BoolUnbox);
  }

  private void intBox()
  {
    if (parent.IntBox == 0) parent.IntBox = emit.method("java/lang/Long.valueOf(J)Ljava/lang/Long;");
    code.op2(INVOKESTATIC, parent.IntBox);
  }

  private void intUnbox(boolean cast)
  {
    if (cast) code.op2(CHECKCAST, emit.cls("java/lang/Long"));
    if (parent.IntUnbox== 0) parent.IntUnbox = emit.method("java/lang/Long.longValue()J");
    code.op2(INVOKEVIRTUAL, parent.IntUnbox);
  }

  private void floatBox()
  {
    if (parent.FloatBox == 0) parent.FloatBox = emit.method("java/lang/Double.valueOf(D)Ljava/lang/Double;");
    code.op2(INVOKESTATIC, parent.FloatBox);
  }

  private void floatUnbox(boolean cast)
  {
    if (cast) code.op2(CHECKCAST, emit.cls("java/lang/Double"));
    if (parent.FloatUnbox== 0) parent.FloatUnbox = emit.method("java/lang/Double.doubleValue()D");
    code.op2(INVOKEVIRTUAL, parent.FloatUnbox);
  }

  private void typeToNullable()
  {
    if (parent.TypeToNullable == 0) parent.TypeToNullable = emit.method(Sys.TypeClassPathName+".toNullable()"+Sys.TypeClassJsig);
    code.op2(INVOKEVIRTUAL, parent.TypeToNullable);
  }

//////////////////////////////////////////////////////////////////////////
// Buf
//////////////////////////////////////////////////////////////////////////

  private int consumeOp()
  {
    reloc[pos] = code.pos();  // store fcode -> bytecode relocation offsets (8 bytes left for Code header)
    return u1();
  }

  private int peekOp()
  {
    if (pos < len) return buf[pos];
    return -1;
  }

  private int u1() { return buf[pos++]; }
  private int u2() { return (buf[pos++] & 0xFF) << 8 | (buf[pos++] & 0xFF); }
  private int u4() { return (buf[pos++] & 0xFF) << 24 | (buf[pos++] & 0xFF) << 16 | (buf[pos++] & 0xFF) << 8 | (buf[pos++] & 0xFF); }

//////////////////////////////////////////////////////////////////////////
// Reg
//////////////////////////////////////////////////////////////////////////

  /**
   * Given a list of registers compute the max locals
   */
  static int maxLocals(Reg[] regs)
  {
    if (regs.length == 0) return 0;
    Reg last = regs[regs.length-1];
    return last.jindex + (last.isWide() ? 2 : 1);
  }

  /**
   * Map to Java register info for the given Fantom local variables.
   * Registers are typed (so we know which XLOAD_X and XSTORE_X opcodes
   * to use) and might be numbered differently (if using longs/doubles).
   */
  static Reg[] initRegs(FTypeEmit parent, boolean isStatic, FMethodVar[] vars)
  {
    FPod pod = parent.pod;
    Reg[] regs = new Reg[isStatic ? vars.length : vars.length+1];
    int jindex = 0;
    for (int i=0; i<regs.length; ++i)
    {
      Reg r = new Reg();
      if (i == 0 && !isStatic)
      {
        // this pointer
        r.typeRef = pod.typeRef(parent.type.self);
        r.name = "this";
        r.stackType = FTypeRef.OBJ;
        r.jindex = jindex;
        ++jindex;
      }
      else
      {
        FMethodVar var = vars[isStatic ? i : i - 1];
        r.typeRef = pod.typeRef(var.type);
        r.name = var.name;
        r.stackType = r.typeRef.stackType;
        r.jindex = jindex;
        jindex += r.typeRef.isWide() ? 2 : 1;
      }
      regs[i] = r;
    }
    return regs;
  }

  static class InvalidRegException extends RuntimeException
  {
    InvalidRegException(String msg) { super(msg); }
  }

  private Reg reg(int fanIndex)
  {
    if (regs == null) throw new IllegalStateException("Use of variable with undefined regs");
    if (fanIndex >= regs.length) 
    	throw new InvalidRegException("" + fanIndex);
    return regs[fanIndex];
  }

  static final Reg[] noRegs = new Reg[0];

  static Reg makeThisReg(FTypeRef typeRef)
  {
    Reg r = new Reg();
    r.typeRef = typeRef;
    r.name = "this";
    r.stackType = FTypeRef.OBJ;
    r.jindex = 0;
    return r;
  }

  static class Reg
  {
    public String toString() { return "Reg " + jindex + " " + (char)stackType; }
    public boolean isWide() { return FTypeRef.isWide(stackType); }
    String name;      // local variable name
    FTypeRef typeRef; // local variable type
    int stackType;    // FTypeRef.OBJ, LONG, INT, etc
    int jindex;       // Java register number to use (might shift for longs/doubles)
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  static class JumpNode
  {
    int fcodeLoc;       // fcode location (index of fcode opcode in byte buffer)
    int javaMark;       // location in java bytecode to backpatch the java offset
    int javaFrom;       // loc in java to consider as jump base in computing relative offset
    int size = 2;       // size in bytes to backpatch (2 or 4)
    boolean isFinally;  // is this a JSR branch to a finally block
    JumpNode next;      // next in linked list
  }

  FPod pod;
  FTypeEmit parent;
  FMethod fmethod;     // maybe null
  Reg[] regs;          // register mappnig must be set for loadVar/storeVar
  FTypeRef ret;        // return type
  byte[] buf;
  int len;
  int pos;
  Emitter emit;
  CodeEmit code;
  String podClass;
  int[] reloc;        // fcode offsets -> java bytecode offsets
  JumpNode jumps;     // link list of jumps to back patch
  int finallyEx = -1; // local variable used in finally to stash catch exception
  int finallySp = -1; // local variable used in finally to stash stack pointer

}