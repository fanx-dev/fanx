//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Sep 05  Brian Frank  Creation
//    6 Jun 06  Brian Frank  Ported from Java to Fan
//

**
** Parser is responsible for parsing a list of tokens into the
** abstract syntax tree.  At this point the CompilationUnit, Usings,
** and TypeDefs are already populated by the ScanForUsingAndTypes
** step.
**
public class Parser : CompilerSupport
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Construct the parser for the specified compilation unit.
  **
  new make(Compiler compiler, CompilationUnit unit, ClosureExpr[] closures)
    : super(compiler)
  {
    this.unit      = unit
    this.tokens    = unit.tokens
    this.numTokens = unit.tokens.size
    this.closures  = closures
    reset(0)
  }

//////////////////////////////////////////////////////////////////////////
// Access
//////////////////////////////////////////////////////////////////////////

  **
  ** Top level parse a compilation unit:
  **
  **   <compilationUnit> :=  [<usings>] <typeDef>*
  **
  Void parse()
  {
    usings
    while (curt !== Token.eof) typeDef
  }

//////////////////////////////////////////////////////////////////////////
// Usings
//////////////////////////////////////////////////////////////////////////

  **
  ** Parse <using>* - note that we are just skipping them because
  ** they are already parsed by ScanForUsingsAndTypes.
  **
  **   <using>       :=  <usingPod> | <usingType> | <usingAs>
  **   <usingPod>    :=  "using" <podSpec> <eos>
  **   <usingType>   :=  "using" <podSpec> "::" <id> <eos>
  **   <usingAs>     :=  "using" <podSpec> "::" <id> "as" <id> <eos>
  **   <podSpec>     :=  <id> | <str> | <ffiPodSpec>
  **   <ffiPodSpec>  := "[" <id> "]" <id> ("." <id>)*
  **
  private Void usings()
  {
    while (curt == Token.usingKeyword)
      skipUsing
  }

  private Void skipUsing()
  {
    consume(Token.usingKeyword)

    // <str> | <id> | "[" <id> "]" <id> ("." <id>)*
    if (curt === Token.strLiteral) consume
    else
    {
      if (curt === Token.lbracket) { consume; consumeId; consume(Token.rbracket) }
      consumeId
      while (curt === Token.dot) { consume; consumeId }
    }

    if (curt === Token.doubleColon)
    {
      consume; consumeId
      while (curt === Token.dollar) { consume; if (curt === Token.identifier) consumeId }
      if (curt === Token.asKeyword) { consume; consumeId }
    }
    endOfStmt
  }

//////////////////////////////////////////////////////////////////////////
// TypeDef
//////////////////////////////////////////////////////////////////////////

  **
  ** TypeDef:
  **   <typeDef>      :=  <classDef> | <mixinDef> | <enumDef> | <facetDef>
  **
  **   <classDef>     :=  <classHeader> <classBody>
  **   <classHeader>  :=  [<doc>] <facets> <typeFlags> "class" [<inheritance>]
  **   <classFlags>   :=  [<protection>] ["abstract"] ["final"]
  **   <classBody>    :=  "{" <slotDefs> "}"
  **
  **   <enumDef>      :=  <enumHeader> <enumBody>
  **   <enumHeader>   :=  [<doc>] <facets> <protection> "enum" [<inheritance>]
  **   <enumBody>     :=  "{" <enumDefs> <slotDefs> "}"
  **
  **   <facetDef      :=  <facetHeader> <enumBody>
  **   <facetHeader>  :=  [<doc>] <facets> [<protection>] "facet" "class" <id> [<inheritance>]
  **   <facetBody>    :=  "{" <slotDefs> "}"
  **
  **   <mixinDef>     :=  <enumHeader> <enumBody>
  **   <mixinHeader>  :=  [<doc>] <facets> <protection> "mixin" [<inheritance>]
  **   <mixinBody>    :=  "{" <slotDefs> "}"
  **
  **   <protection>   :=  "public" | "protected" | "private" | "internal"
  **   <inheritance>  :=  ":" <typeList>
  **
  Void typeDef()
  {
    // [<doc>]
    doc := doc()
    if (curt === Token.usingKeyword) throw err("Cannot use ** doc comments before using statement")
    if (curt === Token.eof) return

    // <facets>
    facets := facets()

    // <flags>
    flags := flags(false)
    if (flags.and(ProtectionMask.not) == 0) flags = flags.or(FConst.Public)
    //if (compiler.isSys) flags = flags.or(FConst.Native)
    if (flags.and(FConst.Readonly) != 0) err("Cannot use 'readonly' modifier on type", cur)

    // local working variables
    loc     := cur
    isMixin := false
    isEnum  := false

    // mixin
    if (curt === Token.mixinKeyword)
    {
      if (flags.and(FConst.Abstract) != 0) err("The 'abstract' modifier is implied on mixin", loc)
      if (flags.and(FConst.Final) != 0) err("Cannot use 'final' modifier on mixin", loc)
      flags = flags.or(FConst.Mixin + FConst.Abstract)
      isMixin = true
      consume
    }

    // class
    else
    {
      //data class
      if (curt === Token.identifier && cur.val == "data") {
        flags = flags.or(Parser.Data)
        consume
      }
      // enum class
      if (curt === Token.identifier && cur.val == "enum")
      {
        if (flags.and(FConst.Const) != 0) err("The 'const' modifier is implied on enum", loc)
        if (flags.and(FConst.Final) != 0) err("The 'final' modifier is implied on enum", loc)
        if (flags.and(FConst.Abstract) != 0) err("Cannot use 'abstract' modifier on enum", loc)
        flags = flags.or(FConst.Enum + FConst.Const + FConst.Final)
        isEnum = true
        consume
      }
      // facet class
      if (curt === Token.identifier && cur.val == "facet")
      {
        if (flags.and(FConst.Const) != 0) err("The 'const' modifier is implied on facet", loc)
        if (flags.and(FConst.Final) != 0) err("The 'final' modifier is implied on facet", loc)
        if (flags.and(FConst.Abstract) != 0) err("Cannot use 'abstract' modifier on facet", loc)
        flags = flags.or(FConst.Facet + FConst.Const + FConst.Final)
        consume
      }
      // struct class
      if (curt == Token.identifier && cur.val == "struct") {
        //if (flags.and(FConst.Const) == 0) err("The struct class must 'const'", loc)
        if (flags.and(FConst.Final) != 0) err("The 'final' modifier is implied on struct", loc)
        if (flags.and(FConst.Abstract) != 0) err("Cannot use 'abstract' modifier on struct", loc)
        flags = flags.or(FConst.Struct + FConst.Final)
        consume
      }
      consume(Token.classKeyword)
    }

    // name
    name := consumeId
    // lookup TypeDef
    def := unit.types.find |TypeDef def->Bool| { def.name == name }
    if (def == null) throw err("Invalid class definition", cur)

    // populate it's doc, facets, and flags
    def.doc    = doc
    def.facets = facets
    def.flags  = flags
    if (def.isFacet) def.mixins.add(ns.facetType)

    //GenericType Param
    if (curt === Token.lt) {
      consume
      gparams := GenericParameter[,]
      while (true) {
        paramName := consumeId
        conflict := unit.importedTypes[paramName]
        if (conflict != null) {
          throw err("generic type conflict: $conflict", cur)
        }
        param := GenericParameter(ns, paramName, def, gparams.size)
        gparams.add(param)
        if (curt === Token.comma) {
          consume
          continue
        }
        else if (curt === Token.gt) {
          consume
          break
        }
        else {
          err("Error token: $curt")
        }
      }
      def.genericParameters = gparams
    }

    // open current type
    curType = def
    closureCount = 0

    // inheritance
    if (curt === Token.colon)
    {
      // first inheritance type can be extends or mixin
      consume
      first := inheritType
      if (!first.isMixin)
        def.base = first
      else
        def.mixins.add(first)

      // additional mixins
      while (curt === Token.comma)
      {
        consume
        def.mixins.add(inheritType)
      }
    }

    // if no inheritance specified then apply default base class
    if (def.base == null)
    {
      def.baseSpecified = false
      if (isEnum)
        def.base = ns.enumType
      else if (def.qname != "sys::Obj")
        def.base = ns.objType
    }

    // start class body
    consume(Token.lbrace)

    // if enum, parse values
    if (isEnum) enumDefs(def)

    // slots
    while (true)
    {
      doc = this.doc
      if (curt === Token.rbrace) break
      slot := slotDef(def, doc)

      // do duplicate name error checking here
      if (def.hasSlotDef(slot.name))
      {
        err("Duplicate slot name '$slot.name'", slot.loc)
      }
      else
      {
        def.addSlot(slot)
      }
    }

    // close cur type
    closureCount = null
    curType = null

    // end of class body
    consume(Token.rbrace)
  }

  private CType inheritType()
  {
    Loc loc := cur
    t := TypeRef(loc, simpleType(false))
    if (t == ns.facetType) err("Cannot inherit 'Facet' explicitly", t.loc)
    if (t == ns.enumType)  err("Cannot inherit 'Enum' explicitly", t.loc)
    return t
  }

