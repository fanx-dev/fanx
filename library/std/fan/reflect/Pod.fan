//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Jan 06  Brian Frank  Creation
//

internal rtconst class PodList {
  private [Str:Pod] podMap := [:]
  private Lock lock := Lock()
  private Bool inited := false

  internal const static PodList cur := PodList()

  private new make() {}

  Pod[] listPod() {
    names := Env.cur.findAllPodNames
    return names.map { findPod(it) }
  }

  private native Void doInit()
  private Void init() {
    lock.lock
    if (!inited) {
      doInit
      inited = true
    }
    lock.unlock
  }

  //call in native
  internal static Void addPod(Pod pod) {
    cur.podMap[pod.name] = pod
  }

  Pod? findPod(Str name, Bool checked := true) {
    init
    lock.lock
    pod := podMap.getChecked(name, false)
    if (pod == null) {
      podFile := Env.cur.findPodFile(name)
      if (podFile != null) {
        pod = Pod.makeZip(Zip.open(podFile))
        if (!name.equals(pod.name))
            throw IOErr("Pod name mismatch " + name + " != " + pod.name);
        cur.podMap[name] = pod
      }
    }
    lock.unlock
    if (checked && pod == null) {
        throw UnknownPodErr(name)
    }
    return pod
  }

  override Bool isImmutable() {
    true
  }

  override Obj toImmutable() {
    this
  }
}

**
** Pod represents a module of Types.  Pods serve as a type namespace
** as well as unit of deployment and versioning.
**
native final rtconst class Pod
{
  private const Str _name
  private const Version _version
  private const Depend[] _depends
  private const Uri _uri
  private [Str:Str] _meta
  private Type[] _types
  private [Str:Type] _typeMap
  private Obj? compilerCache

  private Bool inited := false
  private Lock lock := Lock()

  private Zip? _file

//////////////////////////////////////////////////////////////////////////
// Management
//////////////////////////////////////////////////////////////////////////

  private native Void doInit()
  private Void init() {
    lock.lock
    if (!inited) {
      doInit
      inited = true
    }
    lock.unlock
  }

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
  static Pod[] list() { PodList.cur.listPod }

  **
  ** Find a pod by name.  If the pod doesn't exist and checked
  ** is false then return null, otherwise throw UnknownPodErr.
  **
  static Pod? find(Str name, Bool checked := true) {
    PodList.cur.findPod(name, checked)
  }

  **
  ** Load a pod into memory from the specified input stream.  The
  ** stream must contain a valid pod zip file with the all the definitions.
  ** The pod is completely loaded into memory and the input stream is
  ** closed.  The pod cannot have resources.  The pod name as defined
  ** by '/pod.def' must be uniquely named or Err is thrown.
  **
  static Pod load(InStream in) {
    zip := Zip.read(in)
    return Pod(zip)
  }

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Private constructor.
  **
  internal new makeZip(Zip zip) {
    props := zip.contents("fcode")[`/meta.props`].in.readProps

    metaName := props.get("pod.name")
    version := props.get("pod.version")
    depends := props.get("pod.depends")

    _version = Version(version)
    if (depends.isEmpty) _depends = Depend[,]
    else _depends = depends.split(';').map { Depend(it) }
    _name = metaName
    _uri = Uri.fromStr("fan://" + _name);
    _meta = props
    _types = Type[,]
    _typeMap = [Str:Type][:]
    _file = zip
  }

  internal new make(Str name, Str version, Str depends) {
    _version = Version(version)
    if (depends.isEmpty) _depends = Depend[,]
    else _depends = depends.split(';').map { Depend(it) }
    _name = name
    _uri = Uri.fromStr("fan://" + _name);
    _meta = [:]
    _types = Type[,]
    _typeMap = [Str:Type][:]
  }

  internal Void addType(Type t) {
    _types.add(t)
    _typeMap[t.name] = t
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
  [Str:Str] meta() { _meta }

//////////////////////////////////////////////////////////////////////////
// Types
//////////////////////////////////////////////////////////////////////////

  **
  ** List of the all defined types.
  **
  Type[] types() { init; return _types }

  **
  ** Find a type by name.  If the type doesn't exist and checked
  ** is false then return null, otherwise throw UnknownTypeErr.
  **
  Type? type(Str name, Bool checked := true) {
    init
    return _typeMap.getChecked(name, checked)
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
  File[] files() {
    _file.contents("fcode").vals.findAll { it.ext != "fcode" && it.ext != "class" }
  }

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
  File? file(Uri uri, Bool checked := true) {
    f := _file.contents("fcode")[uri]
    if (f.ext == "fcode" || f.ext == "class") {
      f = null
    }
    if (checked && f == null) {
      throw UnresolvedErr("$name, $uri")
    }
    return f
  }

//////////////////////////////////////////////////////////////////////////
// Doc
//////////////////////////////////////////////////////////////////////////

  **
  ** Return the fandoc chapter for this pod or null if not available.
  ** To get the summary string for the pod use:
  **   pod.meta["pod.summary"]
  **
  Str? doc() { meta["pod.summary"] }

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
  [Str:Str] props(Uri uri, Duration maxAge) {
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


  @NoDoc Obj? _getCompilerCache() { compilerCache }
  @NoDoc Void _setCompilerCache(Obj? obj) { compilerCache = obj }

  override Bool isImmutable() {
    true
  }

  override Obj toImmutable() {
    this
  }


  **
  ** Expand a set of pods to include all their recurisve dependencies.
  ** This method is does not order them; see `orderByDepends()`.
  **
  static Pod[] flattenDepends(Pod[] pods) {
    acc := [Str:Pod][:]
    for (i:=0; i<pods.size; ++i)
      doFlattenDepends(acc, pods[i])
    return acc.vals
  }

  private static Void doFlattenDepends([Str:Pod] acc, Pod pod)
  {
    if (acc[pod.name] != null) return
    acc[pod.name] = pod
    depends := pod.depends
    for (i:=0; i<depends.size; ++i)
    {
      d := depends[i]
      doFlattenDepends(acc, Pod.find(d.name));
    }
  }


  **
  ** Order a list of pods by their dependencies.
  ** This method does not flatten dependencies - see `flattenDepends()`.
  **
  static Pod[] orderByDepends(Pod[] pods) {
    left := pods.dup.sort
    ordered := Pod[,] { capacity = pods.size }
    while (!left.isEmpty)
    {
      // find next pod that doesn't have depends in left list
      i := 0
      for (i = 0; i<left.size; ++i)
        if (noDependsInLeft(left, left[i])) break
      ordered.add(left.removeAt(i))
    }
    return ordered
  }

  private static Bool noDependsInLeft(Pod[] left, Pod p)
  {
    depends := p.depends
    for (i:=0; i<depends.size; ++i)
    {
      d := depends[i]
      for (j:=0; j<left.size; ++j)
        if (d.name == left[j].name)
          return false
    }
    return true
  }
}