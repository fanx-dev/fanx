
class CompilerContext {
  **
  ** Namespace used to resolve dependency pods/types.
  **
  CNamespace? ns
  
  **
  ** Current pod
  ** 
  PodDef pod
  
  **
  ** Log used for reporting compile errors
  **
  CompilerLog log
  
  **
  ** Flag to indicate if we are are compiling a script.  Scripts
  ** don't require explicit depends and can import any type via the
  ** using statement or with qualified type names.
  **
  Bool isScript := true
  
  ** temp vars see: ResolveExpr.resolveLocaleLiteral
  LocaleLiteralExpr[] localeDefs
  
  new make(PodDef pod) {
    this.pod = pod
    log = CompilerLog()
    localeDefs = LocaleLiteralExpr[,]
  }
}
