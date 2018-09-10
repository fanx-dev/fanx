//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   5 Jun 06  Brian Frank  Creation
//

**
** Tokenize is responsible for parsing all the source files into a
** a list of tokens.  Each source file is mapped to a CompilationUnit
** and stored in the PodDef.units field:
**   Compiler.srcFiles -> Compiler.pod.units
**
** During the standard pipeline this step is called by the InitInput step.
**
class Tokenize : CompilerStep
{

  new make(Compiler compiler)
    : super(compiler)
  {
    input = compiler.input
  }

  override Void run()
  {
    log.debug("Tokenize")
    switch (input.mode)
    {
      case CompilerInputMode.str:  runStrMode
      case CompilerInputMode.file: runFileMode
      default: throw UnsupportedErr()
    }
  }

  private Void runStrMode()
  {
    tokenize(input.srcStrLoc, input.srcStr)
  }

  private Void runFileMode()
  {
    compiler.srcFiles.each |file|
    {
      loc := Loc.makeFile(file)
      try
      {
        src := file.readAllStr
        tokenize(loc, src)
      }
      catch (CompilerErr err)
      {
        throw err
      }
      catch (Err e)
      {
        if (file.exists)
          throw err("Cannot read source file: $e", loc)
        else
          throw err("Source file not found", loc)
      }
    }
  }

  CompilationUnit tokenize(Loc loc, Str src)
  {
    unit := CompilationUnit(loc, pod)
    tokenizer := Tokenizer(compiler, loc, src, input.includeDoc)
    unit.tokens = tokenizer.tokenize
    pod.units.add(unit)
    return unit
  }

  CompilerInput input
}