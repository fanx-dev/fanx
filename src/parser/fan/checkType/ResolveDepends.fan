//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Dec 05  Brian Frank  Creation
//    5 Jun 06  Brian Frank  Ported from Java to Fan
//

**
** ResolveDepends resolves each dependency to a CPod and
** checks the version.  We also set CNamespace.depends in
** this step.
**
class ResolveDepends : CompilerStep
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
    loc = compiler.pod.loc
  }

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  **
  ** Run the step
  **
  override Void run()
  {
    debug("ResolveDepends")

    // if the input has no dependencies, then
    // assume a dependency on sys
    pod := compiler.pod
    isSys := pod.name == "sys"
    if (pod.depends.isEmpty && !isSys)
      pod.depends.add(Depend.fromStr("sys 2"))

    // we initialize the CNamespace.depends map
    // as we process each dependency
    compiler.ns.depends = Str:CPod[:]

    // process each dependency
    resolvePodDepend(pod)

    // check that everything has a dependency on sys
    if (!ns.depends.containsKey("sys"))
      err("All pods must have a dependency on 'sys'", loc)

    // depends self
    ns.depends[pod.name] = pod
  }
  
  private Void resolvePodDepend(CPod pod) {
    pod.depends.each |cdepend|
    {
      name := cdepend.name
      if (name == compiler.pod.name) {
        err("Cyclic dependency on self '$name' in ${pod.name}", loc)
      }
      
      dpod := ns.depends[name]
      if (dpod == null) {
        dpod = resolveDepend(cdepend)
        ns.depends[name] = dpod
        resolvePodDepend(pod)
      }
    }
  }

  **
  ** Resolve the dependency via reflection using
  ** the pods the compiler is running against.
  **
  private CPod? resolveDepend(Depend depend)
  {
    CPod? pod
    try
    {
      pod = ns.resolvePod(depend.name, loc)
    }
    catch (CompilerErr e)
    {
      err("Cannot resolve depend: pod '$depend.name' not found", loc)
      return null
    }

    if (!depend.match(pod.version))
    {
      err("Cannot resolve depend: '$pod.name $pod.version' != '$depend'", loc)
    }

    return pod
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  Loc loc

}