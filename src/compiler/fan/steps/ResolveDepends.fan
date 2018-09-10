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
  new make(Compiler compiler)
    : super(compiler)
  {
    loc = compiler.input.inputLoc
  }

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  **
  ** Run the step
  **
  override Void run()
  {
    log.debug("ResolveDepends")

    // if the input has no dependencies, then
    // assume a dependency on sys
    input := compiler.input
    myName := input.podName
    isSys := myName == "sys"
    if (compiler.depends.isEmpty && !isSys)
      compiler.depends.add(CDepend.fromStr("sys 2"))

    // we initialize the CNamespace.depends map
    // as we process each dependency
    ns.depends = Str:CDepend[:]

    // process each dependency
    compiler.depends.each |cdepend|
    {
      ns.depends[cdepend.name] = cdepend
      cdepend.pod = resolveDepend(cdepend.depend)
    }

    // check that everything has a dependency on sys
    if (!ns.depends.containsKey("sys") && !isSys)
      err("All pods must have a dependency on 'sys'", loc)

    bombIfErr

    // now that we've resolved all depends, ensure there are no
    // cyclic dependencies; this means that none of my dependent
    // pods should have a cyclic dependency back on me
    ns.depends.each |myDepend|
    {
      if (myDepend.name == myName) err("Cyclic dependency on self '$myName'", loc)
      myDepend.pod.depends.each |podDepend|
      {
        if (podDepend.name == myName)
          err("Cyclic dependency on '$myDepend.name'", loc)
      }
    }

    bombIfErr
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