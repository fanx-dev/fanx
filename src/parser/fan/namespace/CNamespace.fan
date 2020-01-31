//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Sep 05  Brian Frank  Creation
//   29 Aug 06  Brian Frank  Ported from Java to Fan
//

**
** CNamespace is responsible for providing a unified view pods, types,
** and slots between the entities currently being compiled and the
** entities being imported from pre-compiled pods.
**
abstract class CNamespace
{

//////////////////////////////////////////////////////////////////////////
// Initialization
//////////////////////////////////////////////////////////////////////////

  **
  ** Once the sub class is initialized, it must call this
  ** method to initialize our all predefined values.
  **
  protected Void init()
  {
  }

  private CTypeDef sysType(Str name)
  {
    return sysPod.resolveType(name, true)
  }

  private CTypeDef findType(Str podName, Str name) {
    pod := resolvePod(podName, null)
    return pod.resolveType(name, true)
  }

  private CMethod sysMethod(CTypeDef t, Str name)
  {
    m := t.slots[name] as CMethod
    if (m == null) throw Err("Cannot resolve '${t.qname}.$name' method in namespace")
    return m
  }

//////////////////////////////////////////////////////////////////////////
// Cleanup
//////////////////////////////////////////////////////////////////////////

  Void cleanup()
  {
    bridgeCache.each |bridge|
    {
      try
        bridge.cleanup
      catch (Err e)
        e.trace
    }
  }

//////////////////////////////////////////////////////////////////////////
// Resolution
//////////////////////////////////////////////////////////////////////////

  **
  ** Resolve to foreign function interface bridge.
  ** Bridges are loaded once for each compiler session.
  **
  private CBridge resolveBridge(Str name, Loc? loc)
  {
    // check cache
    bridge := bridgeCache[name]
    if (bridge != null) return bridge

    // delegate to findBridge
    bridge = findBridge(name, loc)

    // put into cache
    bridgeCache[name] = bridge
    return bridge
  }
  private Str:CBridge bridgeCache := Str:CBridge[:]  // keyed by pod name

  **
  ** Subclass hook to resolve a FFI name to a CBridge implementation.
  ** Throw CompilerErr if there is a problem resolving the bridge.
  ** The default implementation attempts to resolve the indexed
  ** property "compiler.bridge.$name" to a Type qname.
  **
  protected virtual CBridge findBridge(Str name, Loc? loc)
  {
    // resolve the compiler bridge using indexed props
    t := Env.cur.index("compiler.bridge.${name}")
    if (t.size > 1)
      throw CompilerErr("Multiple FFI bridges available for '$name': $t", loc)
    if (t.size == 0)
      throw CompilerErr("No FFI bridge available for '$name'", loc)

    // construct bridge instance
    try
      return Type.find(t.first).make()
    catch (Err e)
      throw CompilerErr("Cannot construct FFI bridge '$t.first'", loc, e)
  }

  **
  ** Attempt to import the specified pod name against our
  ** dependency library.  If not found then throw CompilerErr.
  **
  CPod resolvePod(Str podName, Loc? loc)
  {
    // check cache
    pod := podCache[podName]
    if (pod != null) return pod

    if (podName[0] == '[')
    {
      // we have a FFI, route to bridge
      sep := podName.index("]")
      ffi := podName[1..<sep]
      package := podName[sep+1..-1]
      pod = resolveBridge(ffi, loc).resolvePod(package, loc)
    }
    else
    {
      // let namespace resolve it
      pod = findPod(podName)
      if (pod == null)
        throw CompilerErr("Pod not found '$podName'", loc)
    }

    // stash in the cache and return
    podCache[podName] = pod
    return pod
  }
  private Str:CPod podCache := Str:CPod[:]  // keyed by pod name
  Void addCurPod(Str name, CPod pod) { podCache[name] = pod }

  **
  ** Subclass hook to resolve a pod name to a CPod implementation.
  ** Return null if not found.
  **
  protected abstract CPod? findPod(Str podName)

