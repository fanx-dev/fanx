
** Compiler manages the top level process of the compiler pipeline.
class IncCompiler {
  
  ** compiler context
  CompilerContext compiler
  
  ** compiler pipeline
  CompilerStep[] pipelines := [,]
  
  ** make from empty pod obj
  new make(PodDef pod, CompilerInput? input = null, CNamespace? ns := null) {
    if (input == null) input = CompilerInput()
    if (ns == null) ns = FPodNamespace(null)
    compiler = CompilerContext(pod, input, ns)
    
    pipelines = [
      BasicInit(compiler),
      InitDataClass(compiler),
      DefaultCtor(compiler),
      InitEnum(compiler),
      InitFacet(compiler),
      SlotNormalize(compiler),
      
      ResolveDepends(compiler),
      ResolveImports(compiler),
      ResolveType(compiler),
      
      StmtNormalize(compiler),
      CheckInheritance(compiler),
      CheckInheritSlot(compiler),
      
      ResolveExpr(compiler),
      CheckErrors(compiler),
      CheckParamDefs(compiler),
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
    files := compiler.input.srcFiles
    files.each |f| {
       this.updateSourceFile(f)
    }
    return this
  }
  
  ** parse souce code
  private CompilationUnit parseCode(Str file, Str code) {
    unit := CompilationUnit(Loc.make(file), compiler.pod, file.toStr)
    parser := DeepParser(compiler.log, code, unit)
    //echo(parser.tokens.join("\n")|t|{ t.loc.toStr + "\t\t" + t.kind + "\t\t" + t.val })
    parser.parse
    return unit
  }
  
  ** update compiler result by source file
  CompilationUnit? updateSourceFile(File file, Bool isDelete := false) {
    updateSource(file.osPath, file.readAllStr)
  }
  
  ** update compiler result by source str
  CompilationUnit? updateSource(Str file, Str code, Bool isDelete := false) {
    old := compiler.cunitsMap[file]
    if (old != null) {
      compiler.cunitsMap.remove(file)
      compiler.cunits.removeSame(old)
      compiler.log.clearByFile(file)
    }
    
    if (isDelete) {
      compiler.pod.updateCompilationUnit(null, old)
      return old
    }
    
    unit := parseCode(file, code)
    compiler.pod.updateCompilationUnit(unit, old)
    
    compiler.cunitsMap[file] = unit
    compiler.cunits.add(unit)
    return unit
  }
  
////////////////////////////////////////////////////////////////////////////////
// resolve
////////////////////////////////////////////////////////////////////////////////

  ** run pipelines, do expression resolve and type check
  This resolveAll() {
    pipelines.each |pass| { pass.run }
    return this
  }
  
  Void run() {
    parseAll
    pipelines.each |pass| { pass.run }
  }

  static Void main() {
  }
}
