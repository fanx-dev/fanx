//
// Copyright (c) 2017, chunquedong
// Licensed under the LGPL
// History:
//   2018-08-12  Jed Young  Creation
//


**
** JSON Object
**
class JVal {
  Obj? obj

  new make(Obj? obj) {
    this.obj = obj
  }

  new makeMap() {
    this.obj = OrderedMap<Str,Obj?>()
  }

  new makeList() {
    this.obj = Obj?[,]
  }

  override Str toStr() { "$obj" }

//////////////////////////////////////////////////////////////////////////
// parse
//////////////////////////////////////////////////////////////////////////

  **
  ** parse object from JSON string
  **
  static JVal readJson(Str str) {
    obj := JsonInStream(str.in).readJson
    return JVal(obj)
  }

  **
  ** writes objects in JSON string
  ** @std nonstandard will omit the quotation of object key
  ** @encode encode the unicode char
  **
  Str writeJson(Bool std := true, Bool encode := false) {
    buf := StrBuf()
    jout := JsonOutStream(buf.out)
    jout.std = std
    jout.encode = encode
    jout.writeJson(this)
    return buf.toStr
  }

//////////////////////////////////////////////////////////////////////////
// xpath
//////////////////////////////////////////////////////////////////////////

  JVal xpath(Str path) {
    buf := StrBuf()
    paths := Obj[,]
    for (i:=0; i<path.size; ++i) {
      c := path[i]
      if (c == '/') {
        if (buf.size > 0) {
          paths.add(buf.toStr)
          buf.clear
        }
      }
      else if (c == '[') {
        paths.add(buf.toStr)
        buf.clear
        ++i
        while (i < path.size) {
          c2 := path[i]
          if (c2 != ']') {
            buf.addChar(c2)
          }
          else break
          ++i
        }
        pos := buf.toStr
        buf.clear
        paths.add(pos.toInt)
      }
      else {
        buf.addChar(c)
      }
    }
    if (buf.size > 0) {
      paths.add(buf.toStr)
    }
    //echo(paths)
    return getInPath(paths)
  }

  private JVal getInPath(Obj[] paths) {
    if (paths.size == 0) return this
    first := paths.first

    JVal? child
    if (first is Int) child = getAt((Int)first)
    else child = get(first.toStr)

    paths.removeAt(0)
    return child.getInPath(paths)
  }

//////////////////////////////////////////////////////////////////////////
// check type
//////////////////////////////////////////////////////////////////////////

  Bool isMap() { obj is Str:Obj? }
  Bool isList() { obj is Obj?[] }
  Bool isStr() { obj is Str }
  Bool isInt() { obj is Int }
  Bool isFloat() { obj is Float }
  Bool isBool() { obj is Bool }
  Bool isNull() { obj === null }
  Bool isNum() { obj is Int || obj is Float }

//////////////////////////////////////////////////////////////////////////
// safe convert
//////////////////////////////////////////////////////////////////////////

  Str:Obj? asMap() {
    (obj as Str:Obj?) ?: Map.defVal
  }

  Obj?[] asList() {
    (obj as Obj?[]) ?: List.defVal
  }

  Str asStr() {
    (obj as Str) ?: ""
  }

  Int asInt() {
    (obj as Int) ?: 0
  }

  Float asFloat() {
    (obj as Float) ?: 0.0
  }

  Bool asBool() {
    (obj as Bool) ?: false
  }

  Obj? asNull() { null }

//////////////////////////////////////////////////////////////////////////
// Collection op
//////////////////////////////////////////////////////////////////////////

  Int size() {
    if (obj is Obj?[]) {
      return ((Obj?[])obj).size
    }
    else if (obj is Str:Obj?) {
      return ((Str:Obj?)obj).size
    }
    return 0
  }

  JVal getAt(Int i) {
    list := asList()
    //echo("$i $obj")
    if (i < 0) {
      i += list.size
    }
    if (i < 0 || i >= list.size) {
      return JVal(null)
    }
    return asVal(list[i])
  }

  @Operator
  This add(Obj? elem) {
    list := (Obj?[])obj
    elem = asVal(elem)
    list.add(elem)
    return this
  }

  @Operator
  JVal get(Str name, JVal defVal := JVal(null)) {
    map := asMap
    res := map.get(name, defVal)
    return asVal(res)
  }

  @Operator
  This set(Str name, Obj? elem) {
    map := (Str:Obj?)obj
    elem = asVal(elem)
    map.set(name, elem)
    return this
  }

  static JVal asVal(Obj? obj) {
    if (obj isnot JVal) return JVal(obj)
    return obj
  }

//////////////////////////////////////////////////////////////////////////
// trap
//////////////////////////////////////////////////////////////////////////

  override Obj? trap(Str name, Obj?[]? args := null) {
    if (args == null || args.size == 0) {
      return get(name)
    }
    else if (args.size == 1) {
      set(name, args.first)
      return null
    }
    return super.trap(name, args)
  }
}