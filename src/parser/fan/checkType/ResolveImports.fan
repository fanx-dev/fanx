//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Dec 05  Brian Frank  Creation
//    5 Jun 06  Brian Frank  Ported from Java to Fan
//

**
** ResolveImports maps every Using node in each CompilationUnit to a pod
** and ensures that it exists and that no imports are duplicated.  Then we
** create a map for all the types which are imported into the CompilationUnit
** so that the Parser can quickly distinguish between a type identifier and
** other identifiers.  The results of this step populate Using.resolvedXXX and
** CompilationUnit.importedTypes.
**
class ResolveImports : CompilerStep
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Constructor takes the associated Compiler
  **
  new make(CompilerContext compiler)
    : super(compiler)
  {
    //resolved[pod.name] = pod
  }

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  **
  ** Run the step
  **
  override Void run()
  {
    //debug("ResolveImports")
    
    // process each unit for Import.pod
    compiler.cunits.each |CompilationUnit unit|
    {
      try
        resolveImports(unit)
      catch (CompilerErr e)
        errReport(e)
    }

    // process each unit for CompilationUnit.importedTypes
    compiler.cunits.each |CompilationUnit unit|
    {
      try
        resolveImportedTypes(unit)
      catch (CompilerErr e)
        errReport(e)
    }

    // if this is a script, make our using imports the depends
    if (compiler.input.isScript)
    {
      resolved.each |pod|
      {
        if (pod !== compiler.pod && pod.name != "sys")
          compiler.pod.resolvedDepends[pod.name] = pod
      }
    }
  }

  **
  ** Resolve all the imports in the specified unit
  ** and ensure there are no duplicates.
  **
  private Void resolveImports(CompilationUnit unit)
  {
    // map to keep track of duplicate imports
    // within this compilation unit
    dups := Str:Using[:]

    // process each import statement (remember the
    // first one is an implicit import of sys)
    unit.usings.each |Using u|
    {
      podName := u.podName

      // check that this podName was in the compiler's
      // input dependencies
      checkUsingPod(this.compiler, podName, u.loc)

      // don't allow a using my own pod
      if (u.typeName == null && u.podName == compiler.pod.name) {
        warn("Using '$u.podName' is on pod being compiled", u.loc)
        return
      }

      // check for duplicate imports
      key := podName
      if (u.typeName != null) key += "::$u.typeName"
      if (u.asName != null) key += " as $u.asName"
      if (dups.containsKey(key))
      {
        err("Duplicate using '$key'", u.loc)
        return
      }
      dups[key] = u

      // if already resolved, then just use it
      u.resolvedPod = resolved[podName]

      // resolve the import and cache in resolved map
      if (u.resolvedPod == null)
      {
        try
        {
          pod := ns.resolvePod(podName, u.loc)
          resolved[podName] = u.resolvedPod = pod
        }
        catch (CompilerErr e)
        {
          errReport(e)
          return
        }
        catch {
          return
        }
      }

      // if type specified, then resolve type
      if (u.typeName != null)
      {
        
        u.resolvedType = CType(u.podName, u.typeName)
        try
        {
          ns.resolveTypeRef(u.resolvedType, u.loc)
          if (!u.resolvedType.isResolved)
          {
            err("Type not found in pod '$podName::$u.typeName'", u.loc)
            return
          }
        }
        catch (CompilerErr e) {
          errReport(e)
        }
      }
    }
  }
  
  private once CTypeDef[] defaultImportedTypes() {
    res := CTypeDef[,]
    if (podName != "sys") {
      //std and reflect is imported implicitly
      if (podName != "std") {
        if (compiler.pod.resolvedDepends.containsKey("std")) {
          pod := ns.resolvePod("std", compiler.pod.loc)
          res.addAll(pod.types)
        }
      }
      pod := ns.resolvePod("sys", compiler.pod.loc)
      res.addAll(pod.types)
    }
    return res
  }

  **
  ** Create a unified map of type names to CType[] for all the
  ** imports in the specified unit (this includes types within
  ** the pod being compilied itself).  For example if foo::Thing
  ** and bar::Thing are imported, then importedTypes would contain
  **   "Thing" : [foo::Thing, bar::Thing]
  **
  private Void resolveImportedTypes(CompilationUnit unit)
  {
    // name -> CType[]
    types := [Str:CType[]][:]

    //import system default pod types
    addAll(types, defaultImportedTypes)
    
    // add types for my own pod
    addAll(types, compiler.pod.types)
    
    // add pod level imports first
    unit.usings.each |Using u|
    {
      if (u.typeName == null && u.resolvedPod != null)
        addAll(types, u.resolvedPod.types)
    }

    // add type specific imports last (these
    // override any pod level imports)
    unit.usings.each |Using u|
    {
      if (u.typeName != null && u.resolvedType != null)
      {
        if (u.asName == null)
        {
          types[u.typeName] = [u.resolvedType]
        }
        else
        {
          remove(types, u.resolvedType)
          types[u.asName] = [u.resolvedType]
        }
      }
    }

//    if (pod.name == "sys") addAll(types, sizedPrimitive.vals)

    /*
    // dump
    echo("--- types for $unit")
    ids := types.keys.sort
    ids.each |Str id| { echo("$id = ${types[id]}") }
    */

    // save away on unit
    unit.importedTypes = types
  }

