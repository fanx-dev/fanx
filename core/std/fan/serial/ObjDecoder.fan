//
// Copyright (c) 2007, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 Aug 07  Brian Frank  Creation
//


/**
 * ObjDecoder parses an object tree from an input stream.
 */
class ObjDecoder
{

//////////////////////////////////////////////////////////////////////////
// Static
//////////////////////////////////////////////////////////////////////////

  static Obj decode(Str s)
  {
    return ObjDecoder(s.in, null).readRootObj
  }

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  /**
   * Construct for input stream.
   */
  new make(InStream in, [Str:Obj]? options)
  {
    tokenizer = Tokenizer(in)
    this.options = options
    consume
  }

//////////////////////////////////////////////////////////////////////////
// Parse
//////////////////////////////////////////////////////////////////////////

  /**
   * Read an object from the stream.
   */
  Obj? readRootObj()
  {
    readHeader
    return readObj(null, null, true)
  }

  /**
   * header := [using]*
   */
  private Void readHeader()
  {
    while (curt == Token.USING)
    {
      Using u := readUsing
      /*
      if (usings == null) usings = Using[8]
      if (numUsings  >= usings.size)
      {
        Using[] temp = Using[usings.length*2]
        System.arraycopy(usings, 0, temp, 0, numUsings )
        usings = temp
      }
      */
      usings.add(u)
    }
  }

  /**
   * using   := usingPod | usingType | usingAs
   * usingPod  := "using" podName
   * usingType := "using" podName::typeName
   * usingAs   := "using" podName::typeName "as" name
   */
  private Using readUsing()
  {
    Int line := tokenizer.line
    consume

    Str podName := consumeId("Expecting pod name")
    Pod? pod := Pod.find(podName, false)
    if (pod == null) throw err("Unknown pod: " + podName)
    if (curt != Token.DOUBLE_COLON)
    {
      endOfStmt(line)
      return UsingPod(pod)
    }

    consume
    Str typeName := consumeId("Expecting type name")
    Type? t := pod.type(typeName, false)
    if (t == null) throw err("Unknown type: " + podName + "::" + typeName)

    if (curt == Token.AS)
    {
      consume
      typeName = consumeId("Expecting using as name")
    }

    endOfStmt(line)
    return UsingType(t, typeName)
  }

  /**
   * obj := literal | simple | complex
   */
  private Obj? readObj(Field? curField, Type? peekType, Bool root)
  {
    // literals are stand alone
    if (Token.isLiteral(curt))
    {
      Obj? val := tokenizer.val
      consume
      return val
    }

    // [ is always list/map collection (or map/FFI type)
    if (curt == Token.LBRACKET)
      return readCollection(curField, peekType)

    // at this poInt all remaining options must start
    // with a type signature - if peekType is non-null
    // then we've already read the type signature
    Int line := tokenizer.line
    Type t := (peekType != null) ? peekType : readType

    // type:   type#
    // simple:   type(
    // list/map: type[
    // complex:  type || type{
    if (curt == Token.LPAREN)
      return readSimple(line, t)
    else if (curt == Token.POUND)
      return readTypeOrSlotLiteral(line, t)
    else if (curt == Token.LBRACKET)
      return readCollection(curField, t)
    else
      return readComplex(line, t, root)
  }

  /**
   * typeLiteral := type "#"
   * slotLiteral := type "#" id
   */
  private Obj readTypeOrSlotLiteral(Int line, Type t)
  {
    consumeAs(Token.POUND, "Expected '#' for type literal")
    if (curt == Token.ID && !isEndOfStmt(line))
    {
      Str slotName := consumeId("slot literal name")
      return t.slot(slotName)
    }
    else
    {
      return t
    }
  }