//////////////////////////////////////////////////////////////////////////
// Flags
//////////////////////////////////////////////////////////////////////////

  **
  ** Parse any list of flags in any order, we will check invalid
  ** combinations in the CheckErrors step.
  **
  private Int flags(Bool normalize := true)
  {
    loc := cur
    flags := 0
    protection := false
    for (done := false; !done; )
    {
      oldFlags := flags
      switch (curt)
      {
        case Token.abstractKeyword:  flags = flags.or(FConst.Abstract)
        case Token.constKeyword:     flags = flags.or(FConst.Const)
        case Token.readonlyKeyword:  flags = flags.or(FConst.Readonly)
        case Token.finalKeyword:     flags = flags.or(FConst.Final)
        case Token.internalKeyword:  flags = flags.or(FConst.Internal);  protection = true
        case Token.nativeKeyword:    flags = flags.or(FConst.Native)
        case Token.onceKeyword:      flags = flags.or(Once) // Parser only flag
        case Token.extensionKeyword: flags = flags.or(FConst.Extension)
        case Token.overrideKeyword:  flags = flags.or(FConst.Override)
        case Token.privateKeyword:   flags = flags.or(FConst.Private);   protection = true
        case Token.protectedKeyword: flags = flags.or(FConst.Protected); protection = true
        case Token.publicKeyword:    flags = flags.or(FConst.Public);    protection = true
        case Token.staticKeyword:    flags = flags.or(FConst.Static)
        case Token.virtualKeyword:   flags = flags.or(FConst.Virtual)
        case Token.rtconstKeyword:   flags = flags.or(FConst.RuntimeConst)
        case Token.asyncKeyword:     flags = flags.or(FConst.Async)
        default:                     done = true
      }
      if (done) break
      if (oldFlags == flags) err("Repeated modifier")
      oldFlags = flags
      consume
    }

    if (flags.and(FConst.Abstract) != 0 && flags.and(FConst.Virtual) != 0)
      err("Abstract implies virtual", loc)
    if (flags.and(FConst.Override) != 0 && flags.and(FConst.Virtual) != 0)
      err("Override implies virtual", loc)

    if (flags.and(FConst.Extension) != 0 && flags.and(FConst.Static) == 0) {
      err("Extension must static", loc)
    }

    if (normalize)
    {
      if (!protection) flags = flags.or(FConst.Public)
      if (flags.and(FConst.Abstract) != 0) flags = flags.or(FConst.Virtual)
      if (flags.and(FConst.Override) != 0)
      {
        if (flags.and(FConst.Final) != 0)
          flags = flags.and(FConst.Final.not)
        else
          flags = flags.or(FConst.Virtual)
      }
    }

    return flags
  }

//////////////////////////////////////////////////////////////////////////
// Enum
//////////////////////////////////////////////////////////////////////////

  **
  ** Enum definition list:
  **   <enumDefs>  :=  <enumDef> ("," <enumDef>)* <eos>
  **
  private Void enumDefs(TypeDef def)
  {
    // create static$init to wrap enums in case
    // they have closures
    sInit := MethodDef.makeStaticInit(def.loc, def, null)
    sInit.code = Block(def.loc)
    def.addSlot(sInit)
    curSlot = sInit

    // parse each enum def
    ordinal := 0
    def.enumDefs.add(enumDef(ordinal++))
    while (curt === Token.comma)
    {
      consume
      enumDef := enumDef(ordinal++)
      if (def.enumDefs.any |EnumDef e->Bool| { e.name == enumDef.name })
        err("Duplicate enum name '$enumDef.name'", enumDef.loc)
      def.enumDefs.add(enumDef)
    }
    endOfStmt

    // clear static$init scope
    curSlot = null
  }

  **
  ** Enum definition:
  **   <enumDef>  :=  <facets> <id> ["(" <args> ")"]
  **
  private EnumDef enumDef(Int ordinal)
  {
    doc := doc()
    facets := facets()

    def := EnumDef(cur, doc, facets, consumeId, ordinal)

    // optional ctor args
    if (curt === Token.lparen)
    {
      consume(Token.lparen)
      if (curt != Token.rparen)
      {
        while (true)
        {
          def.ctorArgs.add( expr )
          if (curt === Token.rparen) break
          consume(Token.comma);
        }
      }
      consume(Token.rparen)
    }

    return def
  }

//////////////////////////////////////////////////////////////////////////
// Slots
//////////////////////////////////////////////////////////////////////////

  **
  ** Slot definition:
  **   <slotDef> :=  <fieldDef> | <methodDef> | <ctorDef>
  **
  private SlotDef slotDef(TypeDef parent, DocDef? doc)
  {
    // check for static {} class initialization
    if (curt === Token.staticKeyword && peekt === Token.lbrace)
    {
      loc := cur
      consume
      sInit := MethodDef.makeStaticInit(loc, parent, null)
      curSlot = sInit
      sInit.code = block
      curSlot = null
      return sInit
    }

    // all members start with facets, flags
    loc := cur
    facets := facets()
    flags := flags()

    // check if this is a Java style constructor, log error and parse like Fantom sytle ctor
    if (curt === Token.identifier && cur.val == parent.name && peekt == Token.lparen)
    {
      err("Invalid constructor syntax - use new keyword")
      return methodDef(loc, parent, doc, facets, flags.or(FConst.Ctor), TypeRef(loc, ns.voidType), consumeId)
    }

    // check for inferred typed field
    // if = used rather than := then fieldDef() will log error
    if (curt === Token.identifier && (peekt === Token.defAssign || peekt === Token.assign))
    {
      name := consumeId
      return fieldDef(loc, parent, doc, facets, flags, null, name)
    }

    // check for constructor
    if (curt === Token.newKeyword)
    {
      consume
      flags = flags.or(FConst.Ctor)
      name := consumeId
      /*
      returns := flags.and(FConst.Static) == 0 ?
                 TypeRef(loc, ns.voidType) :
                 TypeRef(loc, parent) //remove 'toNullable' sine we don't want boxing for struct type
      */
      returns := ns.voidType
      if (flags.and(FConst.Static) != 0) {
        if (parent.isGeneric) {
          TypeDef gp := parent.deref
          params := gp.genericParameters
          returns = ParameterizedType.create(parent, params)
        }
        else returns = parent
      }
      returnsRef := TypeRef(loc, returns)
      return methodDef(loc, parent, doc, facets, flags, returnsRef, name)
    }

    //modern field
    if (curt === Token.varKeyword || curt === Token.letKeyword || tokens[pos-1].kind === Token.constKeyword) {
      modernStyle := false
      if (curt === Token.varKeyword) {
        consume
        modernStyle = true
        if (flags.and(FConst.Const) != 0) {
          err("var must not const", loc)
        }
      }
      if (curt === Token.letKeyword) {
        consume
        flags = flags.or(FConst.Readonly)
        modernStyle = true
      }

      if (curt === Token.identifier && peekt === Token.colon) {
        name := consumeId
        consume(Token.colon)
        type := typeRef
        return fieldDef(loc, parent, doc, facets, flags, type, name)
      }
      if (modernStyle) {
        err("expected colon for field def", loc)
      }
    }

    //modern function
    if (curt === Token.funKeyword) {
      consume
      CType? type := null
      name := consumeId
      return methodDef(loc, parent, doc, facets, flags, type, name)
    }

    // otherwise must be field or method
    type := typeRef
    name := consumeId
    if (curt === Token.lparen)
    {
      return methodDef(loc, parent, doc, facets, flags, type, name)
    }
    else
    {
      return fieldDef(loc, parent, doc, facets, flags, type, name)
    }
  }

