
class BasicInit : CompilerStep {
  
  new make(CompilerContext compiler)
    : super(compiler)
  {
  }
  
  override Void run()
  {
    //debug("BasicInit")
    walkUnits(VisitDepth.slotDef)
  }

  override Void visitTypeDef(TypeDef def)
  {
    loc := def.loc
    if (def.inheritances.isEmpty) {
      def.baseSpecified = false
      if (def.isEnum)
        def.inheritances.add(CType.enumType(loc))
      else if (def.qname != "sys::Obj")
        def.inheritances.add(CType.objType(loc))
    }
    
    if (def.isFacet)
        def.inheritances.add(CType.facetType(loc))
    
//    genericParams := def.genericParameters
//    if (genericParams != null) {
//      genericParams.each |p| {
//        if (p.bound == null) p.bound = TypeRef.objType(p.loc)
//      }
//    }
    
    def.flags = normalizeFlags(def.flags, loc)
    initVirtualFlags(def)
    
    // walk thru all the slots
    def.slotDefs.dup.each |SlotDef s|
    {
      if (s is FieldDef)
      {
        f := (FieldDef)s
        normalizeFieldDef(f)
      }
    }
  }
  
  private Void normalizeFieldDef(FieldDef field) {
    field.flags = normalizeFlags(field.flags, field.loc)
    
    if ((field.isConst || field.isReadonly)) {
      if (field.get == null && field.isOverride) {
        get := Parser.defGet(field)
        curType.addSlot(get)
        genSyntheticGet(field)
      }
      return
    }
    if (field.get == null) {
      get := Parser.defGet(field)
      curType.addSlot(get)
      genSyntheticGet(field)
    }
    else if (field.get.code == null) {
      genSyntheticGet(field)
    }
    
    if (field.set == null) {
      set := Parser.defSet(field)
      curType.addSlot(set)
      genSyntheticSet(field)
    }
    else if (field.set.code == null) {
      genSyntheticSet(field)
    }
  }
  
  override Void visitMethodDef(MethodDef m) {
    m.flags = normalizeFlags(m.flags, m.loc)
    if (m.ret == null) {
      m.ret = CType.voidType(m.loc)
    }
  }
  
  private Int normalizeFlags(Int flags, Loc loc) {
    if (flags.and(FConst.Abstract) != 0 && flags.and(FConst.Virtual) != 0)
      err("Abstract implies virtual", loc)
    if (flags.and(FConst.Override) != 0 && flags.and(FConst.Virtual) != 0)
      err("Override implies virtual", loc)

    if (flags.and(FConst.Extension) != 0 && flags.and(FConst.Static) == 0) {
      err("Extension must static", loc)
    }
    
    protection := FConst.Internal.or(FConst.Private).or(FConst.Protected).or(FConst.Public)
    if (protection.and(flags) == 0) flags = flags.or(FConst.Public)
    
    
    if (flags.and(FConst.Abstract) != 0) flags = flags.or(FConst.Virtual)
    if (flags.and(FConst.Override) != 0)
    {
      if (flags.and(FConst.Final) != 0)
        flags = flags.and(FConst.Final.not)
      else
        flags = flags.or(FConst.Virtual)
    }
    return flags
  }
  
  private Void initVirtualFlags(TypeDef t) {
    if (t.flags.and(FConst.Virtual) != 0 ||
        t.flags.and(FConst.Abstract) != 0 ||
        t.flags.and(FConst.Final) != 0) return
    
    vir := t.slotDefs.any |s| {
      if (s.flags.and(FConst.Virtual) != 0 || t.flags.and(FConst.Abstract) != 0) {
        return true
      }
      return false
    }
    if (vir) t.flags = t.flags.or(FConst.Virtual)
  }
  
  
  private Void genSyntheticGet(FieldDef f)
  {
    loc := f.loc
    f.get.flags = f.get.flags.or(FConst.Synthetic)
    if (!f.isAbstract && !f.isNative)
    {
      f.flags = f.flags.or(FConst.Storage)
      f.get.code = Block(loc)
      f.get.code.add(ReturnStmt(loc, f.makeAccessorExpr(loc, false)))
    }
  }

  private Void genSyntheticSet(FieldDef f)
  {
    loc := f.loc
    f.set.flags = f.set.flags.or(FConst.Synthetic)
    if (!f.isAbstract && !f.isNative)
    {
      f.flags = f.flags.or(FConst.Storage)
      lhs := f.makeAccessorExpr(loc, false)
      rhs := UnknownVarExpr(loc, null, "it")
      f.set.code = Block(loc)
      f.set.code.add(BinaryExpr.makeAssign(lhs, rhs).toStmt)
      f.set.code.add(ReturnStmt(loc))
    }
  }

}