  /**
   * simple := type "(" str ")"
   */
  private Obj readSimple(Int line, Type t)
  {
    // parse: type(str)
    consumeAs(Token.LPAREN, "Expected ( in simple")
    Str str := consumeStr("Expected string literal for simple")
    consumeAs(Token.RPAREN, "Expected ) in simple")

    // lookup the fromStr method
    //t.finish
    Method? m := t.method("fromStr", false)
    if (m == null)
    {
      // fallback to valueOf for java.lang.Enums
      if (t.isJava) m = t.method("valueOf", false)
      if (m == null)
      throw err("Missing method: " + t.qname + ".fromStr", line)
    }

    // invoke parse method to translate into instance
    try
    {
      return m.call(str)
    }
    catch (ParseErr e)
    {
      throw ParseErr.make(e.msg + " [Line " + line + "]", e)
    }
    catch (Err e)
    {
      throw ParseErr.make(e.toStr + " [Line " + line + "]", e)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Complex
//////////////////////////////////////////////////////////////////////////

  /**
   * complex := type [fields]
   * fields  := "{" field (eos field)* "}"
   * field   := name "=" obj
   */
  private Obj readComplex(Int line, Type t, Bool root)
  {
    [Field:Obj?] toSet := [:]
    Obj?[] toAdd := [,]

    // read fields/collection into toSet/toAdd
    readComplexFields(t, toSet, toAdd)

    // get the make constructor
    Method? makeCtor := t.method("make", false)
    if (makeCtor == null || !makeCtor.isPublic)
      throw err("Missing constructor " + t.qname + ".make", line)

    // get argument lists
    Obj?[]? args := null
    if (root && options != null)
      args = options.get("makeArgs")

    // construct object
    Obj? obj := null
    Bool setAfterCtor := true
    try
    {
      // if first parameter is an function then pass toSet
      // as an it-block for setting the fields
      Param? p := makeCtor.params.first
      if (args == null && p != null && p.type.fits(Func#))
      {
        args = [Field.makeSetFunc(toSet)]
        setAfterCtor = false
      }

      // invoke make to construct object
      obj = makeCtor.callList(args)
    }
    catch (Err e)
    {
      throw err("Cannot make " + t + ": " + e, line, e)
    }

    // set fields (if not passed to ctor as it-block)
    if (setAfterCtor && toSet.size > 0)
    {
      toSet.each |v,k|
      {
        complexSet(obj, k, v, line)
      }
    }

    // add
    if (toAdd.size > 0)
    {
      Method? addMethod := t.method("add", false)
      if (addMethod == null) throw err("Method not found: " + t.qname + ".add", line)
      for (Int i:=0; i<toAdd.size; ++i)
        complexAdd(t, obj, addMethod, toAdd.get(i), line)
    }

    return obj
  }

  private Void readComplexFields(Type t, [Field:Obj?] toSet, Obj?[] toAdd)
  {
    if (curt != Token.LBRACE) return
    consume

    // fields and/or collection items
    while (curt != Token.RBRACE)
    {
      // try to read "id =" to see if we have a field
      Int line := tokenizer.line
      Bool readField := false
      if (curt == Token.ID)
      {
        Str name := consumeId("Expected field name")
        if (curt == Token.EQ)
        {
          // we have "id =" so read field
          consume
          readComplexSet(t, line, name, toSet)
          readField = true
        }
        else
        {
          // pushback to reset on start of collection item
          tokenizer.pushUndo(tokenizer.type, tokenizer.val, tokenizer.line)
          curt = tokenizer.reset(Token.ID, name, line)
        }
      }

      // if we didn't read a field, we assume a collection item
      if (!readField) readComplexAdd(t, line, toAdd)

      if (curt == Token.COMMA) consume
      else endOfStmt(line)
    }
    consumeAs(Token.RBRACE, "Expected '}'")
  }

  private Void readComplexSet(Type t, Int line, Str name, [Field:Obj?] toSet)
  {
    // resolve field
    Field? field := t.field(name, false)
    if (field == null) throw err("Field not found: " + t.qname + "." + name, line)

    // parse value
    Obj? val := readObj(field, null, false)

    try
    {
      // if const field, then make val immutable
      if (field.isConst) val = val?.toImmutable
    }
    catch (Err ex)
    {
      throw err("Cannot make object const for " + field.qname + ": " + ex, line, ex)
    }

    // add to map
    toSet.set(field, val)
  }

  private Void complexSet(Obj obj, Field field, Obj? val, Int line)
  {
    try
    {
      if (field.isConst)
        field._set(obj, val?.toImmutable, false)
      else
        field.set(obj, val)
    }
    catch (Err ex)
    {
      throw err("Cannot set field " + field.qname + ": " + ex, line, ex)
    }
  }

  private Void readComplexAdd(Type t, Int line, Obj?[] toAdd)
  {
    Obj val := readObj(null, null, false)

    // add to list
    toAdd.add(val)
  }

  private Void complexAdd(Type t, Obj obj, Method addMethod, Obj val, Int line)
  {
    try
    {
      addMethod.call(obj, val)
    }
    catch (Err ex)
    {
      throw err("Cannot call " + t.qname + ".add: " + ex, line, ex)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Collection
//////////////////////////////////////////////////////////////////////////

  /**
   * collection := list | map
   */
  private Obj readCollection(Field? curField, Type? t)
  {
    // opening [
    consumeAs(Token.LBRACKET, "Expecting '['")

    // if this could be a map/FFI type signature:
    //  [qname:qname]
    //  [qname:qname][]
    //  [qname:qname][][] ...
    //  [java]foo.bar
    // or it could just be the type signature of
    // of a embedded simple, complex, or list
    Type? peekType := null
    if (curt == Token.ID && t == null)
    {
      // peek at the type
      peekType = readType(true)

      // if we have [mapType] then this is non-inferred type signature
      if (curt == Token.RBRACKET && peekType.fits(Map#))
      {
        t = peekType; peekType = null
        consume
        while (curt == Token.LRBRACKET) { consume; t = List#/*t.toListOf*/ }
        if (curt == Token.QUESTION) { consume; t = t.toNullable }
        if (curt == Token.POUND) { consume; return t }
        consumeAs(Token.LBRACKET, "Expecting '['")
      }

      // if the type was a FFI JavaType, this isn't a collection
      if (peekType != null && peekType.isJava)
      return readObj(curField, peekType, false)
    }

    // handle special case of [,]
    if (curt == Token.COMMA && peekType == null)
    {
      consume
      consumeAs(Token.RBRACKET, "Expecting ']'")
      //return List(toListOfType(t, curField, false))
      return [,]
    }

    // handle special case of [:]
    if (curt == Token.COLON && peekType == null)
    {
      consume
      consumeAs(Token.RBRACKET, "Expecting ']'")
      //return Map(toMapType(t, curField, false))
      return [:]
    }

    // read first list item or first map key
    Obj? first := readObj(null, peekType, false)

    // now we can distinguish b/w list and map
    if (curt == Token.COLON)
      return readMap(first)
    else
      return readList(first)
  }

  /**
   * list := "[" obj ("," obj)* "]"
   */
  private Obj readList(Obj? first)
  {
    // setup accumulator
    Obj?[] acc := [ first ]

    // parse list items
    while (curt != Token.RBRACKET)
    {
      consumeAs(Token.COMMA, "Expected ','")
      if (curt == Token.RBRACKET) break
      acc.add(readObj(null, null, false))
    }
    consumeAs(Token.RBRACKET, "Expected ']'")

    return acc
  }

  /**
   * map   := "[" mapPair ("," mapPair)* "]"
   * mapPair := obj ":" + obj
   */
  private Obj readMap(Obj firstKey)
  {
    // setup accumulator
    map := OrderedMap<Obj,Obj?>()

    // finish first pair
    consumeAs(Token.COLON, "Expected ':'")
    map.set(firstKey, readObj(null, null, false))

    // parse map pairs
    while (curt != Token.RBRACKET)
    {
      consumeAs(Token.COMMA, "Expected ','")
      if (curt == Token.RBRACKET) break
      Obj key := readObj(null, null, false)
      consumeAs(Token.COLON, "Expected ':'")
      Obj? val := readObj(null, null, false)
      map.set(key, val)
    }
    consumeAs(Token.RBRACKET, "Expected ']'")

    return map
  }
  /*
  /**
   * Figure out the type of the list:
   *   1) if t was explicit then use it
   *   2) if we have field typed as a list, then use its definition
   *   3) if inferred is false, then drop back to list of Obj
   *   4) If inferred is true then return null and we'll infer the common type
   */
  private Type toListOfType(Type t, Field curField, Bool infer)
  {
    if (t != null) return t
    if (curField != null)
    {
      Type ft = curField.type.toNonNullable
      if (ft instanceof ListType) return ((ListType)ft).v
    }
    if (infer) return null
    return Sys.ObjType.toNullable
  }

  /**
   * Figure out the map type:
   *   1) if t was explicit then use it (check that it was a map type)
   *   2) if we have field typed as a map , then use its definition
   *   3) if inferred is false, then drop back to Obj:Obj
   *   4) If inferred is true then return null and we'll infer the common key/val types
   */
  private MapType toMapType(Type t, Field curField, Bool infer)
  {
    if (t != null)
    {
      try { return (MapType)t }
      catch (ClassCastException e) { throw err("Invalid map type: " + t) }
    }

    if (curField != null)
    {
      Type ft = curField.type.toNonNullable
      if (ft instanceof MapType) return (MapType)ft
    }

    if (infer) return null

    if (defaultMapType == null)
      defaultMapType = MapType(Sys.ObjType, Sys.ObjType.toNullable)
    return defaultMapType
  }

  private static MapType defaultMapType
  */

//////////////////////////////////////////////////////////////////////////
// Type
//////////////////////////////////////////////////////////////////////////

  /**
   * type  := listSig | mapSig1 | mapSig2 | qname
   * listSig := type "[]"
   * mapSig1 := type ":" type
   * mapSig2 := "[" type ":" type "]"
   *
   * Note: the mapSig2 with brackets is handled by the
   * method succinctly named readMapTypeOrCollection.
   */
  private Type readType(Bool lbracket := false)
  {
    Type t := readSimpleType(lbracket)
    if (curt == Token.QUESTION)
    {
      consume
      t = t.toNullable
    }
    if (curt == Token.COLON)
    {
      consume
      readType
      t = Map#
    }
    while (curt == Token.LRBRACKET)
    {
      consume
      t = List#
    }
    if (curt == Token.QUESTION)
    {
      consume
      t = t.toNullable
    }
    return t
  }

  /**
   * qname := [podName "::"] typeName
   */
  private Type readSimpleType(Bool lbracket)
  {
    // parse identifier
    Int line := tokenizer.line
    Str n := consumeId("Expected type signature")
    Bool ffi := false

    // handle [java]foo.bar
    if (n.equals("java") && lbracket)
    {
      ffi = true
      consumeAs(Token.RBRACKET, "Expected ] in Java FFI [java]")
      n = "[java]" + consumeId("Expected Java FFI type name")
      while (curt == Token.DOT || curt == Token.DOLLAR)
      {
        Str symbol := Token.toString(curt)
        consume
        n += symbol + consumeId("Expected Java FFI type name")
      }
    }

    // check for using imported name
    if (curt != Token.DOUBLE_COLON)
    {
      for (Int i:=0; i<usings.size; ++i)
      {
        Type? t := usings[i].resolve(n)
        if (t != null) return t
      }
      throw err("Unresolved type name: " + n)
    }

    // must be fully qualified
    consumeAs(Token.DOUBLE_COLON, "Expected ::")
    Str typeName := consumeId("Expected type name")

    // handle Outer$Inner for Java FFI
    if (curt == Token.DOLLAR)
    {
      Str symbol := Token.toString(curt)
      consume
      typeName += symbol + consumeId("Expected Java FFI type name")
    }

    // if Java FFI, then don't optimize pod/type lookup
    if (ffi) return Type.find(n + "::" + typeName)

    // resolve pod
    Pod? pod := Pod.find(n, false)
    if (pod == null) throw err("Pod not found: " + n, line)

    // resolve type
    Type? type := pod.type(typeName, false)
    if (type == null) throw err("Type not found: " + n + "::" + typeName, line)
    return type
  }

//////////////////////////////////////////////////////////////////////////
// Error Handling
//////////////////////////////////////////////////////////////////////////

  /**
   * Create error reporting exception.
   */
  private Err err(Str msg, Int line := tokenizer.line, Err? e := null)
  {
    return IOErr(msg + " [Line " + line + "]", e)
  }

//////////////////////////////////////////////////////////////////////////
// Tokens
//////////////////////////////////////////////////////////////////////////

  /**
   * Consume the current token as a identifier.
   */
  private Str consumeId(Str expected)
  {
    verify(Token.ID, expected)
    Str id := tokenizer.val
    consume
    return id
  }

  /**
   * Consume the current token as a Str literal.
   */
  private Str consumeStr(Str expected)
  {
    verify(Token.STR_LITERAL, expected)
    Str id := tokenizer.val
    consume
    return id
  }

  /**
   * Check that the current token matches the
   * specified type, and then consume it.
   */
  private Void consumeAs(Int type, Str expected)
  {
    verify(type, expected)
    consume
  }

  /**
   * Check that the current token matches the specified
   * type, but do not consume it.
   */
  private Void verify(Int type, Str expected)
  {
    if (curt != type)
      throw err(expected + ", not '" + Token.toString(curt) + "' ${tokenizer.val}")
  }

  /**
   * Consume the current token.
   */
  private Void consume()
  {
    curt = tokenizer.next
  }

  /**
   * Is current token part of the next statement?
   */
  private Bool isEndOfStmt(Int lastLine)
  {
    if (curt == Token.EOF) return true
    if (curt == Token.SEMICOLON) return true
    return lastLine < tokenizer.line
  }

  /**
   * Statements can be terminated with a semicolon, end of line or } end of block.
   */
  private Void endOfStmt(Int lastLine)
  {
    if (curt == Token.EOF) return
    if (curt == Token.SEMICOLON) { consume; return }
    if (lastLine < tokenizer.line) return
    if (curt == Token.RBRACE) return
    throw err("Expected end of statement: semicolon, newline, or end of block not '" + Token.toString(curt) + "'")
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private Tokenizer tokenizer    // tokenizer
  private Int curt := -1         // current token type
  private [Str:Obj]? options      // decode option name/value pairs
  private Using[] usings := [,]  // using imports
  //private Int numUsings := 0     // number of using imports

}

//////////////////////////////////////////////////////////////////////////
// Using
//////////////////////////////////////////////////////////////////////////

internal abstract class Using
{
  abstract Type? resolve(Str name)
}

internal class UsingPod : Using
{
  new make(Pod p) { pod = p }
  override Type? resolve(Str n) { return pod.type(n, false) }
  const Pod pod
}

internal class UsingType : Using
{
  new make(Type t, Str n) { type = t; name = n }
  override Type? resolve(Str n) { return name.equals(n) ? type : null }
  const Str name
  const Type type
}