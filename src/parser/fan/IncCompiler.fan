
class IncCompiler {
  
  CompilerContext compiler
  CompilerStep[] pipelines := [,]
  
  new make(PodDef pod) {
    compiler = CompilerContext(pod)
    compiler.ns = FPodNamespace(File(`../../env/lib/fan/`))
    
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
    ]
  }
  
  static IncCompiler fromProps(File file) {
    props := file.readProps
    podName := props["podName"]
    srcDirs := props["srcDirs"]
    
    loc := Loc.makeFile(file)
    pod := PodDef(loc, podName)
    
    icom := IncCompiler(pod)
    
    dirs := parseDirs(file, srcDirs)
    dirs?.each |dir| {
      fdir := (file.uri + dir).toFile
      fdir.listFiles.each |f|{
        if (f.ext == "fan") {
          icom.updateSourceFile(f)
        }
      }
    }
    return icom
  }
  
  static Uri[] allDir(Uri base, Uri dir)
  {
    Uri[] subs := [,]
    (base + dir).toFile.walk |File f|
    {
      if(f.isDir)
      {
        rel := f.uri.relTo(base)
        subs.add(rel)
      }
    }
    return subs
  }
  
  static private Uri[]? parseDirs(File scriptFile, Str? str) {
    if (str == null) return null
    srcDirs := Uri[,]
    str.split(',').each |d| {
      if (d.endsWith("*")) {
        srcUri := d[0..<-1].toUri
        dirs := allDir(scriptFile.uri, srcUri)
        srcDirs.addAll(dirs)
      }
      else {
        srcDirs.add(d.toUri)
      }
    }
    return srcDirs
  }
  
  private CompilationUnit parse(Str file, Str code) {
    unit := CompilationUnit(Loc.make(file), compiler.pod, file.toStr)
    parser := DeepParser(compiler.log, code, unit)
    parser.parse
    return unit
  }
  
  Void updateSourceFile(File file, Bool isDelete := false) {
    updateSource(file.osPath, file.readAllStr)
  }
  
  Void updateSource(Str file, Str code, Bool isDelete := false) {
    old := compiler.pod.units[file]
    if (old != null) {
      old.types.each |t| {
        compiler.pod.typeDefs.remove(t.name)
      }
    }
    
    if (!isDelete) {
      unit := parse(file, code)
      compiler.pod.units[file] = unit
      unit.types.each |t| {
        compiler.pod.typeDefs[t.name] = t
      }
    }
  }
  
  Void resolveAll() {
    pipelines.each |pass| { pass.run }
  }
}
