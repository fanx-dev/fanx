//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Dec 05  Brian Frank  Creation
//   19 Aug 06  Brian Frank  Ported from Java to Fan
//

**
** FTable is a 16-bit indexed lookup table for pod constants.
**
class FTable
{

//////////////////////////////////////////////////////////////////////////
// Factories
//////////////////////////////////////////////////////////////////////////

  static FTable makeStrs(FPod pod)
  {
    return make(pod,
      |OutStream out, Obj obj| { out.writeUtf((Str)obj) },
      |InStream in->Obj| { in.readUtf.intern })
  }

  static FTable makeTypeRefs(FPod pod)
  {
    return make(pod,
      |OutStream out, Obj obj| { ((FTypeRef)obj).write(out) },
      |InStream in->Obj| { FTypeRef.read(in) })
  }

  static FTable makeFieldRefs(FPod pod)
  {
    return make(pod,
      |OutStream out, Obj obj| { ((FFieldRef)obj).write(out) },
      |InStream in->Obj| { FFieldRef.read(in) })
  }

  static FTable makeMethodRefs(FPod pod)
  {
    return make(pod,
      |OutStream out, Obj obj| { ((FMethodRef)obj).write(out) },
      |InStream in->Obj| { FMethodRef.read(in) })
  }

  static FTable makeInts(FPod pod)
  {
    return make(pod,
      |OutStream out, Obj obj| { out.writeI8((Int)obj) },
      |InStream in->Obj| { in.readS8 })
  }

  static FTable makeFloats(FPod pod)
  {
    return make(pod,
      |OutStream out, Obj obj| { out.writeF8((Float)obj) },
      |InStream in->Obj| { in.readF8 })
  }

  static FTable makeDecimals(FPod pod)
  {
    return make(pod,
      |OutStream out, Obj obj| { out.writeUtf(((Decimal)obj).toStr) },
      |InStream in->Obj| { Decimal(in.readUtf) })
  }

  static FTable makeDurations(FPod pod)
  {
    //TODO Fix fanx
    nsPerSec := 1000000000
//    return make(pod,
//      |OutStream out, Obj obj| {
//        out.writeI8(((Duration)obj).toSec)
//        .writeI4(((Int)((Duration)obj).toNanos) % nsPerSec)
//      },
//      |InStream in->Obj| { Duration.fromNanos(in.readS8 * nsPerSec + in.readS4) })
//    
    return make(pod,
      |OutStream out, Obj obj| {
        out.writeI8(((Duration)obj).toSec)
        .writeI4(((Int)((Duration)obj).ticks) % nsPerSec)
      },
      |InStream in->Obj| { Duration(in.readS8 * nsPerSec + in.readS4) })
  }

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(FPod pod, |OutStream out, Obj obj| writer, |InStream in->Obj| reader)
  {
    this.pod     = pod
    this.writer  = writer
    this.reader  = reader
    this.table   = [,]
    this.reverse = Obj:Int[:]
  }

//////////////////////////////////////////////////////////////////////////
// Access
//////////////////////////////////////////////////////////////////////////

  **
  ** Return if this table is empty
  **
  Bool isEmpty()
  {
    return table.isEmpty
  }

  **
  ** Get the object identified by the specified 16-bit index.
  **
  @Operator Obj get(Int index)
  {
    return table[index]
  }

  **
  ** Perform a reverse lookup to map a value to it's index (only
  ** available at compile time).  If the value isn't in the table
  ** yet, then add it.
  **
  Int add(Obj val)
  {
    index := reverse[val]
    if (index == null)
    {
      index = table.size
      table.add(val)
      reverse[val] = index
    }
    return index
  }

  **
  ** Serialize.
  **
  FTable read(InStream? in)
  {
    table = [,]
    if (in == null) return this
    in.readU2.times { table.add(reader.call(in)) }
    in.close
    return this
  }

  **
  ** Deserialize.
  **
  Void write(OutStream out)
  {
    out.writeI2(table.size)
    table.each |Obj obj| { writer.call(out, obj) }
    out.close
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  FPod pod
  Obj[] table
  Obj:Int reverse
  |OutStream out, Obj obj| writer
  |InStream in->Obj| reader
}