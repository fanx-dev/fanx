
class CompilerContext {
  
  CompilerInput input
  
  **
  ** Namespace used to resolve dependency pods/types.
  **
  CNamespace? ns
  
  **
  ** Current pod
  ** 
  PodDef pod

  **
  ** code to compile
  **
  CompilationUnit[] cunits
  [Str:CompilationUnit] cunitsMap
  
  **
  ** Log used for reporting compile errors
  **
  CompilerLog log
  
  
  ** temp storage for locale/en.props
  Str? localeProps          // LocaleProps
  
  ** javascript target
  Obj? jsPod                // CompileJs (JavaScript AST)
  Str? js                   // CompileJs (JavaScript code)
  Str? jsSourceMap          // CompileJs (JavaScript sourcemap)
  
  **
  ** pod file to write
  **
  FPod? fpod
  
  **
  ** If `CompilerOutputMode.podFile` mode, the pod zip file written to disk.
  **
  File? podFile
  
  **
  ** If `CompilerOutputMode.transientPod` mode, this is loaded pod.
  **
  Pod? transientPod
  
  **
  ** ClosureVars wrapper types cache
  **
  Str:CField wrappers := [:]
  
  **
  ** Get default compilation unit to use for synthetic definitions
  ** such as wrapper types.
  **
  CompilationUnit syntheticsUnit() { cunits[0] }
  
  
  ** temp vars see: ResolveExpr.resolveLocaleLiteral
  LocaleLiteralExpr[] localeDefs
  
  ** ctor
  new make(PodDef pod, CompilerInput input, CNamespace ns) {
    this.pod = pod
    log = CompilerLog()
    localeDefs = LocaleLiteralExpr[,]
    cunitsMap = [:]
    cunits = [,]
    this.input = input
    this.ns = ns
  }
}
