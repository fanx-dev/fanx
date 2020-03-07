
class IncCompiler {
  
  CompilerContext compiler
  CompilerStep[] pipelines := [,]
  Uri[]? srcDirs
  
  new make(PodDef pod) {
    compiler = CompilerContext(pod)
    compiler.ns = FPodNamespace(null)
    
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
  
  static IncCompiler fromProps(File file, CNamespace? ns := null) {
    props := file.in.readProps
    podName := props["podName"]
    srcDirs := props["srcDirs"]
    
    loc := Loc.makeFile(file)
    pod := PodDef(loc, podName)
    
    icom := IncCompiler(pod)
    if (ns != null) icom.compiler.ns = ns
    baseDir := file.uri.parent
    
    dirs := parseDirs(baseDir, srcDirs)
    icom.srcDirs = dirs
    dirs?.each |dir| {
      fdir := (baseDir + dir).toFile
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
  
  static private Uri[]? parseDirs(Uri baseDir, Str? str) {
    if (str == null) return null
    srcDirs := Uri[,]
    str.split(',').each |d| {
      if (d.endsWith("*")) {
        srcUri := d[0..<-1].toUri
        dirs := allDir(baseDir, srcUri)
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
    //echo(parser.tokens.join("\n")|t|{ t.loc.toStr + "\t\t" + t.kind + "\t\t" + t.val })
    parser.parse
    return unit
  }
  
  CompilationUnit? updateSourceFile(File file, Bool isDelete := false) {
    updateSource(file.osPath, file.readAllStr)
  }
  
  CompilationUnit? updateSource(Str file, Str code, Bool isDelete := false) {
    old := compiler.pod.units[file]
    if (old != null) {
      old.types.each |t| {
        compiler.pod.typeDefs.remove(t.name)
      }
      compiler.pod.units.remove(file)
      compiler.log.clearByFile(file)
    }
    
    if (isDelete) {
      return old
    }
    
    unit := parse(file, code)
    compiler.pod.units[file] = unit
    unit.types.each |t| {
      compiler.pod.typeDefs[t.name] = t
    }
    compiler.cunits.add(unit)
    return unit
  }
  
  Void resolveAll() {
    pipelines.each |pass| { pass.run }
    compiler.cunits.clear
  }

  static Void main() {
  }
}
