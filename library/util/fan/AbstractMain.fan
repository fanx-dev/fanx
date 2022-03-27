//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   8 Mar 08  Brian Frank  Creation
//   1 Dec 09  Brian Frank  Rename BootScript to AbstractMain
//

using concurrent

**
** AbstractMain provides conveniences for writing the main routine
** of an app. Command line arguments are configured as fields
** with the `Arg` facet:
**
**   @Arg { help = "source file to process" }
**   File? src
**
** Arguments are ordered by the field declaration order.  The
** last argument may be declared as a list to handle a variable
** numbers of arguments.
**
** Command line options are configured as fields with
** the `Opt` facet :
**
**   @Opt { help = "http port"; aliases=["p"] }
**   Int port := 8080
**
** Bool fields should always default to false and are considered
** flag options.  All other arg and opt fields must be a Str, File,
** or have a type which supports a 'fromStr' method.
**
** Option fields may include the "Opt" suffix, and arguments the
** "Arg" suffix.  These suffixes can be used when a field conflicts
** with an existing slot name.
**
** AbstractMain will automatically implement `usage` and
** `parseArgs` based on the fields which are declared as options
** and arguments.  In general subclasses only need to override `run`.
** If writing a daemon main, then you'll probably want to configure
** your services then call `runServices`.
**
** See [example]`examples::util-main`.
**
abstract class AbstractMain
{

//////////////////////////////////////////////////////////////////////////
// Environment
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the application name.  If this is a script it is the
  ** name of the script file.  For a precompiled class called
  ** "Main" this is the pod name, otherwise it is the type name.
  **
  virtual Str appName()
  {
    t := Type.of(this)
    if (t.pod.meta["pod.isScript"] == "true") return Uri.fromStr(t->sourceFile).basename
    if (t.name == "Main") return t.pod.name
    return t.name
  }

  **
  ** Log for this application; defaults to `appName`.
  **
  virtual Log log() { Log.get(appName) }

  **
  ** Home directory for the application.  For a script
  ** this defaults to directory of the script.  For pods
  ** the default is "{Env.cur.workDir}/etc/{pod}".
  **
  virtual File homeDir()
  {
    t := Type.of(this)
    if (t.pod.meta["pod.isScript"] == "true")
      return File(t->sourceFile->toUri).parent
    else
      return Env.cur.workDir + `etc/${t.pod.name}/`
  }

  **
  ** Print usage help.
  **
  @Opt { help = "Print usage help"; aliases = ["?"] }
  Bool helpOpt := false

//////////////////////////////////////////////////////////////////////////
// Command Line
//////////////////////////////////////////////////////////////////////////

