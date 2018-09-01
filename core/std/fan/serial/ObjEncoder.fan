//
// Copyright (c) 2007, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 Aug 07  Brian Frank  Creation
//

/**
 * ObjEncoder serializes an object to an output stream.
 */
internal class ObjEncoder
{

//////////////////////////////////////////////////////////////////////////
// Static
//////////////////////////////////////////////////////////////////////////

  static Str encode(Obj obj)
  {
    buf := StrBuf()
    ObjEncoder(buf.out, null).writeObj(obj)
    return buf.toStr
  }

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(OutStream out, [Str:Obj]? options)
  {
    this.out = out
    if (options != null) initOptions(options)
  }

//////////////////////////////////////////////////////////////////////////
// Write
//////////////////////////////////////////////////////////////////////////

  Void writeObj(Obj? obj)
  {
    if (obj == null)
    {
      wStr("null")
      return
    }


    if (obj is Bool) { wStr(obj.toStr); return }
    else if (obj is Str)  { wStrLiteral(obj.toStr, '"'); return }
    else if (obj is Int)  { wStr(obj.toStr); return }
    else if (obj is Float)  {
      f := obj as Float
      if (f.isNaN) wStr("""sys::Float("NaN")""")
      else if (f == Float.posInf) wStr("""sys::Float("INF")""")
      else if (f == Float.negInf) wStr("""sys::Float("-INF")""")
      else { wStr(obj.toStr); w('f') }
      return
    }
    else if (obj is Type) {
      wType(obj).w('#')
      return
    }
    else if (obj is Slot) {
      slot := obj as Slot
      wType(slot.parent).w('#').wStr(slot.name)
      return
    }
    else if (obj is List) { writeList(obj); return }
    else if (obj is Map) { writeMap(obj); return }
    else if (obj is Duration) { wStr(obj.toStr); return }
    //if (obj is Decimal) { FanDecimal.encode((BigDecimal)obj, this) return }
    /*
    if (obj instanceof Literal)
    {
      ((Literal)obj).encode(this)
      return
    }
    */

    type := obj.typeof
    Serializable? ser := type.facet(Serializable#, false)
    if (ser != null)
    {
      if (ser.simple)
        writeSimple(type, obj)
      else
        writeComplex(type, obj, ser)
    }
    else
    {
      if (skipErrors)
        wStr("null /* Not serializable: ").wStr(type.qname).wStr(" */")
      else
        throw IOErr.make("Not serializable: " + type)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Simple
//////////////////////////////////////////////////////////////////////////

  private Void writeSimple(Type type, Obj obj)
  {
    wType(type).w('(').wStrLiteral(obj.toStr, '"').w(')')
  }

//////////////////////////////////////////////////////////////////////////
// Complex
//////////////////////////////////////////////////////////////////////////

  private Void writeComplex(Type type, Obj obj, Serializable ser)
  {
    wType(type)

    Bool first := true
    Obj? defObj := null
    if (skipDefaults)
    {
      // attempt to instantiate default object for type,
      // this will fail if complex has it-block ctor
      try { defObj = obj.typeof.make } catch (Err e) {}
    }

    fields := type.fields
    for (i:=0; i<fields.size; ++i)
    {
      Field f := fields.get(i)

      // skip static, transient, and synthetic (once) fields
      if (f.isStatic || f.isSynthetic || f.hasFacet(Transient#)) continue

      // get the value
      Obj? val := f.get(obj)

      // if skipping defaults
      if (defObj != null)
      {
        Obj? defVal := f.get(defObj)
        if (val == defVal) continue
      }

      // if first then open braces
      if (first) { w('\n').wIndent.w('{').w('\n'); level++; first = false }

      // field name =
      wIndent.wStr(f.name).w('=')

      // field value
      curFieldType = f.type.toNonNullable
      writeObj(val)
      curFieldType = null

      w('\n')
    }

    // if collection
    if (ser.collection)
      first = writeCollectionItems(type, obj, first)

    // if we output fields, then close braces
    if (!first) { level--; wIndent.w('}') }
  }

//////////////////////////////////////////////////////////////////////////
// Collection (@collection)
//////////////////////////////////////////////////////////////////////////

  private Bool writeCollectionItems(Type type, Obj obj, Bool first)
  {
    // lookup each method
    Method? m := type.method("each", false)
    if (m == null) throw IOErr.make("Missing " + type.qname + ".each")

    // call each(it)
    m.call(obj, |Obj? item|{
      if (first) { w('\n').wIndent.w('{').w('\n'); level++; first = false }
      wIndent
      writeObj(item)
      w(',').w('\n')
    })
    return first
  }

//////////////////////////////////////////////////////////////////////////
// List
//////////////////////////////////////////////////////////////////////////

  private Void writeList(Obj?[] list)
  {
    // get of type
    //Type of = list.of

    // decide if we're going output as single or multi-line format
    Bool nl := list.any { isMultiLine(it) }

    // handle empty list
    Int size := list.size
    if (size == 0) { wStr("[,]"); return }

    // items
    if (nl) w('\n').wIndent
    w('[')
    level++
    for (i:=0; i<size; ++i)
    {
      if (i > 0) w(',')
      if (nl) w('\n').wIndent
      writeObj(list.get(i))
    }
    level--
    if (nl) w('\n').wIndent
    w(']')
  }

//////////////////////////////////////////////////////////////////////////
// Map
//////////////////////////////////////////////////////////////////////////

  private Void writeMap([Obj:Obj?] map)
  {
    // decide if we're going output as single or multi-line format
    Bool nl := map.any |v,k| { isMultiLine(k) || isMultiLine(v) }

    // handle empty map
    if (map.isEmpty) { wStr("[:]"); return }

    // items
    level++
    w('[')
    Bool first := true
    map.each |val,key| {
      if (first) first = false
      else w(',')
      if (nl) w('\n').wIndent
      writeObj(key)
      w(':')
      writeObj(val)
    }
    w(']')
    level--
  }

  private Bool isMultiLine(Obj? t)
  {
    if (t == null) return false
    return t.typeof.pod.name != "sys"
  }

//////////////////////////////////////////////////////////////////////////
// Output
//////////////////////////////////////////////////////////////////////////

  private ObjEncoder wType(Type t)
  {
    return wStr(t.signature)
  }

  private ObjEncoder wStrLiteral(Str s, Int quote)
  {
    return wStr(s.toCode(quote))
  }

  private ObjEncoder wIndent()
  {
    num := level*indent
    for (i:=0; i<num; ++i) w(' ')
    return this
  }

  private ObjEncoder wStr(Str s)
  {
    out.writeChars(s)
    return this
  }

  private ObjEncoder w(Int ch)
  {
    out.writeChar(ch)
    return this
  }

//////////////////////////////////////////////////////////////////////////
// Options
//////////////////////////////////////////////////////////////////////////

  private Void initOptions([Str:Obj] options)
  {
    indent = options.get("indent", indent)
    skipDefaults = options.get("skipDefaults", skipDefaults)
    skipErrors = options.get("skipErrors", skipErrors)
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private OutStream out
  private Int level  := 0
  private Int indent := 0
  private Bool skipDefaults := false
  private Bool skipErrors := false
  private Type? curFieldType

}