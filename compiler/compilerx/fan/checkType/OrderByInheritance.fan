//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Sep 06  Brian Frank  Creation
//

**
** OrderByInheritance orders the list of TypeDefs from top to bottom
** such that any inherited types are guaranteed to be positioned first
** in the types list.  During this process we check for duplicate type
** names and cyclic inheritance.
**
class OrderByInheritance : CompilerStep
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(CompilerContext compiler)
    : super(compiler)
  {
    ordered = TypeDef[,]
    processing = Str:TypeDef[:]
    todo = Str:TypeDef[:]
  }

//////////////////////////////////////////////////////////////////////////
// Run
//////////////////////////////////////////////////////////////////////////

  override Void run()
  {
    //log.debug("OrderByInheritance")
    types := compiler.pod.types
    ordered.capacity = types.size

    // create the todo map which is our working input,
    // check for duplicate type names in this loop
    types.each |TypeDef t|
    {
      todo[t.qname] = t
    }
    //bombIfErr

    // process each type in order
    types.each |TypeDef t| { process(t) }
    //bombIfErr

    // use ordered types for rest of pipeline
    if (ordered.size != types.size) throw Err("Internal error")
    compiler.pod.types = ordered
  }

//////////////////////////////////////////////////////////////////////////
// Process
//////////////////////////////////////////////////////////////////////////

  private Void process(TypeDef t)
  {
    // check that this type is still in the todo
    // list, otherwise we've already processed it
    // or it is imported from another pod
    def := todo[t.qname]
    if (def == null) return

    // check if this guy is in the processing queue,
    // in which case we have cyclic inheritance
    if (processing.containsKey(def.qname))
    {
      err("Cyclic inheritance for '$def.name'", def.loc)
      return
    }
    processing[def.qname] = def

    // process inheritance
    def.inheritances.each |CType m| { process(m.typeDef) }

    // now that is has been processed, removed it the
    // todo map and add it to the ordered result list
    processing.remove(def.qname)
    todo.remove(def.qname)
    ordered.add(def)
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  Str:TypeDef processing  // map of qname to typse being processed
  Str:TypeDef todo        // map of qname to types left to process
  TypeDef[] ordered       // ordered result list
}