  **
  ** Get all the fields annotated with the [@Arg]`Arg` facet.
  **
  virtual Field[] argFields()
  {
    Type.of(this).fields.findAll |f| { f.hasFacet(Arg#) }
  }

  **
  ** Get all the fields annotated with the [@Opt]`Opt` facet.
  **
  virtual Field[] optFields()
  {
    Type.of(this).fields.findAll |f| { f.hasFacet(Opt#) }
  }

  **
  ** Parse the command line and set this instances fields.
  ** Return false if not all of the arguments were passed.
  **
  virtual Bool parseArgs(Str[] toks)
  {
    args := argFields
    opts := optFields
    varArgs := !args.isEmpty && args.last.type.fits(List#)
    argi := 0
    for (i:=0; i<toks.size; ++i)
    {
      tok := toks[i]
      Str? next := i+1 < toks.size ? toks[i+1] : null
      if (tok.startsWith("-"))
      {
        if (parseOpt(opts, tok, next)) ++i
      }
      else if (argi < args.size)
      {
        if (parseArg(args[argi], tok)) ++argi
      }
      else
      {
        log.warn("Unexpected arg: $tok")
      }
    }
    if (argi == args.size) return true
    if (argi == args.size-1 && varArgs) return true
    return false // missing args
  }

  private Bool parseOpt(Field[] opts, Str tok, Str? next)
  {
    n := tok[1..-1]
    for (i:=0; i<opts.size; ++i)
    {
      // if name doesn't match opt or any of its aliases then continue
      field := opts[i]
      facet := (Opt)field.facet(Opt#)
      aliases := facet
      if (optName(field) != n && !facet.aliases.contains(n)) continue

      // if field is a bool we always assume the true value
      if (field.type == Bool#)
      {
        field.set(this, true)
        return false // did not consume next
      }

      // check that we have a next value to parse
      if (next == null || next.startsWith("-"))
      {
        log.err("Missing value for -$n")
        return false // did not consume next
      }

      try
      {
        // parse the value to proper type and set field
        field.set(this, parseVal(field.type, next))
      }
      catch (Err e) log.err("Cannot parse -$n as $field.type.name: $next")
      return true // we *did* consume next
    }

    log.warn("Unknown option -$n")
    return false // did not consume next
  }

  private Bool parseArg(Field field, Str tok)
  {
    isList := field.type.fits(List#)
    try
    {
      // if not a list, this is easy
      if (!isList)
      {
        field.set(this, parseVal(field.type, tok))
        return true // increment argi
      }

      // if list, then parse list item and add to end of list
      //of := field.type.params["V"]
      list := field.get(this) as Obj?[]
      //of := list.of
      sig := field.type.signature
      ofType := sig.extract("<", ">")
      of := Type.find(ofType)
      val :=  parseVal(of, tok)
      //if (list == null) field.set(this, list = List.make(8, of))
      list.add(val)
    }
    catch (Err e) e.trace//log.err("Cannot parse argument as $field.type.name: $tok")
    return !isList // increment argi if not list
  }

  private Str argName(Field f)
  {
    if (f.name.endsWith("Arg")) return f.name[0..<-3]
    return f.name
  }

  private Str optName(Field f)
  {
    if (f.name.endsWith("Opt")) return f.name[0..<-3]
    return f.name
  }

  private Obj? parseVal(Type of, Str tok)
  {
    of = of.toNonNullable
    if (of == Str#) return tok
    if (of == File#)
    {
      if (tok.contains("\\"))
        return File.os(tok).normalize
      else
        return File.make(tok.toUri, false)
    }
    return of.method("fromStr").call(tok)
  }

//////////////////////////////////////////////////////////////////////////
// Usage
//////////////////////////////////////////////////////////////////////////

  **
  ** Print usage of arguments and options.
  ** Return non-zero.
  **
  virtual Int usage(OutStream out := Env.cur.out)
  {
    // get list of argument fields
    args := argFields

    // get list of all documented options
    opts := optFields.findAll |f| { !f.hasFacet(NoDoc#) }

    // format args/opts into columns
    argRows := usagePad(args.map |f| { usageArg(f) })
    optRows := usagePad(opts.map |f| { usageOpt(f) })

    // format summary line
    argSummary := args.join(" ") |field|
    {
      s := "<" + argName(field) + ">"
      if (field.type.fits(List#)) s += "*"
      return s
    }

    // print usage
    out.printLine
    out.printLine("Usage:")
    out.printLine("  $appName [options] $argSummary")
    usagePrint(out, "Arguments:", argRows)
    usagePrint(out, "Options:", optRows)
    out.printLine
    return 1
  }

  private Str[] usageArg(Field field)
  {
    name := argName(field)
    help := field.facet(Arg#)->help as Str
    return [name, help]
  }

  private Str[] usageOpt(Field field)
  {
    name := optName(field)
    def  := field.get(Type.of(this).make)
    help := field.facet(Opt#)->help as Str
    Str[] aliases := field.facet(Opt#)->aliases

    col1 := "-$name"
    if (!aliases.isEmpty) col1 += ", -" + aliases.join(", -")
    if (def != false) col1 += " <$field.type.name>"

    col2 := help
    if (def != false && def != null && def != "") col2 += " (default $def)"

    return [col1, col2]
  }

  private Str[][] usagePad(Str[][] rows)
  {
    if (rows.isEmpty) return rows
    Int max := rows.map |row| { row[0].size }.max
    pad := 20.min(2 + max)
    rows.each |row| { row[0] = row[0].padr(pad) }
    return rows
  }

  private Void usagePrint(OutStream out, Str title, Str[][] rows)
  {
    if (rows.isEmpty) return
    out.printLine(title)
    rows.each |row| { out.printLine("  ${row[0]}  ${row[1]}") }
  }

//////////////////////////////////////////////////////////////////////////
// Run
//////////////////////////////////////////////////////////////////////////

  **
  ** Run the application.  This method is called after the
  ** command line has been parsed.  See `runServices` to
  ** launch a deamon application.  Return status code, zero
  ** for success.
  **
  abstract Int run()

  **
  ** Run the set of services:
  **   1. call install on each service
  **   2. call start on each service
  **   3. put main thread to sleep.
  **   4. on shutodwn call stop on each service
  **   5. then call uninstall on each service
  **
  virtual Int runServices(Service[] services)
  {
    hook := |->| { shutdownServices }
    Env.cur.addShutdownHook(hook)
    services.each |Service s| { s.install }
    services.each |Service s| { s.start }

    while (true) {
      try {
        r := Env.cur.in.readLine()
        //echo("debug $r")
        if (r == "exit") break
      }
      catch {}
      Actor.sleep(500ms)
    }
    shutdownServices
    Env.cur.removeShutdownHook(hook)
    return 0
  }

  private static Void shutdownServices()
  {
    Service.list.each |Service s| { s.stop }
    Service.list.each |Service s| { s.uninstall }
  }

//////////////////////////////////////////////////////////////////////////
// Main
//////////////////////////////////////////////////////////////////////////

  **
  ** Main performs the following tasks:
  **   1. Calls `parseArgs` to parse command line
  **   2. If args were incomplete or -help was specified
  **      then dump usage and return 1
  **   3. Call `run` and return 0
  **   4. If an exception is raised log it and return 1
  **
  virtual Int main(Str[] args := Env.cur.args)
  {
    success := false
    try
    {
      // parse command line
      argsOk := parseArgs(args)

      // if args not ok or help was specified, dump usage
      if (!argsOk || helpOpt)
      {
        usage
        if (!helpOpt) log.err("Missing arguments")
        return 1
      }

      // call run
      return run
    }
    catch (Err err)
    {
      log.err("Cannot boot")
      err.trace
      return 1
    }
  }

}

**************************************************************************
** Arg
**************************************************************************

**
** Facet for annotating an `AbstractMain` argument field.
**
facet class Arg
{
  ** Usage help, should be a single short line summary
  const Str help := ""
}

**************************************************************************
** Opt
**************************************************************************

**
** Facet for annotating an `AbstractMain` option field.
**
facet class Opt
{
  ** Usage help, should be a single short line summary
  const Str help := ""

  ** Aliases for the option
  const Str[] aliases := Str[,]
}