  **
  ** Attempt resolve a signature against our dependency
  ** library.  If not a valid signature or it can't be
  ** resolved, then throw Err.
  **
  CType resolveType(Str sig)
  {
    // check our cache first
    t := typeCache[sig]
    if (t != null) return t

    // parse it into a CType
    t = TypeParser.parse(sig)
    resolveTypeRef(t, null)
    typeCache[sig] = t
    return t
  }
  internal Str:CType typeCache := Str:CType[:]   // keyed by signature
  
  Void resolveTypeRef(CType typeRef, Loc? loc) {
    pod := this.resolvePod(typeRef.podName, loc)
    //GenericParameterType
    typeName := typeRef.name
    pos := typeName.index("^")
    if (pos != null) {
      parentName := typeName[0..<pos]
      name := typeName[pos+1..-1]
      parent := pod.resolveType(parentName, true)
      gptype := parent.getGenericParameter(name)
      return typeRef.resolveTo(gptype)
    }
    typeRef.resolveTo(pod.resolveType(typeName, true))
    if (typeRef.genericArgs != null) {
      typeRef.genericArgs.each {
        resolveTypeRef(it, loc)
      }
    }
  }

  **
  ** Attempt resolve a slot against our dependency
  ** library.  If can't be resolved, then throw Err.
  **
  CSlot resolveSlot(Str qname)
  {
    dot := qname.indexr(".")
    slot := resolveType(qname[0..<dot]).slot(qname[dot+1..-1])
    if (slot == null) throw Err("Cannot resolve slot: $qname")
    return slot
  }

//////////////////////////////////////////////////////////////////////////
// Compiler
//////////////////////////////////////////////////////////////////////////

//  ** Used for resolveBridge only
//  internal Compiler compiler() { c ?: throw Err("Compiler not associated with CNamespace") }
//  internal Compiler? c

//////////////////////////////////////////////////////////////////////////
// Dependencies
//////////////////////////////////////////////////////////////////////////

  **
  ** Map of dependencies keyed by pod name set in ResolveDepends.
  **
  [Str:Depend]? depends

//////////////////////////////////////////////////////////////////////////
// Predefined
//////////////////////////////////////////////////////////////////////////

  once CPod? sysPod() { resolvePod("sys", null) }

  // place holder type used for resolve errors
  once CTypeDef? error() { PlaceHolderTypeDef("Error") }

  // place holder type used to indicate nothing (like throw expr)
  once CTypeDef? nothingType() { PlaceHolderTypeDef("Nothing") }

  // generic type for it block until we can infer type
//  once FuncType? itBlockType() {
//    t := FuncType.makeItBlock(objType.toNullable)
//    t.inferredSignature = true
//    return t
//  }

  once CTypeDef? objType              () { findType("sys", "Obj") }
  once CTypeDef? boolType             () { findType("sys", "Bool") }
  once CTypeDef? enumType             () { findType("sys", "Enum") }
  once CTypeDef? facetType            () { findType("sys", "Facet") }
  once CTypeDef? intType              () { findType("sys", "Int") }
  once CTypeDef? floatType            () { findType("sys", "Float") }
  once CTypeDef? strType              () { findType("sys", "Str") }
  once CTypeDef? strBufType           () { findType("sys", "StrBuf") }
  once CTypeDef? listType             () { findType("sys", "List") }
  once CTypeDef? funcType             () { findType("sys", "Func") }
  once CTypeDef? errType              () { findType("sys", "Err") }
  once CTypeDef? typeType             () { findType("std", "Type") }
  once CTypeDef? ptrType              () { findType("sys", "Ptr") }
  once CTypeDef? rangeType            () { findType("sys", "Range") }
  once CTypeDef? voidType             () { findType("sys", "Void") }
  once CTypeDef? fieldNotSetErrType   () { findType("sys", "FieldNotSetErr") }
  once CTypeDef? notImmutableErrType  () { findType("sys", "NotImmutableErr") }
  once CTypeDef? thisType             () { findType("sys", "This") }