//  private once Str:CType sizedPrimitive() {
//    intType := ns.intType
//    floatType := ns.floatType
//
//    return [
//     "Int8"  : SizedPrimitiveType(intType, "8"),
//     "Int16" : SizedPrimitiveType(intType, "16"),
//     "Int32" : SizedPrimitiveType(intType, "32"),
//     "Int64" : SizedPrimitiveType(intType, "64"),
//     "Float32" : SizedPrimitiveType(floatType, "32"),
//     "Float64" : SizedPrimitiveType(floatType, "64")
//    ]
//  }

  private Void addAll([Str:CType[]] types, CTypeDef[] toAdd)
  {
    toAdd.each |CTypeDef t|
    {
      list := types.get(t.name)
      if (list == null) {
        list = CType[,]
        types.set(t.name, list)
      }
      list.add(t.asRef)
    }
  }

  private Void remove([Str:CType[]] types, CType t)
  {
    list := types[t.name+t.extName]
    if (list != null)
    {
      for (i:=0; i<list.size; ++i)
        if (list[i].qname == t.qname) { list.removeAt(i); break }
    }
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  **
  ** Resolve a fully qualified type name into its CType representation.
  ** This may be a TypeDef within the compilation units or could be
  ** an imported type.  If the type name cannot be resolved then we
  ** log an error and return null.
  **
//  static CType? resolveQualified(CompilerContext cs, Str podName, Str typeName, Loc loc)
//  {
//    // first check pod being compiled
//    if (podName == cs.pod.name)
//    {
//      t := cs.pod.resolveType(typeName, false)
//      if (t == null)
//      {
//        cs.errors.err("Type '$typeName' not found within pod being compiled", loc)
//        return null
//      }
//      return t
//    }
//
//    // resolve pod
//    pod := resolvePod(cs, podName, loc)
//    if (pod == null) return null
//
//    // now try to lookup type
//    t := pod.resolveType(typeName, false)
//    if (t == null)
//    {
//      cs.errors.err("Type '$typeName' not found in pod '$podName'", loc);
//      return null
//    }
//
//    return t
//  }

//  **
//  ** Resolve a pod name into its CPod representation.  If pod
//  ** cannot be resolved then log an error and return null.
//  **
//  static CPod? resolvePod(CompilerContext cs, Str podName, Loc loc)
//  {
//    // if this is the pod being compiled no further checks needed
//    if (cs.pod.name == podName) return cs.pod
//
//    // otherwise we need to try to resolve pod
//    CPod? pod := null
//    try
//    {
//      pod = cs.ns.resolvePod(podName, loc)
//    }
//    catch (CompilerErr e)
//    {
//      cs.errors.errReport(e)
//      return null
//    }
//
//    // check that we have a dependency on the pod
//    checkUsingPod(cs, podName, loc)
//
//    return pod
//  }

  **
  ** Check that a pod name is in the dependency list.
  **
  private static Void checkUsingPod(CompilerContext cs, Str podName, Loc loc)
  {
    // scripts don't need dependencies
    if (cs.input.isScript) return

    // if we have a declared dependency that is ok
    if (cs.pod.resolvedDepends.containsKey(podName)) return

    // if this is the pod being compiled that is obviously ok
    if (cs.pod.name == podName) return

    // we don't require explicit dependencies on FFI
    if (podName.startsWith("[")) return

    // we got a problem
    cs.log.err("Using '$podName' which is not a declared dependency for '$cs.pod.name'", loc)
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  Str:CPod resolved := Str:CPod[:]  // reuse CPods across units

}