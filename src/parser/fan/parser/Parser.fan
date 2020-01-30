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
public class Parser
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Construct the parser for the specified compilation unit.
  **
  new make(ParserSupport parserSupport, Loc loc, Str code, PodDef pod)
  {
    unit := CompilationUnit(loc, pod)
    tokenizer := Tokenizer(parserSupport, loc, code, true)
    unit.tokens = tokenizer.tokenize
    
    this.parserSupport = parserSupport
    this.unit      = unit
    this.tokens    = unit.tokens
    this.numTokens = unit.tokens.size
    this.closures  = [,]
    reset(0)
  }
  
  static Parser makeSimple(Str code, Str name, Bool deep := true) {
    loc := Loc.makeUninit
    parserSupport := ParserSupport()
    pod := PodDef(loc, name)
    
    if (deep) return DeepParser(parserSupport, loc, code, pod)
    return Parser(parserSupport, loc, code, pod)
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
  
  
  virtual CallExpr? ctorChain(MethodDef method)
  {
    consume(Token.colon)
    expr
    return null
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
    if (flags.and(FConst.ProtectionMask.not) == 0) flags = flags.or(FConst.Public)
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
        flags = flags.or(FConst.Data)
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
    def := TypeDef(loc, unit, name)
    unit.types.add(def)
//    def := unit.types.find |TypeDef def->Bool| { def.name == name }
//    if (def == null) throw err("Invalid class definition", cur)

    // populate it's doc, facets, and flags
    def.doc    = doc
    def.facets = facets
    def.flags  = flags
    if (def.isFacet) def.inheritances.add(TypeRef.facetType(loc))

    //GenericType Param
    if (curt === Token.lt) {
      consume
      gparams := GenericParameter[,]
      while (true) {
        paramName := consumeId
//        conflict := unit.importedTypes[paramName]
//        if (conflict != null) {
//          throw err("generic type conflict: $conflict", cur)
//        }
        param := GenericParameter(paramName, def, gparams.size)
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
//      if (!first.isMixin)
//        def.base = first
//      else
//        def.mixins.add(first)
      def.inheritances.add(first)

      // additional mixins
      while (curt === Token.comma)
      {
        consume
        def.inheritances.add(inheritType)
      }
    }

    // if no inheritance specified then apply default base class
    if (def.inheritances.isEmpty)
    {
      def.baseSpecified = false
      if (isEnum)
        def.inheritances.add(TypeRef.enumType(loc))
      else if (def.qname != "sys::Obj")
        def.inheritances.add(TypeRef.objType(loc))
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

  private TypeRef inheritType()
  {
//    Loc loc := cur
//    t := TypeRef(loc, simpleType(false))
    return simpleType(false)
    //TODO
    //if (t == ns.facetType) err("Cannot inherit 'Facet' explicitly", t.loc)
    //if (t == ns.enumType)  err("Cannot inherit 'Enum' explicitly", t.loc)
//    return t
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
        case Token.onceKeyword:      flags = flags.or(FConst.Once) // Parser only flag
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
// Deep parser
//////////////////////////////////////////////////////////////////////////

  **
  ** Top level for blocks which must be surrounded by braces
  **
  virtual Block? block()
  {
//    verify(Token.lbrace)
    consume(Token.lbrace)
    deep := 1
    while (deep > 0) {
      if (curt == Token.rbrace) --deep
      else if (curt == Token.lbrace) ++deep
      consume
    }
    return null
  }
  
  private Void skipBracket() {
    if (curt == Token.lparen) {
        consume
        deep := 1
        while (deep > 0) {
          if (curt == Token.rparen) --deep
          else if (curt == Token.lparen) ++deep
          consume
        }
    }
    if (curt == Token.lbrace) {
        consume
        deep := 1
        while (deep > 0) {
          if (curt == Token.rbrace) --deep
          else if (curt == Token.lbrace) ++deep
          consume
        }
    }
  }
  
  virtual Expr? expr() {
    skipBracket
    
    while (curt != Token.comma && curt != Token.semicolon &&
          curt != Token.eof && curt != Token.rparen) {
      skipBracket
      consume
    }
    return null
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
      return methodDef(loc, parent, doc, facets, flags.or(FConst.Ctor), TypeRef.voidType(loc), consumeId)
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
      returns := TypeRef.voidType(loc)
      if (flags.and(FConst.Static) != 0) {
//        if (parent.isGeneric) {
//          TypeDef gp := parent.deref
//          params := gp.genericParameters
//          returns = ParameterizedType.create(parent, params)
//        }
        returns = parent.asRef(loc)
      }
      return methodDef(loc, parent, doc, facets, flags, returns, name)
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
        if (flags.and(FConst.Const) != 0) {
          err("var must not const", loc)
        }
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
      TypeRef? type := null
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
    field.flags  = flags.and(FConst.ParserFlagsMask.not)
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

    //TODO gen getter/setter
    // generate synthetic getter or setter code if necessary
//    if (!field.isConst && !field.isReadonly)
//    {
//      if (field.get.code == null) genSyntheticGet(field)
//      if (field.set.code == null) genSyntheticSet(field)
//    }

    // const override has getter only
//    if ((field.isConst || field.isReadonly) && field.isOverride)
//    {
//      defGet(field)
//      genSyntheticGet(field)
//    }

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
    set.ret   = TypeRef.voidType(loc)
    set.params.add(ParamDef(loc, f.fieldType, "it"))
    f.set = set
  }

//  private Void genSyntheticGet(FieldDef f)
//  {
//    loc := f.loc
//    f.get.flags = f.get.flags.or(FConst.Synthetic)
//    if (!f.isAbstract && !f.isNative)
//    {
//      f.flags = f.flags.or(FConst.Storage)
//      f.get.code = Block(loc)
//      f.get.code.add(ReturnStmt(loc, f.makeAccessorExpr(loc, false)))
//    }
//  }
//
//  private Void genSyntheticSet(FieldDef f)
//  {
//    loc := f.loc
//    f.set.flags = f.set.flags.or(FConst.Synthetic)
//    if (!f.isAbstract && !f.isNative)
//    {
//      f.flags = f.flags.or(FConst.Storage)
//      lhs := f.makeAccessorExpr(loc, false)
//      rhs := UnknownVarExpr(loc, null, "it")
//      f.set.code = Block(loc)
//      f.set.code.add(BinaryExpr.makeAssign(lhs, rhs).toStmt)
//      f.set.code.add(ReturnStmt(loc))
//    }
//  }

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
          if (accessorFlags.and(FConst.ProtectionMask) != 0)
            err("Cannot use modifiers on field setter except to narrow protection", loc)
          f.set.flags = f.set.flags.and(FConst.ProtectionMask).or(accessorFlags)
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
        ret = TypeRef.voidType(loc)
        method.ret = ret
      }
    }

    // if This is returned, then we configure inheritedRet
    // right off the bat (this is actual signature we will use)
    //TODO
//    if (ret.isThis) method.inheritedRet = parent

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
// Types
//////////////////////////////////////////////////////////////////////////

  **
  ** Parse a type production into a CType and wrap it as AST TypeRef.
  **
  protected TypeRef typeRef()
  {
//    Loc loc := cur
//    return TypeRef(loc, ctype(true))
    return ctype(true)
  }

  **
  ** If the current stream of tokens can be parsed as a
  ** valid type production return it.  Otherwise leave
  ** the parser positioned on the current token.
  **
  protected TypeRef? tryType()
  {
    // types can only begin with identifier, | or [
    if (curt !== Token.identifier && curt !== Token.pipe && curt !== Token.lbracket)
      return null
      
    if (curt === Token.identifier) {
      if (peekt == Token.lbracket && peekpeek.kind == Token.rbracket) {
        //Int[]
      }
      else if (peekt != Token.identifier) {
        return null
      }
    }
      
    type := ctype()
    return type
  }

  **
  ** Type signature:
  **   <type>      :=  <simpleType> | <listType> | <mapType> | <funcType>
  **   <listType>  :=  <type> "[]"
  **   <mapType>   :=  ["["] <type> ":" <type> ["]"]
  **
  protected TypeRef ctype(Bool isTypeRef := false)
  {
    TypeRef? t := null
    loc := cur

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
      loc = consume(Token.lbracket)
      t = ctype
      consume(Token.rbracket)
      //if (!(t is MapType)) err("Invalid map type", loc)
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
      valT := t
      t = TypeRef(loc, "sys", "List")
      t.genericArgs = [valT]
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
      if (t.isNullable && (t isnot GenericParameter)) throw err("Map type cannot have nullable key type")
      consume(Token.colon)
      key := t
      val := ctype
      //throw err("temp test")
//      t = MapType(key, val)
      t = TypeRef(loc, "sys", "Map")
      t.genericArgs = [t, val]
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
  private TypeRef simpleType(Bool allowDefaultParameterized := true)
  {
    loc := cur
    id := consumeId

    TypeRef? type
    // fully qualified
    if (curt === Token.doubleColon)
    {
      consume
//      return ResolveImports.resolveQualified(this, id, consumeId, loc) ?: ns.voidType
      type = TypeRef(loc, id, consumeId)
    }
    else {
      type = TypeRef(loc, null, id)
    }

    //generic param
    if (curt === Token.lt) {
      //TODO check
//      if (!type.isGeneric) {
//        errReport(CompilerErr("$type is not Generic", loc))
//      }
      consume
      params := TypeRef[,]
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
      type.genericArgs = params
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
  protected FuncType funcType(Bool isTypeRef)
  {
    params := TypeRef[,]
    names  := Str[,]
    loc := cur
    ret := TypeRef.voidType(loc)

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
        err("Expecting function return type")
    }
    else if (!isTypeRef) {
      inferred = true
    }

    // closing pipe
    consume(Token.pipe)

    ft := FuncType(loc, params, names, ret)
    ft.inferredSignature = inferred
    ft.unnamed = unnamed.first
    return ft
  }

  private Bool funcTypeFormal(Bool isTypeRef, TypeRef[] params, Str[] names, Bool[] unnamed)
  {
    if (peekt === Token.colon) {
      names.add(consumeId)
      consume
      params.add(ctype(isTypeRef))
      return true
    }

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
      params.add(TypeRef.objType(cur).toNullable)
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

  CompilerErr err(Str msg, Loc? loc := null)
  {
    if (loc == null) loc = cur
    return parserSupport.err(msg, loc)
  }

//////////////////////////////////////////////////////////////////////////
// Tokens
//////////////////////////////////////////////////////////////////////////

  **
  ** Verify current is an identifier, consume it, and return it.
  **
  protected Str consumeId()
  {
    if (curt !== Token.identifier)
      throw err("Expected identifier, not '$cur'")
    return consume.val
  }

  **
  ** Check that the current token matches the specified
  ** type, but do not consume it.
  **
  protected Void verify(Token kind)
  {
    if (curt !== kind)
      throw err("Expected '$kind.symbol', not '$cur'");
  }

  **
  ** Consume the current token and return consumed token.
  ** If kind is non-null then verify first
  **
  protected TokenVal consume(Token? kind := null)
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
  
  ** next next token
  protected TokenVal peekpeek() {
    if (pos + 2 < numTokens) {
      return tokens[pos+2]
    }
    return tokens[numTokens-1]
  }

  **
  ** Statements can be terminated with a semicolon, end of line
  ** or } end of block.   Return true on success.  On failure
  ** return false if errMsg is null or log/throw an exception.
  **
  protected Bool endOfStmt(Str? errMsg := "Expected end of statement: semicolon, newline, or end of block; not '$cur'")
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
  protected Void reset(Int pos)
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
// Fields
//////////////////////////////////////////////////////////////////////////

  CompilationUnit unit    // compilation unit to generate
  protected TokenVal[] tokens       // tokens all read in
  protected Int numTokens           // number of tokens
  protected Int pos                 // offset into tokens for cur
  protected TokenVal? cur           // current token
  protected Token? curt             // current token type
  protected TokenVal? peek          // next token
  protected Token? peekt            // next token type
  protected Bool inFieldInit        // are we currently in a field initializer
  protected TypeDef? curType        // current TypeDef scope
  protected SlotDef? curSlot        // current SlotDef scope
  protected ClosureExpr? curClosure // current ClosureExpr if inside closure
  protected Int? closureCount       // number of closures parsed inside curSlot
  protected ClosureExpr[] closures  // list of all closures parsed
  
  ParserSupport parserSupport

}