//////////////////////////////////////////////////////////////////////////
// FieldDef
//////////////////////////////////////////////////////////////////////////

  **
  ** Field definition:
  **   <fieldDef>     :=  <facets> <fieldFlags> [<type>] <id> [":=" <expr>]
  **                      [ "{" [<fieldGetter>] [<fieldSetter>] "}" ] <eos>
  **   <fieldFlags>   :=  [<protection>] ["readonly"] ["static"]
  **   <fieldGetter>  :=  "get" (<eos> | <block>)
  **   <fieldSetter>  :=  <protection> "set" (<eos> | <block>)
  **
  private FieldDef fieldDef(Loc loc, TypeDef parent, DocDef? doc, FacetDef[]? facets, Int flags, TypeRef? type, Str name)
  {
    // define field itself
    field := FieldDef(loc, parent)
    field.doc    = doc
    field.facets = facets
    field.flags  = flags.and(ParserFlagsMask.not)
    field.name   = name
    if (type != null) field.fieldType = type

    // const always has storage, otherwise assume no storage
    // until proved otherwise in ResolveExpr step or we
    // auto-generate getters/setters
    if (field.isConst || field.isReadonly)
      field.flags = field.flags.or(FConst.Storage)

    // field initializer
    if (curt === Token.defAssign || curt === Token.assign)
    {
      //if (curt === Token.assign) err("Must use := for field initialization")
      consume
      curSlot = field
      inFieldInit = true
      field.init = expr
      inFieldInit = false
      curSlot = null
    }

    // disable type inference for now - doing inference for literals is
    // pretty trivial, but other types is tricky;  I'm not sure it is such
    // a hot idea anyways so it may just stay disabled forever
    if (type == null)
      err("Type inference not supported for fields", loc)

    // if not const, define getter/setter methods
    if (!field.isConst && !field.isReadonly) defGetAndSet(field)

    // explicit getter or setter
    if (curt === Token.lbrace)
    {
      consume(Token.lbrace)
      getOrSet(field)
      getOrSet(field)
      consume(Token.rbrace)
    }

    // generate synthetic getter or setter code if necessary
    if (!field.isConst && !field.isReadonly)
    {
      if (field.get.code == null) genSyntheticGet(field)
      if (field.set.code == null) genSyntheticSet(field)
    }

    // const override has getter only
    if ((field.isConst || field.isReadonly) && field.isOverride)
    {
      defGet(field)
      genSyntheticGet(field)
    }

    endOfStmt
    return field
  }

  private Void defGetAndSet(FieldDef f)
  {
    defGet(f)
    defSet(f)
  }

  private Void defGet(FieldDef f)
  {
    // getter MethodDef
    loc := f.loc
    get := MethodDef(loc, f.parentDef)
    get.accessorFor = f
    get.flags = f.flags.or(FConst.Getter)
    get.name  = f.name
    get.ret   = f.fieldType
    f.get = get
  }

  private Void defSet(FieldDef f)
  {
    // setter MethodDef
    loc := f.loc
    set := MethodDef(loc, f.parentDef)
    set.accessorFor = f
    set.flags = f.flags.or(FConst.Setter)
    set.name  = f.name
    set.ret   = ns.voidType
    set.params.add(ParamDef(loc, f.fieldType, "it"))
    f.set = set
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

  private Void getOrSet(FieldDef f)
  {
    loc := cur
    accessorFlags := flags(false)
    if (curt === Token.identifier)
    {
      // get or set
      idLoc := cur
      id := consumeId

      if (id == "get")
        curSlot = f.get
      else
        curSlot = f.set

      // { ...block... }
      Block? block := null
      if (curt === Token.lbrace)
        block = this.block
      else
        endOfStmt

      // const field cannot have getter/setter
      if (f.isConst || f.isReadonly)
      {
        err("Const field '$f.name' cannot have ${id}ter", idLoc)
        return
      }

      // map to get or set on FieldDef
      if (id == "get")
      {
        if (accessorFlags != 0) err("Cannot use modifiers on field getter", loc)
        f.get.code  = block
      }
      else if (id.equals("set"))
      {
        if (accessorFlags != 0)
        {
          if (accessorFlags.and(ProtectionMask) != 0)
            err("Cannot use modifiers on field setter except to narrow protection", loc)
          f.set.flags = f.set.flags.and(ProtectionMask).or(accessorFlags)
        }
        f.set.code = block
      }
      else
      {
        err("Expected 'get' or 'set', not '$id'", idLoc)
      }
    }
  }

//////////////////////////////////////////////////////////////////////////
// MethodDef
//////////////////////////////////////////////////////////////////////////

  **
  ** Method definition:
  **   <methodDef>      :=  <facets> <methodFlags> <type> <id> "(" <params> ")" <methodBody>
  **   <methodFlags>    :=  [<protection>] ["virtual"] ["override"] ["abstract"] ["static"]
  **   <params>         :=  [<param> ("," <param>)*]
  **   <param>          :=  <type> <id> [":=" <expr>]
  **   <methodBody>     :=  <eos> | ( "{" <stmts> "}" )
  **
  private MethodDef methodDef(Loc loc, TypeDef parent, DocDef? doc, FacetDef[]? facets, Int flags, TypeRef? ret, Str name)
  {
    method := MethodDef(loc, parent)
    method.doc    = doc
    method.facets = facets
    method.flags  = flags
    if (ret != null) method.ret    = ret
    method.name   = name

    // enter scope
    curSlot = method

    // parameters
    consume(Token.lparen)
    if (curt !== Token.rparen)
    {
      while (true)
      {
        newParam := paramDef
        if (method.params.any |ParamDef p->Bool| { p.name == newParam.name })
          err("Duplicate parameter name '$newParam.name'", newParam.loc)
        method.params.add(newParam)
        if (curt === Token.rparen) break
        consume(Token.comma)
      }
    }
    consume(Token.rparen)

    //retType decl
    if (ret == null) {
      if((flags.and(FConst.Ctor) == 0) && (curt === Token.colon)) {
        consume
        ret = typeRef
        method.ret = ret
      }
      else {
        ret = TypeRef(loc, ns.voidType)
        method.ret = ret
      }
    }

    // if This is returned, then we configure inheritedRet
    // right off the bat (this is actual signature we will use)
    if (ret.isThis) method.inheritedRet = parent

    // if no body expected
    //if (parent.isNative) flags = flags.or(FConst.Native)
    if (flags.and(FConst.Abstract) != 0 || flags.and(FConst.Native) != 0)
    {
      if (curt === Token.lbrace)
      {
        err("Abstract or native methods cannot have method body")
        block  // keep parsing
      }
      else
      {
        endOfStmt
      }
      return method
    }

    // ctor chain
    if ((flags.and(FConst.Ctor) != 0) && (curt === Token.colon))
      method.ctorChain = ctorChain(method);

    // body
    if (curt != Token.lbrace) {
      if (!parent.isNative) err("Expecting method body")
    }
    else
      method.code = block

    // exit scope
    curSlot = null

    return method
  }

  private ParamDef paramDef()
  {
    ParamDef? param
    hasColon := false
    if (peekt === Token.colon) {
      name := consumeId
      consume(Token.colon)
      type := typeRef
      param = ParamDef(cur, type, name)
      hasColon = true
    }
    else
      param = ParamDef(cur, typeRef, consumeId)
    if (curt === Token.defAssign || curt === Token.assign)
    {
      if (hasColon && curt === Token.defAssign) err("Must use = for parameter default");
      //if (curt === Token.assign) err("Must use := for parameter default");
      consume
      param.def = expr
    }
    return param
  }

  private CallExpr ctorChain(MethodDef method)
  {
    consume(Token.colon)
    loc := cur

    call := CallExpr(loc)
    call.isCtorChain = true
    switch (curt)
    {
      case Token.superKeyword: consume; call.target = SuperExpr(loc)
      case Token.thisKeyword:  consume; call.target = ThisExpr(loc)
      default: throw err("Expecting this or super for constructor chaining", loc);
    }

    // we can omit name if super
    if (call.target.id === ExprId.superExpr && curt != Token.dot)
    {
      call.name = method.name
    }
    else
    {
      consume(Token.dot)
      call.name = consumeId
    }

    // TODO: omit args if pass thru?
    callArgs(call, false)
    return call
  }

//////////////////////////////////////////////////////////////////////////
// Facets
//////////////////////////////////////////////////////////////////////////

  **
  ** Facet definition:
  **   <facets>     := <facet>*
  **   <facet>      := "@" <simpleType> [<facetVals>]
  **   <facetVals>  := "{" <facetVal> (<eos> <facetVal>)* "}"
  **   <facetVal>   := <id> "=" <expr>
  **
  private FacetDef[]? facets()
  {
    if (curt !== Token.at) return null
    facets := FacetDef[,]
    while (curt === Token.at)
    {
      loc := cur
      consume
      if (curt !== Token.identifier) throw err("Expecting identifier")
      type := ctype
      f := FacetDef(loc, type)
      if (curt === Token.lbrace)
      {
        consume(Token.lbrace)
        while (curt === Token.identifier)
        {
          f.names.add(consumeId)
          consume(Token.assign)
          f.vals.add(expr)
          endOfStmt
        }
        consume(Token.rbrace)
      }
      facets.add(f)
    }
    return facets
  }

//////////////////////////////////////////////////////////////////////////
// Block
//////////////////////////////////////////////////////////////////////////

  **
  ** Top level for blocks which must be surrounded by braces
  **
  private Block block()
  {
    verify(Token.lbrace)
    return stmtOrBlock
  }

  **
  ** <block>  :=  <stmt> | ( "{" <stmts> "}" )
  ** <stmts>  :=  <stmt>*
  **
  private Block stmtOrBlock()
  {
    block := Block(cur)

    if (curt !== Token.lbrace)
    {
      block.stmts.add( stmt )
    }
    else
    {
      consume(Token.lbrace)
      while (curt != Token.rbrace)
        block.stmts.add( stmt )
      consume(Token.rbrace)
    }

    return block
  }

//////////////////////////////////////////////////////////////////////////
// Statements
//////////////////////////////////////////////////////////////////////////

  **
  ** Statement:
  **   <stmt>  :=  <break> | <continue> | <for> | <if> | <return> | <switch> |
  **               <throw> | <while> | <try> | <exprStmt> | <localDef> | <itAdd>
  **
  private Stmt stmt()
  {
    // check for statement keywords
    switch (curt)
    {
      case Token.breakKeyword:    return breakStmt
      case Token.continueKeyword: return continueStmt
      case Token.forKeyword:      return forStmt
      case Token.ifKeyword:       return ifStmt
      case Token.returnKeyword:   return returnStmt
      case Token.lretKeyword:     return returnStmt
      case Token.switchKeyword:   return switchStmt
      case Token.throwKeyword:    return throwStmt
      case Token.tryKeyword:      return tryStmt
      case Token.whileKeyword:    return whileStmt
    }

    // at this point we either have an expr or local var declaration
    return exprOrLocalDefStmt(true)
  }

  **
  ** Expression or local variable declaration:
  **   <exprStmt>  :=  <expr> <eos>
  **   <localDef>  :=  [<type>] <id> [":=" <expr>] <eos>
  **   <itAdd>     :=  <expr> ("," <expr>)*
  **
  private Stmt exprOrLocalDefStmt(Bool isEndOfStmt)
  {
    // see if this statement begins with a type literal
    loc := cur
    mark := pos
    localType := tryType

    // type followed by identifier must be local variable declaration
    if (localType != null)
    {
      if (curt === Token.identifier) return localDefStmt(loc, localType, isEndOfStmt)
      if (curt === Token.defAssign) throw err("Expected local variable identifier")
    }
    reset(mark)

    //type back local variable declaration
    if (curt === Token.identifier && peekt === Token.colon) {
      return localDefStmt(loc, null, isEndOfStmt)
    }

    // identifier followed by def assign is inferred typed local var declaration
    if (curt === Token.identifier && peekt === Token.defAssign)
    {
      return localDefStmt(loc, null, isEndOfStmt)
    }

    // if current is an identifer, save for special error handling
    Str? id := (curt === Token.identifier) ? (Str)cur.val : null

    // otherwise assume it's a stand alone expression statement
    e := expr()

    // if expression statement ends with comma then this
    // is syntax sugar for it.add(expr) ...
    if (curt === Token.comma) e = itAdd(e)

    // return expression as statement
    stmt := ExprStmt(e)
    if (!isEndOfStmt) return stmt
    if (endOfStmt(null)) return stmt

    // report error
    if (id != null && curt === Token.identifier && (peekt === Token.defAssign || peekt === Token.assign))
      throw err("Unknown type '$id' for local declaration", loc)
    else if (id == null && curt === Token.defAssign)
      throw err("Left hand side of ':=' must be identifier", loc)
    else
      throw err("Expected expression statement", loc)
  }

  **
  ** Comma operator is sugar for it.add(target):
  **   <itAdd>  :=  <expr> ("," <expr>)* <eos>
  **
  private Expr itAdd(Expr e)
  {
    e = CallExpr(e.loc, ItExpr(cur), "add") { args.add(e); isItAdd = true }
    while (true)
    {
      consume(Token.comma)
      if (curt === Token.rbrace || curt === Token.semicolon) break
      e = CallExpr(cur, e, "add") { args.add(expr()) }
      if (curt === Token.rbrace || curt === Token.semicolon) break
    }
    return e
  }

  **
  ** Parse local variable declaration, the current token must be
  ** the identifier of the local variable.
  **
  private LocalDefStmt localDefStmt(Loc loc, CType? localType, Bool isEndOfStmt)
  {
    // verify name doesn't conflict with an import type
    name := consumeId
    conflict := unit.importedTypes[name]
    if (conflict != null && conflict.size > 0)
      err("Variable name conflicts with imported type '$conflict.first'", loc)

    hasColon := false
    if (localType == null && curt === Token.colon) {
      consume
      localType = typeRef
      hasColon = true
    }

    stmt := LocalDefStmt(loc, localType, name)

    if (curt === Token.defAssign || curt === Token.assign)
    {
      if (hasColon && curt === Token.defAssign) err("Must use = for assignments")
      //if (curt === Token.assign) err("Must use := for declaration assignments")
      consume
      stmt.init = expr
    }

    if (isEndOfStmt) endOfStmt
    return stmt
  }

  **
  ** If/else statement:
  **   <if>  :=  "if" "(" <expr> ")" <block> [ "else" <block> ]
  **
  private IfStmt ifStmt()
  {
    loc := cur
    consume(Token.ifKeyword)
    consume(Token.lparen)
    cond := expr
    consume(Token.rparen)
    trueBlock := stmtOrBlock
    stmt := IfStmt(loc, cond, trueBlock)
    if (curt === Token.elseKeyword)
    {
      consume(Token.elseKeyword)
      stmt.falseBlock = stmtOrBlock
    }
    return stmt
  }

  **
  ** Return statement:
  **   <return>  :=  "return" [<expr>] <eos>
  **
  private ReturnStmt returnStmt()
  {
    stmt := ReturnStmt(cur)
    if (curt === Token.lretKeyword) {
      if (curClosure == null) {
        throw err("Can't use the 'lret' in non-closure")
      }
      consume(Token.lretKeyword)
      stmt.isLocal = true
    }
    else {
      consume(Token.returnKeyword)
    }

    if (!endOfStmt(null))
    {
      stmt.expr = expr
      endOfStmt
    }
    return stmt
  }

  **
  ** Throw statement:
  **   <throw>  :=  "throw" <expr> <eos>
  **
  private ThrowStmt throwStmt()
  {
    loc := cur
    consume(Token.throwKeyword)
    stmt := ThrowStmt(loc, expr)
    endOfStmt
    return stmt
  }

  **
  ** While statement:
  **   <while>  :=  "while" "(" <expr> ")" <block>
  **
  private WhileStmt whileStmt()
  {
    loc := cur
    consume(Token.whileKeyword)
    consume(Token.lparen)
    cond := expr
    consume(Token.rparen)
    return WhileStmt(loc, cond, stmtOrBlock)
  }

  **
  ** For statement:
  **   <for>      :=  "for" "(" [<forInit>] ";" <expr> ";" <expr> ")" <block>
  **   <forInit>  :=  <expr> | <localDef>
  **
  private ForStmt forStmt()
  {
    stmt := ForStmt(cur)
    consume(Token.forKeyword)
    consume(Token.lparen)

    if (curt !== Token.semicolon) stmt.init = exprOrLocalDefStmt(false)
    consume(Token.semicolon)

    if (curt != Token.semicolon) stmt.condition = expr
    consume(Token.semicolon)

    if (curt != Token.rparen) stmt.update = expr
    consume(Token.rparen)

    stmt.block = stmtOrBlock

    return stmt
  }

  **
  ** Break statement:
  **   <break>  :=  "break" <eos>
  **
  private BreakStmt breakStmt()
  {
    stmt := BreakStmt(cur)
    consume(Token.breakKeyword)
    endOfStmt
    return stmt
  }

  **
  ** Continue statement:
  **   <continue>  :=  "continue" <eos>
  **
  private ContinueStmt continueStmt()
  {
    stmt := ContinueStmt(cur)
    consume(Token.continueKeyword)
    endOfStmt
    return stmt
  }

  **
  ** Try-catch-finally statement:
  **   <try>       :=  "try" "{" <stmt>* "}" <catch>* [<finally>]
  **   <catch>     :=  "catch" [<catchDef>] "{" <stmt>* "}"
  **   <catchDef>  :=  "(" <type> <id> ")"
  **   <finally>   :=  "finally" "{" <stmt>* "}"
  **
  private TryStmt tryStmt()
  {
    stmt := TryStmt(cur)
    consume(Token.tryKeyword)
    stmt.block = stmtOrBlock
    if (curt !== Token.catchKeyword && curt !== Token.finallyKeyword)
      throw err("Expecting catch or finally block")
    while (curt === Token.catchKeyword)
    {
      stmt.catches.add(tryCatch)
    }
    if (curt === Token.finallyKeyword)
    {
      consume
      stmt.finallyBlock = stmtOrBlock
    }
    return stmt
  }

  private Catch tryCatch()
  {
    c := Catch(cur)
    consume(Token.catchKeyword)

    if (curt === Token.lparen)
    {
      consume(Token.lparen)
      c.errType = typeRef
      c.errVariable = consumeId
      consume(Token.rparen)
    }

    c.block = stmtOrBlock

    // insert implicit local variable declaration
    if (c.errVariable != null)
      c.block.stmts.insert(0, LocalDefStmt.makeCatchVar(c))

    return c
  }

  **
  ** Switch statement:
  **   <switch>   :=  "switch" "(" <expr> ")" "{" <case>* [<default>] "}"
  **   <case>     :=  "case" <expr> ":" <stmts>
  **   <default>  :=  "default" ":" <stmts>
  **
  private SwitchStmt switchStmt()
  {
    loc := cur
    consume(Token.switchKeyword)
    consume(Token.lparen)
    stmt := SwitchStmt(loc, expr)
    consume(Token.rparen)
    consume(Token.lbrace)
    while (curt != Token.rbrace)
    {
      if (curt === Token.caseKeyword)
      {
        c := Case(cur)
        while (curt === Token.caseKeyword)
        {
          consume
          c.cases.add(expr)
          consume(Token.colon)
        }
        if (curt !== Token.defaultKeyword) // optimize away case fall-thru to default
        {
          c.block = switchBlock
          stmt.cases.add(c)
        }
      }
      else if (curt === Token.defaultKeyword)
      {
        if (stmt.defaultBlock != null) err("Duplicate default blocks")
        consume
        consume(Token.colon)
        stmt.defaultBlock = switchBlock
      }
      else
      {
        throw err("Expected case or default statement")
      }
    }
    consume(Token.rbrace)
    endOfStmt
    return stmt
  }

  private Block switchBlock()
  {
    block := Block(cur)
    while (curt !== Token.caseKeyword && curt != Token.defaultKeyword && curt !== Token.rbrace)
      block.stmts.add(stmt)
    return block
  }

//////////////////////////////////////////////////////////////////////////
// Expr
//////////////////////////////////////////////////////////////////////////

  **
  ** Expression:
  **   <expr>  :=  <assignExpr>
  **
  private Expr expr()
  {
    return assignExpr
  }

  **
  ** Assignment expression:
  **   <assignExpr>     :=  <ifExpr> [<assignOp> <assignExpr>]
  **   <assignOp>       :=  "=" | "*=" | "/=" | "%=" | "+=" | "-="
  **
  private Expr assignExpr(Expr? expr := null)
  {
    // this is tree if built to the right (others to the left)
    if (expr == null) expr = ifExpr
    if (curt.isAssign)
    {
      if (curt === Token.assign)
        return BinaryExpr(expr, consume.kind, assignExpr)
      else
        return ShortcutExpr.makeBinary(expr, consume.kind, assignExpr)
    }
    return expr
  }

  **
  ** Ternary/Elvis expressions:
  **   <ifExpr>       :=  <ternaryExpr> | <elvisExpr>
  **   <ternaryExpr>  :=  <condOrExpr> ["?" <ifExprBody> ":" <ifExprBody>]
  **   <elvisExpr>    :=  <condOrExpr> "?:" <ifExprBody>
  **
  private Expr ifExpr()
  {
    expr := condOrExpr
    if (curt === Token.question)
    {
      condition := expr
      consume(Token.question)
      trueExpr := ifExprBody
      // nice error checking for Foo? x :=
      if (curt === Token.defAssign && expr.id === ExprId.unknownVar && trueExpr.id === ExprId.unknownVar)
        throw err("Unknown type '$expr' for local declaration", expr.loc)
      consume(Token.colon)
      falseExpr := ifExprBody
      expr = TernaryExpr(condition, trueExpr, falseExpr)
    }
    else if (curt === Token.elvis)
    {
      lhs := expr
      consume
      rhs := ifExprBody
      expr = BinaryExpr(lhs, Token.elvis, rhs)
    }
    return expr
  }

  **
  ** If expression body (ternary/elvis):
  **   <ifExprBody>   :=  <condOrExpr> | <ifExprThrow>
  **   <ifExprThrow>  :=  "throw" <expr>
  **
  private Expr ifExprBody()
  {
    if (curt === Token.throwKeyword)
    {
      loc := cur
      consume(Token.throwKeyword)
      return ThrowExpr(loc, expr)
    }
    else
    {
      return condOrExpr
    }
  }

  **
  ** Conditional or expression:
  **   <condOrExpr>  :=  <condAndExpr>  ("||" <condAndExpr>)*
  **
  private Expr condOrExpr()
  {
    expr := condAndExpr
    if (curt === Token.doublePipe)
    {
      cond := CondExpr(expr, cur.kind)
      while (curt === Token.doublePipe)
      {
        consume
        cond.operands.add(condAndExpr)
      }
      expr = cond
    }
    return expr
  }

  **
  ** Conditional and expression:
  **   <condAndExpr>  :=  <equalityExpr> ("&&" <equalityExpr>)*
  **
  private Expr condAndExpr()
  {
    expr := equalityExpr
    if (curt === Token.doubleAmp)
    {
      cond := CondExpr(expr, cur.kind)
      while (curt === Token.doubleAmp)
      {
        consume
        cond.operands.add(equalityExpr)
      }
      expr = cond
    }
    return expr
  }

  **
  ** Equality expression:
  **   <equalityExpr>  :=  <relationalExpr> [("==" | "!=" | "===" | "!==") <relationalExpr>]
  **
  private Expr equalityExpr()
  {
    expr := relationalExpr
    if (curt === Token.eq   || curt === Token.notEq ||
        curt === Token.same || curt === Token.notSame)
    {
      lhs := expr
      tok := consume.kind
      rhs := relationalExpr

      // optimize for null literal
      if (lhs.id === ExprId.nullLiteral || rhs.id === ExprId.nullLiteral)
      {
        id := (tok === Token.eq || tok === Token.same) ? ExprId.cmpNull : ExprId.cmpNotNull
        operand := (lhs.id === ExprId.nullLiteral) ? rhs : lhs
        expr = UnaryExpr(lhs.loc, id, tok, operand)
      }
      else
      {
        if (tok === Token.same || tok === Token.notSame)
          expr = BinaryExpr(lhs, tok, rhs)
        else
          expr = ShortcutExpr.makeBinary(lhs, tok, rhs)
      }
    }
    return expr
  }

  **
  ** Relational expression:
  **   <relationalExpr> :=  <typeCheckExpr> | <compareExpr>
  **   <typeCheckExpr>  :=  <rangeExpr> [("is" | "as" | "isnot") <type>]
  **   <compareExpr>    :=  <rangeExpr> [("<" | "<=" | ">" | ">=" | "<=>") <rangeExpr>]
  **
  private Expr relationalExpr()
  {
    expr := rangeExpr
    if (curt === Token.isKeyword || curt === Token.isnotKeyword ||
        curt === Token.asKeyword ||
        curt === Token.lt || curt === Token.ltEq ||
        curt === Token.gt || curt === Token.gtEq ||
        curt === Token.cmp)
    {
      switch (curt)
      {
        case Token.isKeyword:
          consume
          expr = TypeCheckExpr(expr.loc, ExprId.isExpr, expr, ctype)
        case Token.isnotKeyword:
          consume
          expr = TypeCheckExpr(expr.loc, ExprId.isnotExpr, expr, ctype)
        case Token.asKeyword:
          consume
          expr = TypeCheckExpr(expr.loc, ExprId.asExpr, expr, ctype)
        default:
          expr = ShortcutExpr.makeBinary(expr, consume.kind, rangeExpr)
      }
    }
    return expr
  }

  **
  ** Range expression:
  **   <rangeExpr>  :=  <bitOrExpr> ((".." | "...") <bitOrExpr>)*
  **
  private Expr rangeExpr()
  {
    expr := addExpr
    if (curt === Token.dotDot || curt === Token.dotDotLt)
    {
      start := expr
      exclusive := consume.kind === Token.dotDotLt
      end := addExpr
      return RangeLiteralExpr(expr.loc, ns.rangeType, start, end, exclusive)
    }
    return expr
  }

  **
  ** Additive expression:
  **   <addExpr>  :=  <multExpr> (("+" | "-") <multExpr>)*
  **
  private Expr addExpr()
  {
    expr := multExpr
    while (curt === Token.plus || curt === Token.minus)
      expr = ShortcutExpr.makeBinary(expr, consume.kind, multExpr)
    return expr
  }

  **
  ** Multiplicative expression:
  **   <multExpr>  :=  <parenExpr> (("*" | "/" | "%") <parenExpr>)*
  **
  private Expr multExpr()
  {
    expr := parenExpr
    while (curt === Token.star || curt === Token.slash || curt === Token.percent)
      expr = ShortcutExpr.makeBinary(expr, consume.kind, parenExpr)
    return expr
  }

  **
  ** Paren grouped expression:
  **   <parenExpr>    :=  <unaryExpr> | <castExpr> | <groupedExpr>
  **   <castExpr>     :=  "(" <type> ")" <parenExpr>
  **   <groupedExpr>  :=  "(" <expr> ")" <termChain>*
  **
  private Expr parenExpr()
  {
    if (curt !== Token.lparen && curt !== Token.lparenSynthetic)
      return unaryExpr

    // consume opening paren (or synthetic paren)
    loc := cur
    consume()

    // In Fantom just like C# and Java, a paren could mean
    // either a cast or a parenthesized expression
    mark := pos
    castType := tryType
    if (curt === Token.rparen)
    {
      consume
      if (castType == null) throw err("Expecting cast '(type)'")
      return TypeCheckExpr(loc, ExprId.coerce, parenExpr, castType)
    }
    reset(mark)

    // this is just a normal parenthesized expression
    expr := expr
    consume(Token.rparen)
    while (true)
    {
      chained := termChainExpr(expr)
      if (chained == null) break
      expr = chained
    }
    return expr
  }

  **
  ** Unary expression:
  **   <unaryExpr>    :=  <prefixExpr> | <termExpr> | <postfixExpr>
  **   <prefixExpr>   :=  ("!" | "+" | "-" | "~" | "++" | "--") <parenExpr>
  **   <postfixExpr>  :=  <termExpr> ("++" | "--")
  **
  private Expr unaryExpr()
  {
    loc := cur
    tok := cur
    tokt := curt

    if (tokt === Token.bang)
    {
      consume
      return UnaryExpr(loc, tokt.toExprId, tokt, parenExpr)
    }

    if (tokt === Token.plus)
    {
      consume
      return parenExpr // optimize +expr to just expr
    }

    if (tokt === Token.minus)
    {
      consume
      return ShortcutExpr.makeUnary(loc, tokt, parenExpr)
    }

    if (tokt.isIncrementOrDecrement)
    {
      consume
      return ShortcutExpr.makeUnary(loc, tokt, parenExpr)
    }

    expr := termExpr

    // postfix ++/-- must be on the same line
    tokt = curt
    tok = cur
    if (tokt.isIncrementOrDecrement && !tok.newline)
    {
      consume
      shortcut := ShortcutExpr.makeUnary(loc, tokt, expr)
      shortcut.isPostfixLeave = true
      return shortcut
    }

    return expr
  }

//////////////////////////////////////////////////////////////////////////
// Term Expr
//////////////////////////////////////////////////////////////////////////

  **
  ** A term is a base terminal such as a variable, call, or literal,
  ** optionally followed by a chain of accessor expressions - such
  ** as "x.y[z](a, b)".
  **
  **   <termExpr>  :=  <termBase> <termChain>*
  **
  private Expr termExpr(Expr? target := null)
  {
    if (target == null) target = termBaseExpr
    while (true)
    {
      chained := termChainExpr(target)
      if (chained == null) break
      target = chained
    }
    return target
  }

  **
  ** Atomic base of a termExpr
  **
  **   <termBase>    :=  <literal> | <idExpr> | <closure> | <dsl>
  **   <literal>     :=  "null" | "this" | "super" | <bool> | <int> |
  **                     <float> | <str> | <duration> | <list> | <map> | <uri> |
  **                     <typeLiteral> | <slotLiteral>
  **   <typeLiteral> :=  <type> "#"
  **   <slotLiteral> :=  [<type>] "#" <id>
  **
  private Expr termBaseExpr()
  {
    loc := cur

    ctype := tryType
    if (ctype != null) return typeBaseExpr(loc, ctype)

    switch (curt)
    {
      case Token.amp:             return idExpr(null, false, false)
      case Token.identifier:      return idExpr(null, false, false)
      case Token.intLiteral:      return LiteralExpr(loc, ExprId.intLiteral, ns.intType, consume.val)
      case Token.floatLiteral:    return LiteralExpr(loc, ExprId.floatLiteral, ns.floatType, consume.val)
      case Token.decimalLiteral:  return LiteralExpr(loc, ExprId.decimalLiteral, ns.decimalType, consume.val)
      case Token.strLiteral:      return LiteralExpr(loc, ExprId.strLiteral, ns.strType, consume.val)
      case Token.durationLiteral: return LiteralExpr(loc, ExprId.durationLiteral, ns.durationType, consume.val)
      case Token.uriLiteral:      return LiteralExpr(loc, ExprId.uriLiteral, ns.uriType, consume.val)
      case Token.localeLiteral:   return LocaleLiteralExpr(loc, consume.val)
      case Token.lbracket:        return collectionLiteralExpr(loc, null)
      case Token.falseKeyword:    consume; return LiteralExpr.makeFalse(loc, ns)
      case Token.nullKeyword:     consume; return LiteralExpr.makeNull(loc, ns)
      case Token.superKeyword:    consume; if (curt !== Token.dot) err("Expected '.' dot after 'super' keyword"); return SuperExpr(loc)
      case Token.thisKeyword:     consume; return ThisExpr(loc)
      case Token.itKeyword:       consume; return ItExpr(loc)
      case Token.trueKeyword:     consume; return LiteralExpr.makeTrue(loc, ns)
      case Token.pound:           consume; return SlotLiteralExpr(loc, curType, consumeId)
      case Token.awaitKeyword:    consume; return AwaitExpr(loc, this.expr)
      case Token.sizeofKeyword:   
        consume;
        consume(Token.lparen)
        expr := SizeOfExpr(loc, this.ctype)
        consume(Token.rparen)
        return expr
      case Token.addressofKeyword:
        consume;
        consume(Token.lparen)
        expr := AddressOfExpr(loc, this.expr)
        consume(Token.rparen)
        return expr
    }

    if (curt == Token.pipe)
      throw err("Invalid closure expression (check types)")
    else {
      if (cur.kind.keyword) throw err("Expected expression, not keyword '" + cur + "'")
      else throw err("Expected expression, not '" + cur + "'")
    }
  }

  **
  ** Handle a term expression which begins with a type literal.
  **
  private Expr typeBaseExpr(Loc loc, CType ctype)
  {
    // type or slot literal
    if (curt === Token.pound)
    {
      consume
      if (curt === Token.identifier && !cur.newline)
        return SlotLiteralExpr(loc, ctype, consumeId)
      else
        return LiteralExpr(loc, ExprId.typeLiteral, ns.typeType, ctype)
    }

    // dot is named super or static call chain
    if (curt == Token.dot)
    {
      consume
      if (curt === Token.superKeyword)
      {
        consume
        if (curt !== Token.dot) err("Expected '.' dot after 'super' keyword")
        return SuperExpr(loc, ctype)
      }
      else
      {
        return idExpr(StaticTargetExpr(loc, ctype), false, false)
      }
    }

    // dsl
    if (curt == Token.dsl)
    {
      srcLoc := Loc(cur.file, cur.line, cur.col+2)
      dslVal := cur as TokenValDsl
      return DslExpr(loc, ctype, srcLoc, consume.val)
      {
        leadingTabs = dslVal.leadingTabs
        leadingSpaces = dslVal.leadingSpaces
      }
    }

    // list/map literal with explicit type
    if (curt === Token.lbracket)
    {
      return collectionLiteralExpr(loc, ctype)
    }

    // closure
    if (curt == Token.lbrace && ctype is FuncType)
    {
      return closure(loc, (FuncType)ctype)
    }

    // simple literal type(arg)
    if (curt == Token.lparen)
    {
      construction := CallExpr(loc, StaticTargetExpr(loc, ctype), "<ctor>", ExprId.construction)
      callArgs(construction)
      return construction
    }

    // constructor it-block {...}
    if (curt == Token.lbrace)
    {
      // if not inside a field/method we have complex literal for facet
      if (curSlot == null) return complexLiteral(loc, ctype)

      // shortcut for make with optional it-block
      ctor := CallExpr(loc, StaticTargetExpr(loc, ctype), "make")
      itBlock := tryItBlock
      if (itBlock != null) ctor.args.add(itBlock)
      return ctor
    }

    throw err("Unexpected type literal $ctype", loc)
  }

  **
  ** A chain expression is a piece of a term expression that may
  ** be chained together such as "call.var[x]".  If the specified
  ** target expression contains a chained access, then return the new
  ** expression, otherwise return null.
  **
  **   <termChain>      :=  <compiledCall> | <dynamicCall> | <indexExpr>
  **   <compiledCall>   :=  "." <idExpr>
  **   <dynamicCall>    :=  "->" <idExpr>
  **
  private Expr? termChainExpr(Expr target)
  {
    loc := cur

    // handle various call operators: . -> ?. ?->
    switch (curt)
    {
      // if ".id" field access or ".id" call
      case Token.dot: consume;  return idExpr(target, false, false)

      // if "->id" dynamic call
      case Token.arrow: consume; return idExpr(target, true, false, false)

      // if "~>" checked dynamic call
      case Token.tildeArrow:
        consume; return idExpr(target, true, false, true)

      // if "?.id" safe call
      case Token.safeDot: consume; return idExpr(target, false, true)

      // if "?->id" safe dynamic call
      case Token.safeArrow: consume; return idExpr(target, true, true, false)

      // if "?~>id" safe checked dynamic call
      case Token.safeTildeArrow:
        consume; return idExpr(target, true, true, true)
    }

    // if target[...]
    if (cur.isIndexOpenBracket) return indexExpr(target)

    // if target(...)
    if (cur.isCallOpenParen) return callOp(target)

    // if target {...}
    if (curt === Token.lbrace)
    {
      itBlock := tryItBlock
      if (itBlock != null) return itBlock.toWith(target)
    }

    // otherwise the expression should be finished
    return null
  }

//////////////////////////////////////////////////////////////////////////
// Term Expr Utils
//////////////////////////////////////////////////////////////////////////

  **
  ** Identifier expression:
  **   <idExpr>  :=  <local> | <field> | <call>
  **   <local>   :=  <id>
  **   <field>   :=  ["*"] <id>
  **
  private Expr idExpr(Expr? target, Bool dynamicCall, Bool safeCall, Bool checkedCall := true)
  {
    loc := cur

    if (curt == Token.amp)
    {
      consume
      return UnknownVarExpr(loc, target, consumeId, ExprId.storage)
    }

    if (peek.isCallOpenParen)
    {
      call := callExpr(target)
      call.isDynamic = dynamicCall
      call.isCheckedCall = checkedCall
      call.isSafe = safeCall
      return call
    }

    name := consumeId

    // if we have a closure then this is a call with one arg of a closure
    closure := tryClosure
    if (closure != null)
    {
      call := CallExpr(loc)
      call.target    = target
      call.name      = name
      call.isDynamic = dynamicCall
      call.isCheckedCall = checkedCall
      call.isSafe    = safeCall
      call.noParens  = true
      call.args.add(closure)
      return call
    }

    // if dynamic call then we know this is a call not a field
    if (dynamicCall)
    {
      call := CallExpr(loc)
      call.target    = target
      call.name      = name
      call.isDynamic = true
      call.isCheckedCall = checkedCall
      call.isSafe    = safeCall
      call.noParens  = true
      return call
    }

    // at this point we are parsing a single identifier, but
    // if it looks like it was expected to be a type we can
    // provide a more meaningful error
    if (curt === Token.pound) throw err("Unknown type '$name' for type literal", loc)

    return UnknownVarExpr(loc, target, name) { isSafe = safeCall }
  }

  **
  ** Call expression:
  **   <call>  :=  <id> ["(" <args> ")"] [<closure>]
  **
  private CallExpr callExpr(Expr? target)
  {
    call := CallExpr(cur)
    call.target  = target
    call.name    = consumeId
    callArgs(call)
    return call
  }

  **
  ** Parse args with known parens:
  **   <args>  := [<expr> ("," <expr>)*] [<closure>]
  **
  private Void callArgs(CallExpr call, Bool closureOk := true)
  {
    consume(Token.lparen)
    if (curt != Token.rparen)
    {
      while (true)
      {
        //named param
        if (curt === Token.identifier && peekt === Token.colon) {
          if ((cur.val as Str).getSafe(0, 'x').isUpper) {
            //May be a MapLiteral 'Obj:Obj[:]', just discard parse named param
          }
          else {
            name := consumeId
            consume(Token.colon)
            if (call.paramNames == null) call.paramNames = [Int:Str][:]
            call.paramNames[call.args.size] = name
          }
        }
        call.args.add(expr)
        if (curt === Token.rparen) break
        consume(Token.comma)
      }
    }
    consume(Token.rparen)

    if (closureOk)
    {
      closure := tryClosure
      if (closure != null) call.args.add(closure)
    }
  }

  **
  ** Call operator:
  **   <callOp>  := "(" <args> ")" [<closure>]
  **
  private Expr callOp(Expr target)
  {
    loc := cur
    call := CallExpr(loc)
    call.isCallOp = true
    call.target = target
    callArgs(call)
    call.name = "call"
    return call
  }

  **
  ** Index expression:
  **   <indexExpr>  := "[" <expr> "]"
  **
  private Expr indexExpr(Expr target)
  {
    loc := cur
    consume(Token.lbracket)

    // nice error for BadType[,]
    if (curt === Token.comma && target.id === ExprId.unknownVar)
      throw err("Unknown type '$target' for list literal", target.loc)

    // otherwise this must be a standard single key index
    expr := expr
    consume(Token.rbracket)
    return ShortcutExpr.makeGet(loc, target, expr)
  }

//////////////////////////////////////////////////////////////////////////
// Collection "Literals"
//////////////////////////////////////////////////////////////////////////

  **
  ** Collection literal:
  **   <list>       :=  [<type>] "[" <listItems> "]"
  **   <listItems>  :=  "," | (<expr> ("," <expr>)*)
  **   <map>        :=  [<mapType>] "[" <mapItems> "]"
  **   <mapItems>   :=  ":" | (<mapPair> ("," <mapPair>)*)
  **   <mapPair>    :=  <expr> ":" <expr>
  **
  private Expr collectionLiteralExpr(Loc loc, CType? explicitType)
  {
    // empty list [,]
    if (peekt === Token.comma)
      return listLiteralExpr(loc, explicitType, null)

    // empty map [:]
    if (peekt === Token.colon)
      return mapLiteralExpr(loc, explicitType, null)

    // opening bracket
    consume(Token.lbracket)

    // [] is error
    if (curt === Token.rbracket)
    {
      err("Invalid list literal; use '[,]' for empty Obj[] list", loc)
      consume
      return ListLiteralExpr(loc)
    }

    // read first expression
    first := expr

    // at this point we can determine if it is a list or a map
    if (curt === Token.colon)
      return mapLiteralExpr(loc, explicitType, first)
    else
      return listLiteralExpr(loc, explicitType, first)
  }

  **
  ** Parse List literal; if first is null then
  **   cur must be on lbracket
  ** else
  **   cur must be on comma after first item
  **
  private ListLiteralExpr listLiteralExpr(Loc loc, CType? explicitType, Expr? first)
  {
    // explicitType is type of List:  Str[,]
    if (explicitType != null)
      explicitType = explicitType.toListOf

    list := ListLiteralExpr(loc, (ListType?)explicitType)

    // if first is null, must be on lbracket
    if (first == null)
    {
      consume(Token.lbracket)

      // if [,] empty list
      if (curt === Token.comma)
      {
        consume
        consume(Token.rbracket)
        return list
      }

      first = expr
    }

    list.vals.add(first)
    while (curt === Token.comma)
    {
      consume
      if (curt === Token.rbracket) break // allow extra trailing comma
      list.vals.add(expr)
    }
    consume(Token.rbracket)
    return list
  }

  **
  ** Parse Map literal; if first is null:
  **   cur must be on lbracket
  ** else
  **   cur must be on colon of first key/value pair
  **
  private MapLiteralExpr mapLiteralExpr(Loc loc, CType? explicitType, Expr? first)
  {
    // explicitType is *the* map type: Str:Str[,]
    if (explicitType != null && explicitType isnot MapType)
    {
      err("Invalid map type '$explicitType' for map literal", loc)
      explicitType = null
    }

    map := MapLiteralExpr(loc, (MapType?)explicitType)

    // if first is null, must be on lbracket
    if (first == null)
    {
      consume(Token.lbracket)

      // if [,] empty list
      if (curt === Token.colon)
      {
        consume
        consume(Token.rbracket)
        return map
      }

      first = expr
    }

    map.keys.add(first)
    consume(Token.colon)
    map.vals.add(expr)
    while (curt === Token.comma)
    {
      consume
      if (curt === Token.rbracket) break // allow extra trailing comma
      map.keys.add(expr)
      consume(Token.colon)
      map.vals.add(expr)
    }
    consume(Token.rbracket)
    return map
  }

//////////////////////////////////////////////////////////////////////////
// Closure
//////////////////////////////////////////////////////////////////////////

  **
  ** Attempt to parse a closure expression or return null if we
  ** aren't positioned at the start of a closure expression.
  **
  private ClosureExpr? tryClosure()
  {
    loc := cur

    // if curly brace, then this is it-block closure
    if (curt === Token.lbrace) return tryItBlock

    // if not pipe then not closure
    if (curt !== Token.pipe) return null

    // otherwise this can only be a FuncType declaration,
    // so give it a whirl, and bail if that fails
    mark := pos
    funcType := tryType as FuncType
    if (funcType == null) { reset(mark); return null }

    // if we don't see opening brace for body - no go
    if (curt !== Token.lbrace) { reset(mark); return null }

    return closure(loc, funcType)
  }

  **
  ** Parse it-block closure.
  **
  private ClosureExpr? tryItBlock()
  {
    // field initializers look like an it-block, but
    // we can safely peek to see if the next token is "get",
    // "set", or a field getter/setter keyword like "private"
    if (inFieldInit)
    {
      if (peek.kind.isProtectionKeyword) return null
      if (peek.kind === Token.staticKeyword) return null
      if (peek.kind === Token.readonlyKeyword) return null
      if (peekt == Token.identifier)
      {
        if (peek.val == "get" || peek.val == "set") return null
      }
    }

    ib := closure(cur, ns.itBlockType)
    ib.isItBlock = true
    ib.itType = ns.error
    return ib
  }

  **
  ** Parse body of closure expression and return ClosureExpr.
  **
  private ClosureExpr closure(Loc loc, FuncType funcType)
  {
    if (curType == null || curSlot == null) throw err("Unexpected closure")

    // closure anonymous class name: class$slot$count
    name := "${curType.name}\$${curSlot.name}\$${closureCount++}"

    // verify func types has named parameters
    if (funcType.unnamed) err("Closure parameters must be named", loc)

    // create closure
    closure := ClosureExpr(loc, curType, curSlot, curClosure, funcType, name)

    // save all closures in global list and list per type
    closures.add(closure)
    curType.closures.add(closure)

    // parse block; temporarily change curClosure
    oldClosure := curClosure
    curClosure = closure
    closure.code = block
    curClosure = oldClosure

    return closure
  }

  **
  ** This is used to parse an it-block outside of the scope of a
  ** field or method definition.  It is used to parse complex literals
  ** declared in a facet without mucking up the closure code path.
  **
  private Expr complexLiteral(Loc loc, CType ctype)
  {
    complex := ComplexLiteral(loc, ctype)
    consume(Token.lbrace)
    while (curt !== Token.rbrace)
    {
      complex.names.add(consumeId)
      consume(Token.assign)
      complex.vals.add(expr)
      endOfStmt
    }
    consume(Token.rbrace)
    return complex
  }

//////////////////////////////////////////////////////////////////////////
// Types
//////////////////////////////////////////////////////////////////////////

  **
  ** Parse a type production into a CType and wrap it as AST TypeRef.
  **
  private TypeRef typeRef()
  {
    Loc loc := cur
    return TypeRef(loc, ctype(true))
  }

  **
  ** If the current stream of tokens can be parsed as a
  ** valid type production return it.  Otherwise leave
  ** the parser positioned on the current token.
  **
  private CType? tryType()
  {
    // types can only begin with identifier, | or [
    if (curt !== Token.identifier && curt !== Token.pipe && curt !== Token.lbracket)
      return null

    oldSuppress := suppressErr
    suppressErr = true
    mark := pos
    CType? type := null
    try
    {
      type = ctype()
    }
    catch (SuppressedErr e)
    {
    }
    suppressErr = oldSuppress
    if (type == null) reset(mark)
    return type
  }

  **
  ** Type signature:
  **   <type>      :=  <simpleType> | <listType> | <mapType> | <funcType>
  **   <listType>  :=  <type> "[]"
  **   <mapType>   :=  ["["] <type> ":" <type> ["]"]
  **
  private CType ctype(Bool isTypeRef := false)
  {
    CType? t := null

    // Types can begin with:
    //   - id
    //   - [k:v]
    //   - |a, b -> r|
    if (curt === Token.identifier)
    {
      t = simpleType
    }
    else if (curt === Token.lbracket)
    {
      loc := consume(Token.lbracket)
      t = ctype
      consume(Token.rbracket)
      if (!(t is MapType)) err("Invalid map type", loc)
    }
    else if (curt === Token.pipe)
    {
      t = funcType(isTypeRef)
    }
    else
    {
      throw err("Expecting type name")
    }

    // check for ? nullable
    if (curt === Token.question && !cur.whitespace)
    {
      consume(Token.question)
      t = t.toNullable
      if (curt === Token.question && !cur.whitespace)
        throw err("Type cannot have multiple '?'")
    }

    // trailing [] for lists
    while (curt === Token.lbracket && peekt === Token.rbracket)
    {
      consume(Token.lbracket)
      consume(Token.rbracket)
      t = t.toListOf
      if (curt === Token.question && !cur.whitespace)
      {
        consume(Token.question)
        t = t.toNullable
      }
    }

    // check for type?:type map (illegal)
    if (curt === Token.elvis && !cur.whitespace)
    {
      throw err("Map type cannot have nullable key type")
    }

    // check for ":" for map type
    if (curt === Token.colon)
    {
      if (t.isNullable && (t.deref isnot GenericParameter)) throw err("Map type cannot have nullable key type")
      consume(Token.colon)
      key := t
      val := ctype
      //throw err("temp test")
      t = MapType(key, val)
    }

    // check for ? nullable
    if (curt === Token.question && !cur.whitespace)
    {
      consume(Token.question)
      t = t.toNullable
    }

    return t
  }

  **
  ** Simple type signature:
  **   <simpleType>  :=  <id> ["::" <id>]
  **
  private CType simpleType(Bool allowDefaultParameterized := true)
  {
    loc := cur
    id := consumeId

    // fully qualified
    if (curt === Token.doubleColon)
    {
      consume
      return ResolveImports.resolveQualified(this, id, consumeId, loc) ?: ns.voidType
    }

    // unqualified name, lookup in imported types
    types := unit.importedTypes[id]
    if (types == null || types.isEmpty)
    {
      // handle sys generic parameters
      //if (compiler.isSys && id.size == 1)
      //  return ns.genericParameter(id)

      if (curType != null && curType.isGeneric) {
        gt := curType.getGenericParameter(id)
        if (gt != null) return gt
      }

      d := curType as TypeDef
      //echo("$curType ${curType?.isGeneric} ${curType?.typeof} ${d?.genericParameters}")
      // not found in imports
      err("Unknown type '$id'", loc)
      return ns.voidType
    }

    // if more then one, first try to exclude those internal to other pods
    if (types.size > 1)
    {
      publicTypes := types.exclude |t| { t.isInternal && t.pod.name != compiler.pod.name }
      if (!publicTypes.isEmpty) types = publicTypes
    }

    // if more then one its ambiguous (use errReport to avoid suppression)
    if (types.size > 1)
      errReport(CompilerErr("Ambiguous type: " + types.join(", "), loc))

    type := types.first
    //generic param
    if (curt === Token.lt) {
      if (!type.isGeneric) {
        errReport(CompilerErr("$type is not Generic", loc))
      }
      consume
      params := CType[,]
      while (true) {
        type1 := typeRef
        params.add(type1)
        if (curt === Token.comma) {
          consume
          continue
        }
        else if (curt == Token.gt) {
          consume
          break
        }
      }
      type = ParameterizedType.create(type, params)
    }
    else if (type.isGeneric) {
      if (allowDefaultParameterized)
        type = ParameterizedType.create(type)
      else
        errReport(CompilerErr("$type must be parameterized", loc))
    }

    // got it
    return type
  }

  **
  ** Method type signature:
  **   <funcType>       :=  "|" ("->" | <funcTypeSig>) "|"
  **   <funcTypeSig>    :=  <formals> ["->" <type>]
  **   <formals>        :=  [<formal> ("," <formal>)*]
  **   <formal>         :=  <formFull> | <formalInferred> | <formalTypeOnly>
  **   <formalFull>     :=  <type> <id>
  **   <formalInferred> :=  <id>
  **   <formalTypeOnly> :=  <type>
  **
  ** If isTypeRef is true (slot signatures), then we requrie explicit
  ** parameter types.
  **
  private CType funcType(Bool isTypeRef)
  {
    params := CType[,]
    names  := Str[,]
    ret := ns.voidType

    // opening pipe
    consume(Token.pipe)

    // params, must be one if no ->
    inferred := false
    unnamed := [false]
    if (curt !== Token.arrow) inferred = funcTypeFormal(isTypeRef, params, names, unnamed)
    while (curt === Token.comma)
    {
      consume
      inferred = inferred.or(funcTypeFormal(isTypeRef, params, names, unnamed))
    }

    // if we see ?-> in a function type, that means |X?->ret|
    if (curt === Token.safeArrow && !params.isEmpty)
    {
      params[params.size-1] = params[params.size-1].toNullable
      consume
      ret = ctype
    }

    // optional arrow
    if (curt === Token.arrow)
    {
      consume
      if (curt !== Token.pipe || cur.whitespace)
        ret = ctype
      else if (!params.isEmpty) // use errReport to avoid suppression
        errReport(CompilerErr("Expecting function return type", cur))
    }
    else if (!isTypeRef) {
      inferred = true
    }

    // closing pipe
    consume(Token.pipe)

    ft := FuncType(params, names, ret)
    ft.inferredSignature = inferred
    ft.unnamed = unnamed.first
    return ft
  }

  private Bool funcTypeFormal(Bool isTypeRef, CType[] params, Str[] names, Bool[] unnamed)
  {
    t := isTypeRef ? ctype(true) : tryType
    if (t != null)
    {
      params.add(t)
      if (curt === Token.identifier)
      {
        names.add(consumeId)
      }
      else
      {
        names.add("_" + ('a'+names.size).toChar)
        unnamed[0] = true
      }
      return false
    }
    else
    {
      params.add(ns.objType.toNullable)
      names.add(consumeId)
      return true
    }
  }

//////////////////////////////////////////////////////////////////////////
// Misc
//////////////////////////////////////////////////////////////////////////

  **
  ** Parse fandoc or return null
  **
  private DocDef? doc()
  {
    DocDef? doc := null
    while (curt === Token.docComment)
    {
      loc := cur
      lines := (Str[])consume(Token.docComment).val
      doc = DocDef(loc, lines)
    }
    return doc
  }

//////////////////////////////////////////////////////////////////////////
// Errors
//////////////////////////////////////////////////////////////////////////

  override CompilerErr err(Str msg, Loc? loc := null)
  {
    if (loc == null) loc = cur
    return super.err(msg, loc)
  }

//////////////////////////////////////////////////////////////////////////
// Tokens
//////////////////////////////////////////////////////////////////////////

  **
  ** Verify current is an identifier, consume it, and return it.
  **
  private Str consumeId()
  {
    if (curt !== Token.identifier)
      throw err("Expected identifier, not '$cur'")
    return consume.val
  }

  **
  ** Check that the current token matches the specified
  ** type, but do not consume it.
  **
  private Void verify(Token kind)
  {
    if (curt !== kind)
      throw err("Expected '$kind.symbol', not '$cur'");
  }

  **
  ** Consume the current token and return consumed token.
  ** If kind is non-null then verify first
  **
  private TokenVal consume(Token? kind := null)
  {
    // verify if not null
    if (kind != null) verify(kind)

    // save the current we are about to consume for return
    result := cur

    // get the next token from the buffer, if pos is past numTokens,
    // then always use the last token which will be eof
    TokenVal? next;
    pos++;
    if (pos+1 < numTokens)
      next = tokens[pos+1]  // next peek is cur+1
    else
      next = tokens[numTokens-1]

    this.cur   = peek
    this.peek  = next
    this.curt  = cur.kind
    this.peekt = peek.kind

    return result
  }

  **
  ** Statements can be terminated with a semicolon, end of line
  ** or } end of block.   Return true on success.  On failure
  ** return false if errMsg is null or log/throw an exception.
  **
  private Bool endOfStmt(Str? errMsg := "Expected end of statement: semicolon, newline, or end of block; not '$cur'")
  {
    if (cur.newline) return true
    if (curt === Token.semicolon) { consume; return true }
    if (curt === Token.rbrace) return true
    if (curt === Token.eof) return true
    if (errMsg == null) return false
    throw err(errMsg)
  }

  **
  ** Reset the current position to the specified tokens index.
  **
  private Void reset(Int pos)
  {
    this.pos   = pos
    this.cur   = tokens[pos]
    if (pos+1 < numTokens)
      this.peek  = tokens[pos+1]
    else
      this.peek  = tokens[pos]
    this.curt  = cur.kind
    this.peekt = peek.kind
  }

//////////////////////////////////////////////////////////////////////////
// Parser Flags
//////////////////////////////////////////////////////////////////////////

  // These are flags used only by the parser we merge with FConst
  // flags by starting from most significant bit and working down
  const static Int Once     := 0x8000_0000
  const static Int Data     := 0x4000_0000
  const static Int ParserFlagsMask := 0

  // Bitwise and this mask to clear all protection scope flags
  const static Int ProtectionMask := (FConst.Public).or(FConst.Protected).or(FConst.Private).or(FConst.Internal).not

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private CompilationUnit unit    // compilation unit to generate
  private TokenVal[] tokens       // tokens all read in
  private Int numTokens           // number of tokens
  private Int pos                 // offset into tokens for cur
  private TokenVal? cur           // current token
  private Token? curt             // current token type
  private TokenVal? peek          // next token
  private Token? peekt            // next token type
  private Bool inFieldInit        // are we currently in a field initializer
  private TypeDef? curType        // current TypeDef scope
  private SlotDef? curSlot        // current SlotDef scope
  private ClosureExpr? curClosure // current ClosureExpr if inside closure
  private Int? closureCount       // number of closures parsed inside curSlot
  private ClosureExpr[] closures  // list of all closures parsed

}