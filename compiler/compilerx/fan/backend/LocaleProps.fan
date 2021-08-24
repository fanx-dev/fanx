//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   08 Nov 10  Brian Frank  Creation
//

**
** LocaleProps is used to generate or merge locale/en.props
** if any locale literals specified defaults such as '$<foo=Foo>'
**
class LocaleProps : CompilerStep
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(CompilerContext compiler)
    : super(compiler)
  {
  }

//////////////////////////////////////////////////////////////////////////
// Run
//////////////////////////////////////////////////////////////////////////

  override Void run()
  {
    //log.debug("LocaleProps")
    if (compiler.localeDefs.isEmpty) return

    // check for duplicate key=def pairs
    dups := [Str:LocaleLiteralExpr][:]
    compiler.localeDefs.each |expr|
    {
      dup := dups[expr.key]
      if (dup != null)
        err("Duplicate locale literal defaults for key '$expr.key' [$dup.loc.toLocStr]", expr.loc)
      dups[expr.key] = expr
    }

    // load any props defined in default locale/en.props
    baseProps := [Str:Str][:]
    baseUri := compiler.input.baseDir.uri
    baseFileStr := ""
    defFile := compiler.input.resFiles.find |f| { f.uri.relTo(baseUri) == `locale/en.props` }
    if (defFile != null)
    {
      try
      {
        baseProps = defFile.in.readProps
        baseFileStr = defFile.readAllStr
      }
      catch (Err e)
        throw err("Cannot load base locale/en.props: $e", Loc.makeFile(defFile))
    }

    // verify that no update keys b/w def and baseProps
    baseProps.each |v, k|
    {
      dup := dups[k]
      if (dup != null)
        err("Duplicate locale literal defaults for key '$k' [locale/en.props]", dup.loc)
    }

    // append out defs to baseFileStr
    buf := StrBuf()
    if (!baseFileStr.isEmpty)
    {
      buf.add(baseFileStr)
      buf.add("\n\n")
    }
    buf.add("// locale literal defaults\n")
    compiler.localeDefs.each |expr|
    {
      buf.add(expr.key).add("=").add(expr.def).add("\n")
    }
    compiler.localeProps = buf.toStr

    bombIfErr
  }

}