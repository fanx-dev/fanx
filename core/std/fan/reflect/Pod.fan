//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Jan 06  Brian Frank  Creation
//


**
** Pod represents a module of Types.  Pods serve as a type namespace
** as well as unit of deployment and versioning.
**
native final const class Pod
{
//////////////////////////////////////////////////////////////////////////
// Management
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the pod of the given instance which is convenience
  ** for 'Type.of(obj).pod'.  See `Type.pod`.
  **
  static Pod? of(Obj obj)

  **
  ** Get a list of all the pods installed.  Note that currently this
  ** method will load all of the pods into memory, so it is an expensive
  ** operation.
  **
  static Pod[] list()

  **
  ** Find a pod by name.  If the pod doesn't exist and checked
  ** is false then return null, otherwise throw UnknownPodErr.
  **
  static Pod? find(Str name, Bool checked := true)

  **
  ** Load a pod into memory from the specified input stream.  The
  ** stream must contain a valid pod zip file with the all the definitions.
  ** The pod is completely loaded into memory and the input stream is
  ** closed.  The pod cannot have resources.  The pod name as defined
  ** by '/pod.def' must be uniquely named or Err is thrown.
  **
  //static Pod load(InStream in)

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Private constructor.
  **
  private new make()

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  **
  ** Simple name of the pod such as "sys".
  **
  Str name()

  **
  ** Version number for this pod.
  **
  Version version()

  **
  ** Get the declared list of dependencies for this pod.
  **
  Depend[] depends()

  **
  ** Uri for this pod which is always "fan://{name}".
  **
  Uri uri()

  **
  ** Always return name().
  **
  override Str toStr()

  **
  ** Get the meta name/value pairs for this pod.
  ** See [docLang]`docLang::Pods#meta`.
  **
  Str:Str meta()

//////////////////////////////////////////////////////////////////////////
// Types
//////////////////////////////////////////////////////////////////////////

  **
  ** List of the all defined types.
  **
  Type[] types()

  **
  ** Find a type by name.  If the type doesn't exist and checked
  ** is false then return null, otherwise throw UnknownTypeErr.
  **
  Type? type(Str name, Bool checked := true)

//////////////////////////////////////////////////////////////////////////
// Resource Files
//////////////////////////////////////////////////////////////////////////

  **
  ** List all the resource files contained by this pod.  Resources
  ** are any files included in the pod's zip file excluding fcode
  ** files.  The URI of these files is rooted by `uri`.  Use `file`
  ** or `Uri.get` to lookup a resource file.
  **
  File[] files()

  **
  ** Look up a resource file in this pod.  The URI must start
  ** with the Pod's `uri` or be path absolute.  If the file cannot
  ** be found then return null or throw UnresolvedErr based on checked
  ** flag.
  **
  ** Examples:
  **   Pod.find("icons").file(`/x16/cut.png`)
  **   Pod.find("icons").file(`fan://icons/x16/cut.png`)
  **   `fan://icons/x16/cut.png`.get
  **
  File? file(Uri uri, Bool checked := true)

//////////////////////////////////////////////////////////////////////////
// Doc
//////////////////////////////////////////////////////////////////////////

  **
  ** Return the fandoc chapter for this pod or null if not available.
  ** To get the summary string for the pod use:
  **   pod.meta["pod.summary"]
  **
  Str? doc()

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  **
  ** Return the log for this pod's name.  This is a
  ** convenience for 'Log.get(name)'.
  **
  Log log()

  **
  ** Convenience for `Env.props`.
  **
  //Str:Str props(Uri uri, Duration maxAge)

  **
  ** Convenience for `Env.config`.
  **
  Str? config(Str name, Str? defV := null)

  **
  ** Convenience for `Env.locale` using `Locale.cur`.
  **
  Str? locale(Str name, Str? defV := "pod::name")
}