//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   30 Jan 06  Brian Frank  Creation
//   06 Jul 07  Brian Frank  Port from Java
//

**
** TypeParser is used to parser formal type signatures into CTypes.
**
**   x::N
**   x::V[]
**   x::V[x::K]
**   |x::A, ... -> x::R|
**
class TypeParser
{

//////////////////////////////////////////////////////////////////////////
// Factory
//////////////////////////////////////////////////////////////////////////

  **
  ** Parse the signature into a resolved CType.  We *don't*
  ** use the CNamespace's cache - it is using me when a signature
  ** isn't found in the cache.  But we do use the CPod's type cache
  ** via CPod.resolveType.
  **
  public static CType resolve(CNamespace ns, Str sig)
  {
    // if last char is ? then parse as nullable
    //echo("resolve $sig")
    last := sig[sig.size-1]
    if (last == '?') return resolve(ns, sig[0..-2]).toNullable

    // if the last character isn't ] or |, then this a non-generic
    // type and we don't even need to allocate a parser
    if (last != ']' && last != '|' && last != '>')
    {
      colon    := sig.index("::")
      podName  := sig[0..<colon]
      typeName := sig[colon+2..-1]

      //GenericParameterType
      pos := typeName.index("^")
      if (pos != null) {
        parentName := typeName[0..<pos]
        name := typeName[pos+1..-1]
        parent := ns.resolvePod(podName, null).resolveType(parentName, true)
        gptype := parent.getGenericParameter(name)
        return gptype
      }
      return ns.resolvePod(podName, null).resolveType(typeName, true)
    }

    // we got our work cut out for us - create parser
    return TypeParser(ns, sig).loadTop
  }

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  private new make(CNamespace ns, Str sig)
  {
    this.ns    = ns
    this.sig   = sig
    this.len   = sig.size
    this.pos   = 0
    this.cur   = sig[pos]
    this.peek  = sig[pos+1]
  }

//////////////////////////////////////////////////////////////////////////
// Parse
//////////////////////////////////////////////////////////////////////////

  private CType loadTop()
  {
    t := loadAny
    if (cur != 0) throw err
    return t
  }

  private CType loadAny()
  {
    CType? t

    // |...| is function
    if (cur == '|')
      t = loadFunc

    // [ is either [ffi]xxx or [K:V] map
    else if (cur == '[')
    {
      ffi := true
      for (i:=pos+1; i<len; ++i)
      {
        ch := sig[i]
        if (isIdChar(ch)) continue
        ffi = (ch == ']')
        break
      }

      if (ffi)
        t = loadFFI
      else
        t = loadMap
    }
    // otherwise must be basic[]
    else {
      t = loadBasic
    }

    if (cur == '<') {
      t = loadGenericParam(t)
    }

    // nullable
    if (cur == '?')
    {
      consume('?')
      t = t.toNullable
    }

    // anything left must be series of [] or []?
    while (cur == '[')
    {
      consume('[')
      consume(']')
      t = t.toListOf

      if (cur == '?')
      {
        consume('?')
        t = t.toNullable
      }
    }
    
    return t
  }

  private CType loadGenericParam(CType base) {
    consume('<')
    params := CType[,]
    while (true) {
      if (cur == '>') {
        consume
        break
      }
      else if (cur == ',') {
        consume
        continue
      }
      params.add(loadAny)
    }
    return ParameterizedType.create(base, params)
  }

  private CType loadMap()
  {
    consume('[')
    key := loadAny
    consume(':')
    val := loadAny
    consume(']')
    return MapType(key, val)
  }

  private CType loadFunc()
  {
    consume('|')
    params := CType[,]
    names  := Str[,]
    if (cur != '-')
    {
      while (true)
      {
        params.add(loadAny)
        names.add(('a'+names.size).toChar)
        if (cur == '-') break
        consume(',')
      }
    }
    consume('-')
    consume('>')
    ret := loadAny
    consume('|')

    return FuncType(params, names, ret)
  }

  private CType loadFFI()
  {
    // [java]foo.bar.foo
    start := pos
    while (cur != ':' || peek != ':') consume
    //podName := sig[start..<pos]

    consume(':')
    consume(':')

    // Baz or [Baz
    //start = pos
    while (cur == '[') consume
    while (isIdChar(cur)) consume
    //typeName := sig[start..<pos]
    qname := sig[start..<pos]

    return ns.resolveType(qname);
  }

  private CType loadBasic()
  {
    start := pos
    while (cur != ':' || peek != ':') consume
    consume(':')
    consume(':')
    while (isIdChar(cur)) consume
    qname := sig[start..<pos]

    //GenericParameterType
    if (cur == '^') {
        consume
        start2 := pos
        while (isIdChar(cur)) consume
        name := sig[start2..<pos]
        parent := ns.resolveType(qname)
        gptype := parent.getGenericParameter(name)
        if (gptype == null) {
          echo("$parent, $name, $qname, $sig")
        }
        return gptype
    }
    return ns.resolveType(qname)
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  private Void consume(Int? expected := null)
  {
    if (expected != null && cur != expected) throw err
    cur = peek
    pos++
    peek = pos+1 < len ? sig[pos+1] : 0
  }

  private static Bool isIdChar(Int ch)
  {
    ch.isAlphaNum || ch == '_'
  }

  private ArgErr err()
  {
    ArgErr("Invalid type signature '" + sig + "'")
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private CNamespace ns  // namespace we are loading from
  private Str sig        // signature being parsed
  private Int len        // length of sig
  private Int pos        // index of cur in sig
  private Int cur        // cur character; sig[pos]
  private Int peek       // next character; sig[pos+1]

}