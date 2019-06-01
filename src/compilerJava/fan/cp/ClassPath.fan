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

  ** Get the classpath for the current Java runtime.
  **
  ** The following are also searched when constructing the class path:
  **  - {fan}lib/java/ext
  **  - {fan}lib/java/ext/{plat}
  **  - Locations specified in the '-classpath' (as made available in
  **   the 'java.class.path' system property)
  **  - Any additional locations specified via the 'addCp' parameter
  **
  static ClassPath forRuntime(File[] addCp := File#.emptyList)
  {
    libs := ClassLib[,]

    // Get libraries for the current runtime
    if (Env.cur.javaVersion <= 8) libs.addAll(JarClassLib.findClassicLibs)
    else libs.addAll(ModuleClassLib.findModuleLibs)

    // {fan}lib/java/ext
    // {fan}lib/java/ext/{plat}
    addJars(libs, Env.cur.homeDir + `lib/java/ext/`)
    addJars(libs, Env.cur.homeDir + `lib/java/ext/${Env.cur.platform}/`)

    // -classpath
    Env.cur.vars.get("java.class.path", "").split(File.pathSep[0]).each |Str path|
    {
      f := File.os(path)
      if (f.exists) libs.add(JarClassLib(f))
    }

    // user-specified classpath
    addCp.each |file| { libs.add(JarClassLib(file)) }

    return ClassPath(libs)
  }

  private static Void addJars(ClassLib[] libs, File dir)
  {
    dir.list.each |f| { if (f.ext == "jar") libs.add(JarClassLib(f)) }
  }

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Build the class path as the aggregate of all packages in the given
  ** class libraries.
  **
  private new make(ClassLib[] libs)
  {
    this.libs = libs
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  ** The class libraries
  private ClassLib[] libs

  ** Load time duration
  private Duration dur := Duration.defVal

//////////////////////////////////////////////////////////////////////////
// ClassPath
//////////////////////////////////////////////////////////////////////////

  once Str:ClassPathPackage packages()
  {
    acc   := Str:ClassPathPackage[:]
    start := Duration.now
    libs.each |lib|
    {
      lib.loadPackages.each |libPackage, packageName|
      {
        package := acc[packageName]
        if (package == null) acc[packageName] = package = ClassPathPackage(packageName)

        package.classes.setAll(libPackage.classes)
      }
    }
    this.dur = Duration.now - start
    return acc
  }

  This close()
  {
    libs.each |lib| { lib.close }
    return this
  }

  ** Return list of sources.
  override Str toStr() { libs.toStr }

//////////////////////////////////////////////////////////////////////////
// Main
//////////////////////////////////////////////////////////////////////////

  This dump(OutStream out := Env.cur.out)
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
    libs.each |lib| { echo("  $lib") }
    out.printLine("${dur.toLocale}, $libs.size sources, $packages.size packages, $classes classes")
    out.printLine("-----------------")
    return this
  }

  static Void main()
  {
    ClassPath.forRuntime.dump.close
  }
}