  once CTypeDef? decimalType() { findType("std", "Decimal") }
  once CTypeDef? durationType() { findType("std", "Duration") }
  once CTypeDef? mapType() { findType("std", "Map") }
  once CTypeDef? podType() { findType("std", "Pod") }
  once CTypeDef? slotType() { findType("std", "Slot") }
  once CTypeDef? fieldType() { findType("std", "Field") }
  once CTypeDef? methodType() { findType("std", "Method") }
  once CTypeDef? testType() { findType("std", "Test") }
  once CTypeDef? uriType() { findType("std", "Uri") }
  once CTypeDef? asyncType() { findType("concurrent", "Async") }
  once CTypeDef? promiseType() { findType("concurrent", "Promise") }

  once CMethod? objTrap            () { sysMethod(objType,    "trap") }
  once CMethod? objWith            () { sysMethod(objType,    "with") }
  once CMethod? objToImmutable     () { sysMethod(objType,    "toImmutable") }
  once CMethod? boolNot            () { sysMethod(boolType,    "not") }
  once CMethod? intIncrement       () { sysMethod(intType,    "increment") }
  once CMethod? intDecrement       () { sysMethod(intType,    "decrement") }
  once CMethod? intPlus            () { sysMethod(intType,    "plus") }
  once CMethod? floatPlus          () { sysMethod(floatType,    "plus") }
  once CMethod? floatMinus         () { sysMethod(floatType,    "minus") }
  once CMethod? strPlus            () { sysMethod(strType,    "plus") }
  once CMethod? strBufMake         () { sysMethod(strBufType,    "make") }
  once CMethod? strBufAdd          () { sysMethod(strBufType,    "add") }
  once CMethod? strBufToStr        () { sysMethod(strBufType,    "toStr") }
  once CMethod? listMake           () { sysMethod(listType,    "make") }
  once CMethod? listMakeObj        () { sysMethod(listType,    "makeObj") }
  once CMethod? listAdd            () { sysMethod(listType,    "add") }
  once CMethod? listToNullable     () { sysMethod(listType,    "toNullable") }
  once CMethod? mapMake            () { sysMethod(mapType,    "make") }
  once CMethod? mapSet             () { sysMethod(mapType,    "set") }
  once CMethod? enumOrdinal        () { sysMethod(enumType,    "ordinal") }
  once CMethod? funcBind           () { sysMethod(funcType,    "bind") }
  once CMethod? rangeMakeInclusive () { sysMethod(rangeType,    "makeInclusive") }
  once CMethod? rangeMakeExclusive () { sysMethod(rangeType,    "makeExclusive") }
  once CMethod? slotFindMethod     () { sysMethod(slotType,    "findMethod") }
  once CMethod? slotFindFunc       () { sysMethod(slotType,    "findFunc") }
  once CMethod? podFind            () { sysMethod(podType,    "find") }
  once CMethod? podLocale          () { sysMethod(podType,    "locale") }
  once CMethod? typePod            () { sysMethod(typeType,    "pod") }
  once CMethod? typeField          () { sysMethod(typeType,    "field") }
  once CMethod? typeMethod         () { sysMethod(typeType,    "method") }
  once CMethod? funcCall           () { sysMethod(funcType,    "call") }
  once CMethod? fieldNotSetErrMake () { sysMethod(fieldNotSetErrType,    "make") }
  once CMethod? notImmutableErrMake() { sysMethod(notImmutableErrType,    "make") }
  once CMethod decimalMakeMethod   () { sysMethod(decimalType,  "fromStr") }
  once CMethod uriMakeMethod       () { sysMethod(uriType,  "fromStr") }
  once CMethod durationMakeMethod  () { sysMethod(durationType,  "fromTicks") }
/*
  once CMethod? funcEnterCtor() {
    mockFlags := FConst.Public + FConst.Virtual
    return MockMethod(funcType, "enterCtor",   mockFlags, voidType, [objType])
  }
  once CMethod? funcExitCtor() {
    mockFlags := FConst.Public + FConst.Virtual
    return MockMethod(funcType, "exitCtor",    mockFlags, voidType, CType[,])
  }
  once CMethod? funcCheckInCtor() {
    mockFlags := FConst.Public + FConst.Virtual
    return MockMethod(funcType, "checkInCtor", mockFlags, voidType, [objType])
  }
*/
}