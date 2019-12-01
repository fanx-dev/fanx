//
// Copyright (c) 2019, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//    08 May 19  Matthew Giannini Creation
//

using [java] java.net::URI
using [java] java.nio.file
using [java] fanx.interop::Interop

**************************************************************************
** ClassLib
**************************************************************************

**
** ClassLib models a file that contains java packages and class files.
**
abstract class ClassLib
{
  new make(File file) { this.file = file }

  ** The file to load package from.
  const File file

  ** Load packages keyed by package name in "." format.
  abstract Str:ClassPathPackage loadPackages()

  ** Release any resources that the library may have opened when loading
  ** the packages. Return this.
  virtual This close() { return this }

  override Str toStr() { file.toStr }

//////////////////////////////////////////////////////////////////////////
// Util
//////////////////////////////////////////////////////////////////////////

  ** Common utility to determine if a given '.class' file should be accepted or not.
  ** If it is accepted it will be added to the given accumulator.
  protected Void accept([Str:ClassPathPackage] acc, Uri uri, File f, Bool isBoot := false)
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
    if (package.classes[name] == null) package.classes[name] = f
  }
}

**************************************************************************
** JarClassLib
**************************************************************************

**
** JarClassLib can load packages from JAR files, or from directories
** on the file system that represent an "exploded" JAR file.
**
final class JarClassLib : ClassLib
{
  new make(File file) : super(file)
  {
  }

  private Zip? zip := null

  once override Str:ClassPathPackage loadPackages()
  {
    acc := Str:ClassPathPackage[:]
    if (this.file.isDir)
    {
      file.walk |File x| { accept(acc, x.uri.relTo(file.uri), x) }
    }
    else
    {
      try
      {
        this.zip = Zip.open(this.file)
        isBoot := file.name == "rt.jar"
        zip.contents.each |File x, Uri uri| { accept(acc, uri, x, isBoot) }
      }
      catch (Err e)
      {
        echo("ERROR: $this.typeof: $file")
        e.trace
      }
    }
    return acc
  }

  override This close()
  {
    zip?.close
    return super.close
  }

//////////////////////////////////////////////////////////////////////////
// System Libs
//////////////////////////////////////////////////////////////////////////

  ** Find all jars in system classpath (Java 1.8 and earlier)
  static JarClassLib[] findClassicLibs()
  {
    libs := JarClassLib[,]

    // System.property "sun.boot.class.path"; this is preferable
    // to trying to figure out rt.jar - on platforms like Mac OS X
    // the classes are in very non-standard locations
    Env.cur.vars.get("sun.boot.class.path", "").split(File.pathSep[0]).each |Str path|
    {
      f := File.os(path)
      if (!f.exists) return
      if (!f.isDir && f.ext != "jar") return
      if (javaIgnore[f.name] != null) return
      libs.add(JarClassLib(f))
    }

    // {java}lib/rt.jar (only if sun.boot.class.path failed)
    lib := File.os(Env.cur.vars.get("java.home", "") + File.sep + "lib")
    if (libs.isEmpty)
    {
      rt := lib + `rt.jar`
      if (rt.exists) libs.add(JarClassLib(rt))
    }

    // {java}lib/ext
    lib.plus(`ext/`).list.each |f|
    {
      if (f.ext != "jar") return
      if (javaIgnore[f.name] != null) return
      libs.add(JarClassLib(f))
    }

    return libs
  }

  // ignore the common big jars that ship with
  // HotSpot which don't contain public java packages
  private static const [Str:Str] javaIgnore := [:].addList(
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
}

**************************************************************************
** ModuleClassLib
**************************************************************************

**
** ModuleClassLib can load packages and class files from java modules.
**
final class ModuleClassLib : ClassLib
{
  new make(File file) : super(file)
  {

  }

  once override Str:ClassPathPackage loadPackages()
  {
    acc := Str:ClassPathPackage[:]
    file.walk |File x|
    {
      // get an absolute Uri for the just package portion of the module path
      //   Example: jrt:/module/java.base/java/lang/ => /java/lang/
      uri := `/`.plus(x.uri.relTo(file.uri))
      accept(acc, uri, x, true)
    }
    return acc
  }

//////////////////////////////////////////////////////////////////////////
// System Libs
//////////////////////////////////////////////////////////////////////////

  static ModuleClassLib[] findModuleLibs()
  {
    fs := FileSystems.getFileSystem(URI.create("jrt:/"))
    modules := Interop.toFan(Files.list(fs.getPath("/modules", Str[,])).iterator)

    return modules.findAll |Path path->Bool| {
      f := Interop.toFan(path)
      if (!f.isDir) return false

      moduleName := f.name

      // JDK modules
      if (moduleName.startsWith("jdk."))
      {
        // ignore all JDK modules except jdk.management
        if (!moduleName.startsWith("jdk.management")) return false
      }

      return true
    }
    .map |Path path->ModuleClassLib| { ModuleClassLib(Interop.toFan(path)) }
  }
}

**************************************************************************
** ClassPathPackage
**************************************************************************

**
** ClassPathPackage models a single package found in the class
** path with a map of classnames to ClassFiles.
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