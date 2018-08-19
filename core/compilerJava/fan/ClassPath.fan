//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//    15 Nov 08  Brian Frank  Creation
//

**
** ClassPath models a Java classpath to resolve package
** names to types.  Since the standard Java APIs don't expose
** this, we have go thru a lot of pain.
**
class ClassPath
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Find all jars in system classpath
  **
  static File[] findSysClassPathFiles()
  {
    entries := File[,]

    // System.property "sun.boot.class.path"; this is preferable
    // to trying to figure out rt.jar - on platforms like Mac OS X
    // the classes are in very non-standard locations
    Env.cur.vars.get("sun.boot.class.path", "").split(File.pathSep[0]).each |Str path|
    {
      f := File.os(path)
      if (!f.exists) return
      if (!f.isDir && f.ext != "jar") return
      if (javaIgnore[f.name] != null) return
      entries.add(f)
    }

    // {java}lib/rt.jar (only if sun.boot.class.path failed)
    lib := File.os(Env.cur.vars.get("java.home", "") + File.sep + "lib")
    if (entries.isEmpty)
    {
      rt := lib + `rt.jar`
      if (rt.exists) entries.add(rt)
    }

    // {java}lib/ext
    lib.plus(`ext/`).list.each |f|
    {
      if (f.ext != "jar") return
      if (javaIgnore[f.name] != null) return
      entries.add(f)
    }

    // {fan}lib/java/ext
    // {fan}lib/java/ext/{plat}
    addJars(entries, Env.cur.homeDir + `lib/java/ext/`)
    addJars(entries, Env.cur.homeDir + `lib/java/ext/${Env.cur.platform}/`)
    addJars(entries, Env.cur.homeDir + `lib/java/stub/`)

    // -classpath
    Env.cur.vars.get("java.class.path", "").split(File.pathSep[0]).each |Str path|
    {
      f := File.os(path)
      if (f.exists) entries.add(f)
    }

    return entries
  }

  private static Void addJars(File[] entries, File dir)
  {
    dir.list.each |f| { if (f.ext == "jar") entries.add(f) }
  }

  // ignore the common big jars that ship with
  // HotSpot which don't contain public java packages
  private static const Str:Str javaIgnore := [:].addList(
  [
    "deploy.jar",
    "charsets.jar",
    "javaws.jar",
    "jsse.jar",
    "resources.jar",
    "dnsns.jar",
    "localedata.jar",
    "sunec.jar",
    "sunec_provider.jar",
    "sunjce_provider.jar",
    "sunmscapi.jar",
    "sunpkcs11.jar",
    "zipfs.jar",
  ])

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Construct for given list of jar files or directoris.
  **
  new make(File[] files)
  {
    start := Duration.now
    this.files = files
    this.packages = loadPackages
    this.dur = Duration.now - start
  }

//////////////////////////////////////////////////////////////////////////
// Access
//////////////////////////////////////////////////////////////////////////

  ** Class path files (jar or dirs) to search
  const File[] files

  ** Open zip files
  private Zip[] zips := [,]

  ** Packages keyed by package name in "." format
  Str:ClassPathPackage packages { private set }

  ** Return list of files.
  override Str toStr() { files.toStr }

  ** Close all open zip files
  Void close()
  {
    zips.each |zip| { zip.close }
  }

  ** Load time duration
  private Duration dur

//////////////////////////////////////////////////////////////////////////
// Loading
//////////////////////////////////////////////////////////////////////////

  private Str:ClassPathPackage loadPackages()
  {
    acc := Str:ClassPathPackage[:]
    files.each |File f|  { loadFile(acc, f) }
    return acc
  }

  private Void loadFile(Str:ClassPathPackage acc, File f)
  {
    if (f.isDir)
    {
      f.walk |File x| { accept(acc, x.uri.relTo(f.uri), f, false) }
    }
    else
    {
      Zip? zip := null
      try
      {
        zip = Zip.open(f)
        isBoot := f.name == "rt.jar"
        zips.add(zip)
        zip.contents.each |File x, Uri uri| { accept(acc, uri, x, isBoot) }
      }
      catch (Err e)
      {
        echo("ERROR: $typeof: $f")
        e.trace
      }
    }
  }

  private Void accept(Str:ClassPathPackage acc, Uri uri, File file, Bool isBoot)
  {
    // don't care about anything but .class files
    if (uri.ext != "class") return

    // convert URI to package name, skip non-public 'com.sun' if rt.jar
    packageName := uri.path[0..-2].join(".")
    if (isBoot)
    {
      //if (packageName.startsWith("com.sun") || packageName.startsWith("sun"))
      //  return
    }

    // get simple name of class
    name := uri.basename
    if (name == "Void") return

    // get or add package
    package := acc[packageName]
    if (package == null) acc[packageName] = package = ClassPathPackage(packageName)

    // add class to package if not already defined
    if (package.classes[name] == null) package.classes[name] = file
  }

  Void dump(OutStream out := Env.cur.out)
  {
    out.printLine("--- ClassPath ---")
    out.printLine("Packages Found:")
    classes := 0
    packages.vals.sort.each |p|
    {
      classes += p.classes.size
      out.printLine("  $p [" + p.classes.size + "]")
    }
    out.printLine("ClassPath Files:")
    files.each |File f| { echo("  $f") }
    out.printLine("${dur.toLocale}, $files.size files, $packages.size packages, $classes classes")
    out.printLine("-----------------")
  }

  static Void main()
  {
    cp := ClassPath(findSysClassPathFiles)
    cp.close
    cp.dump
  }
}

**************************************************************************
** ClassPathPackage
**************************************************************************

**
** ClassPathPackage models a single package found in the class
** path with a map of classnames to classfiles.
**
class ClassPathPackage
{
  new make(Str name) { this.name = name }

  ** Package name in "." format
  const Str name

  ** Classfiles keyed by simple name (not qualified name)
  Str:File classes := [:] { private set }

  ** Return name
  override Str toStr() { name }
}

