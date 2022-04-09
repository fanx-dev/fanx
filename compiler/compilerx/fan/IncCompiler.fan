//
// Copyright (c) 2006, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2021-8-15 Jed Young Creation
//
**
** Compiler manages the top level process of the compiler pipeline.
** There are a couple different "pipelines" used to accomplish
** various twists on compiling Fantom code (from memory, files, etc).
** The pipelines are implemented as discrete CompilerSteps.
** As the steps are executed, the Compiler instance itself stores
** the state as we move from files -> ast -> resolved ast -> code.
**
class IncCompiler {
  
  ** compiler context
  CompilerContext context
  
  ** compiler pipeline
  CompilerStep[] pipelines := [,]
  
  
  ** make from empty pod obj
  new make(PodDef pod, CompilerInput? input = null, CNamespace? ns := null) {
    if (input == null) input = CompilerInput()
    if (ns == null) ns = FPodNamespace(null)
    pod.compileJs = input.compileJs
    context = CompilerContext(pod, input, ns)
    ctx := context
    
    pipelines = [
        BasicInit(ctx),
        InitDataClass(ctx),
        DefaultCtor(ctx),
        InitEnum(ctx),
        InitFacet(ctx),
        InitClosures(ctx),
        SlotNormalize(ctx),

        ResolveDepends(ctx),
        ResolveImports(ctx),
        ResolveType(ctx),

        CheckInheritance(ctx),
        CheckInheritSlot(ctx),
        StmtNormalize(ctx),

        ResolveExpr(ctx),
        
        CheckErrors(ctx),
        CheckParamDefs(ctx),
        
        LocaleProps(ctx),
        CompileJs(ctx),
        ClosureVars(ctx),
        ClosureToImmutable(ctx),
        ConstChecks(ctx),
        GenParamDefault(ctx),

        StmtFlat(ctx),
        ExprFlat(ctx),
        GenAsync(ctx),
        
        //backend
        Assemble(ctx),
        GenerateOutput(ctx),
    ]
  }
  
////////////////////////////////////////////////////////////////////////////////
// init from .props file
////////////////////////////////////////////////////////////////////////////////

  ** make from pod build file, and parse all srouce code
  static IncCompiler fromProps(File file) {
    input := PodProps.parseProps(file)
    icom := IncCompiler(input.podDef, input, input.ns)
    return icom
  }
  
////////////////////////////////////////////////////////////////////////////////
// parse
////////////////////////////////////////////////////////////////////////////////

  ** do parse code
  This parseAll() {
    files := context.input.srcFiles
    if (files != null) {
        files.each |f| {
           this.updateSourceFile(f)
        }
    }
    if (context.input.srcStr != null) {
        this.updateSource(context.input.srcStrLoc, context.input.srcStr)
    }
    return this
  }
  
  ** parse souce code
  private CompilationUnit parseCode(Str file, Str code) {
    unit := CompilationUnit(Loc.make(file), context.pod, file.toStr)
    if (file.toUri.ext == "fan" || file.toUri.ext == null) unit.isFanx = false
    if (unit.isFanx) {
        parser := DeepParserX(context.log, code, unit)
        parser.parse
    }
    else {
        parser := DeepParser(context.log, code, unit)
        //echo(parser.tokens.join("\n")|t|{ t.loc.toStr + "\t\t" + t.kind + "\t\t" + t.val })
        parser.parse
    }
    return unit
  }
  
  ** update compiler result by source file
  CompilationUnit? updateSourceFile(File file, Bool isDelete := false) {
    updateSource(file.osPath, file.readAllStr)
  }
  
  ** update compiler result by source str
  CompilationUnit? updateSource(Str file, Str code, Bool isDelete := false) {
    old := context.cunitsMap[file]
    if (old != null) {
      context.cunitsMap.remove(file)
      context.cunits.removeSame(old)
      context.log.clearByFile(file)
    }
    
    if (isDelete) {
      context.pod.updateCompilationUnit(null, old, context.log)
      return old
    }
    
    unit := parseCode(file, code)
    context.pod.updateCompilationUnit(unit, old, context.log)
    
    context.cunitsMap[file] = unit
    context.cunits.add(unit)
    return unit
  }
  
////////////////////////////////////////////////////////////////////////////////
// resolve
////////////////////////////////////////////////////////////////////////////////

  ** run pipelines, do expression resolve and type check
  This checkError() {
    try {
      for (i:=0; i<pipelines.size; ++i) {
         pass := pipelines[i]
         pass.run
         if (pass.typeof == CheckParamDefs#) break
      }
    }
    catch (CompilerErr e) {
    }
    finally {
      context.cunits.clear
      context.pod.closures.clear
    }
    return this
  }
  
  This run() {
    t0 := TimePoint.nowMillis
    parseAll
    t1 := TimePoint.nowMillis

    context.log.debug("parse: ${t1-t0}")

    t2 := TimePoint.nowMillis
    pipelines.each |pass| {
      pass.run
      t3 := TimePoint.nowMillis
      context.log.debug("pass ${pass.typeof}: ${t3-t2}")
      t2 = t3
    }
    return this
  }

  static Void main() {
  }
}
