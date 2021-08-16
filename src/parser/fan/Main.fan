

class Main
{

  static Void main(Str[] args) {
    File file := args[0].toUri.toFile
    compiler := IncCompiler.fromProps(file)
    ctx := compiler.compiler
    compiler.pipelines = [
        BasicInit(ctx),
        InitDataClass(ctx),
        DefaultCtor(ctx),
        InitEnum(ctx),
        InitFacet(ctx),
        
        SlotNormalize(ctx),

        ResolveDepends(ctx),
        ResolveImports(ctx),
        ResolveType(ctx),

        StmtNormalize(ctx),
        CheckInheritance(ctx),
        CheckInheritSlot(ctx),

        ResolveExpr(ctx),
        InitClosures(ctx),
        
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
    compiler.run
  }

}