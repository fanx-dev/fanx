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
  private const Str _name
  private const Version _version
  private const Depend[] _depends
  private const Uri _uri
  private const [Str:Str] _meta
  private const Type[] _types
  private const [Str:Type] _typeMap

//////////////////////////////////////////////////////////////////////////
// Management
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the pod of the given instance which is convenience
  ** for 'Type.of(obj).pod'.  See `Type.pod`.
  **
  static Pod? of(Obj obj) { Type.of(obj).pod }

  **
  ** Get a list of all the pods installed.  Note that currently this
  ** method will load all of the pods into memory, so it is an expensive
  ** operation.
  **
  static Pod[] list() { Reflect.listPod }

  **
  ** Find a pod by name.  If the pod doesn't exist and checked
  ** is false then return null, otherwise throw UnknownPodErr.
  **
  static Pod? find(Str name, Bool checked := true) {
    Reflect.findPod(name, checked)
  }

  **
  ** Load a pod into memory from the specified input stream.  The
  ** stream must contain a valid pod zip file with the all the definitions.
  ** The pod is completely loaded into memory and the input stream is
  ** closed.  The pod cannot have resources.  The pod name as defined
  ** by '/pod.def' must be uniquely named or Err is thrown.
  **
  native static Pod load(InStream in)

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Private constructor.
  **
  private new make(Str name, Str version, Str[] depends, [Str:Str] meta, Type[] types) {
    _name = name
    _version = Version(version)
    _depends = depends.map { Depend(it) }
    _uri = Uri.fromStr("fan://" + name);
    _meta = meta
    _types = types
    typeMap := [Str:Type][:]
    types.each {
      typeMap[it.name] = it
    }
    _typeMap = typeMap
  }

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  **
  ** Simple name of the pod such as "sys".
  **
  Str name() { _name }

  **
  ** Version number for this pod.
  **
  Version version() { _version }

  **
  ** Get the declared list of dependencies for this pod.
  **
  Depend[] depends() { _depends }

  **
  ** Uri for this pod which is always "fan://{name}".
  **
  Uri uri() { _uri }

  **
  ** Always return name().
  **
  override Str toStr() { name }

  **
  ** Get the meta name/value pairs for this pod.
  ** See [docLang]`docLang::Pods#meta`.
  **
  Str:Str meta() { _meta }

//////////////////////////////////////////////////////////////////////////
// Types
//////////////////////////////////////////////////////////////////////////

  **
  ** List of the all defined types.
  **
  Type[] types() { _types }

  **
  ** Find a type by name.  If the type doesn't exist and checked
  ** is false then return null, otherwise throw UnknownTypeErr.
  **
  Type? type(Str name, Bool checked := true) {
    _typeMap.getChecked(name, checked)
  }

//////////////////////////////////////////////////////////////////////////
// Resource Files
//////////////////////////////////////////////////////////////////////////

  **
  ** List all the resource files contained by this pod.  Resources
  ** are any files included in the pod's zip file excluding fcode
  ** files.  The URI of these files is rooted by `uri`.  Use `file`
  ** or `Uri.get` to lookup a resource file.
  **
  native File[] files()

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
  native File? file(Uri uri, Bool checked := true)

//////////////////////////////////////////////////////////////////////////
// Doc
//////////////////////////////////////////////////////////////////////////

  **
  ** Return the fandoc chapter for this pod or null if not available.
  ** To get the summary string for the pod use:
  **   pod.meta["pod.summary"]
  **
  Str? doc() { null }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  **
  ** Return the log for this pod's name.  This is a
  ** convenience for 'Log.get(name)'.
  **
  Log log() { Log.get(name) }

  **
  ** Convenience for `Env.props`.
  **
  Str:Str props(Uri uri, Duration maxAge) {
    Env.cur.props(this, uri, maxAge)
  }

  **
  ** Convenience for `Env.config`.
  **
  Str? config(Str name, Str? defV := null) {
    Env.cur.config(this, name, defV)
  }

  **
  ** Convenience for `Env.locale` using `Locale.cur`.
  **
  Str? locale(Str name, Str? defV := "pod::name") {
    Env.cur.locale(this, name, defV)
  }


  @NoDoc native Obj? _getCompilerCache()
  @NoDoc native Void _setCompilerCache(Obj? obj)
}