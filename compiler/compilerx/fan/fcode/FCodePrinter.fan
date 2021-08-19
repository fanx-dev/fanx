//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Dec 05  Brian Frank  Creation
//   20 Aug 06  Brian Frank  Ported from Java to Fan
//

**
** FCodePrinter prints a human readable syntax for fcode
**
class FCodePrinter : FConst
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(FPod pod, OutStream out := Env.cur.out)
  {
    this.pod = pod
    this.out = out
  }

//////////////////////////////////////////////////////////////////////////
// Print
//////////////////////////////////////////////////////////////////////////

  Void code(Buf buf)
  {
    try
    {
      this.buf = buf.seek(0)

      while (true)
      {
        op := buf.read
        if (op == -1) break
        this.op(FOp.vals[op])
      }
    }
    catch (Err e)
    {
      e.trace
    }

    out.flush
    this.buf = null
  }

  Void op(FOp op)
  {
    print("    " + buf.pos.minus(1).toStr.justr(3) + ": " + op.name.justl(19) + " ")
    if (op == FOp.Switch) printSwitch
    else switch (op.arg)
    {
      case FOpArg.None:      print
      case FOpArg.Int:       i := buf.readU2; print(pod.integer(i).toStr + index(i))
      case FOpArg.Float:     i := buf.readU2; print(pod.float(i).toStr + index(i))
      case FOpArg.Decimal:   i := buf.readU2; print(pod.decimal(i).toStr + index(i))
      case FOpArg.Str:       i := buf.readU2; print(pod.str(i).toStr + index(i))
      case FOpArg.Duration:  i := buf.readU2; print(pod.duration(i).toStr + index(i))
      case FOpArg.Uri:       i := buf.readU2; print(pod.uri(i).toStr + index(i))
      case FOpArg.Register:  i := buf.readU2; print(i)
      case FOpArg.TypeRef:   i := buf.readU2; print(pod.typeRefStr(i) + index(i))
      case FOpArg.FieldRef:  i := buf.readU2; print(pod.fieldRefStr(i) + index(i))
      case FOpArg.MethodRef: i := buf.readU2; print(pod.methodRefStr(i) + index(i))
      case FOpArg.Jump:      i := buf.readU2; print(i)
      case FOpArg.TypePair:
        i1 := buf.readU2
        i2 := buf.readU2
        print(pod.typeRefStr(i1) + index(i1))
        if (op == FOp.Coerce) print(" => "); else print(" <=> ")
        print(pod.typeRefStr(i2) + index(i2))
      default:       throw Err(op.arg.toStr)
    }
    printLine
  }

  Void printSwitch()
  {
    buf.readU2.times |Int i|
    {
      printLine
      print("          " + i + " -> " + buf.readU2)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Print
//////////////////////////////////////////////////////////////////////////

  Str index(Int index)
  {
    if (showIndex) return "[" + index + "]"
    return ""
  }

  FCodePrinter print(Obj obj := "") { out.print(obj); return this }
  FCodePrinter printLine(Obj obj := "") { out.printLine(obj); return this }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  FPod pod
  OutStream out
  Bool showIndex
  Buf? buf

}