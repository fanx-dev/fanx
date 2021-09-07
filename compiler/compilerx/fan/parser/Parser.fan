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
  new make(CompilerLog log, Str code, CompilationUnit unit)
  {
//    unit := CompilationUnit(loc, pod)
    tokenizer := Tokenizer(log, unit.loc, code, true, false)
    unit.tokens = tokenizer.tokenize
    
    this.log = log
    this.unit      = unit
    this.tokens    = unit.tokens
    this.numTokens = unit.tokens.size
//    this.closures  = [,]
    reset(0)
  }
  
  static Parser makeSimple(Str code, Str name, Bool deep := true) {
    loc := Loc.makeUnknow
    log := CompilerLog()
    pod := PodDef(loc, name)
    unit := CompilationUnit(loc, pod, name)
    if (deep) return DeepParser(log, code, unit)
    return Parser(log, code, unit)
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
    while (curt !== Token.eof) {
      try typeDef
      catch (CompilerErr e) {
        if (!recoverToTypeDef) break
      }
    }
  }
  
  private Bool recoverToTypeDef() {
    oldPos := pos
    while (curt != Token.eof) {
      if (curt == Token.classKeyword && curt == Token.mixinKeyword) {
        curPos := this.pos
        while (isModifierFlags(tokens[curPos-1], true) && curPos > 0) --curPos
        
        if (curPos <= oldPos) return false
        reset(curPos)
        return true
      }
      consume
    }
    return false
  }
  
  private Bool recoverToSlotDef() {
    while (curt != Token.eof) {
      found := false
      if (isModifierFlags(tokens[pos-1], false)) {
        found = true
      }
      if (curt == Token.classKeyword && curt == Token.mixinKeyword) {
        found = true
      }
      if (found) {
        return true
      }
      consume
    }
    return false
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
      parseUsing
  }
  
  private Void parseUsing()
  {
    consume(Token.usingKeyword)
    u := Using(cur.loc)

    // using "some pod name"
    if (curt === Token.strLiteral)
    {
      u.podName = consume(Token.strLiteral).val
    }
    else
    {
      // using [ffi]
      u.podName = ""
      if (curt === Token.lbracket)
      {
        consume
        u.podName = "[" + consumeId + "]"
        consume(Token.rbracket)
      }

      // using [ffi] pod
      u.podName += consumeId
      while (curt === Token.dot) // allow dots in pod name
      {
        consume
        u.podName += "." + consumeId
      }
    }

    // using [ffi] pod::type
    if (curt === Token.doubleColon)
    {
      consume
      u.typeName = consumeId
      while (curt === Token.dollar) // allow $ in type name
      {
        consume
        u.typeName += "\$"
        if (curt == Token.identifier) u.typeName += consumeId
      }

      // using [ffi] pod::type as rename
      if (curt === Token.asKeyword)
      {
        consume
        u.asName = consumeId
      }
    }

    endLoc(u)
    unit.usings.add(u)
  }
  
  virtual CallExpr? ctorChain(MethodDef method)
  {
    consume(Token.colon)
    
    while (curt != Token.eof) {
      if (isExprValue(curt)) {
        consume
        skipBracket(false)
        if (isExprValue(curt)) break
        continue
      }
      
      if (isJoinToken(curt)) {
        consume
        if (skipBracket(false)) {
          if (isExprValue(curt)) break
        }
        continue
      }
      //skipBracket
      break
    }
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
    flags := flags()
    if (flags.and(FConst.ProtectionMask.not) == 0) flags = flags.or(FConst.Public)
    //if (compiler.isSys) flags = flags.or(FConst.Native)
    if (flags.and(FConst.Readonly) != 0) err("Cannot use 'readonly' modifier on type", cur.loc)

    // local working variables
    loc     := cur.loc
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
    unit.addTypeDef(def)
//    def := unit.types.find |TypeDef def->Bool| { def.name == name }
//    if (def == null) throw err("Invalid class definition", cur)

    // populate it's doc, facets, and flags
    def.doc    = doc
    def.facets = facets
    def.flags  = flags
    //if (def.isFacet) def.inheritances.add(TypeRef.facetType(loc))

    //GenericType Param
    if (curt === Token.lt) {
      consume
      gparams := GenericParamDef[,]
      while (true) {
        gLoc := cur.loc
        paramName := consumeId
//        conflict := unit.importedTypes[paramName]
//        if (conflict != null) {
//          throw err("generic type conflict: $conflict", cur)
//        }
        param := GenericParamDef(gLoc, paramName, def, gparams.size)
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
//    closureCount = 0

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

    // start class body
    consume(Token.lbrace)

    // if enum, parse values
    if (isEnum) enumDefs(def)

    // slots
    while (true)
    {
      doc = this.doc
      if (curt === Token.rbrace) break
      
      try {
        slot := slotDef(def, doc)
        def.addSlot(slot)
      }
      catch (CompilerErr e) {
        if (!recoverToSlotDef()) break
      }
    }

    // close cur type
//    closureCount = null
    curType = null

    // end of class body
    consume(Token.rbrace)
    endLoc(def)
  }

  private CType inheritType()
  {
    t := simpleType(false)
    return t
  }
  
//////////////////////////////////////////////////////////////////////////
// Flags
//////////////////////////////////////////////////////////////////////////
  
  private Bool isModifierFlags(TokenVal t, Bool isType) {
    switch (t.kind)
    {
      case Token.publicKeyword:
      case Token.internalKeyword:
      case Token.privateKeyword:
      case Token.protectedKeyword:
      
      case Token.abstractKeyword:
      case Token.constKeyword:
      case Token.finalKeyword:
      case Token.virtualKeyword:
      case Token.nativeKeyword:
        return true
      
      case Token.readonlyKeyword:
      case Token.onceKeyword:
      case Token.extensionKeyword:
      case Token.overrideKeyword:
      case Token.staticKeyword:
      case Token.asyncKeyword:
      case Token.funKeyword:
      case Token.varKeyword:
      case Token.letKeyword:
        if (!isType) return true
      
      case Token.rtconstKeyword:
        if (isType) return true
      
      case Token.identifier:
        if (isType) {
          if (t.val == "facet" || t.val == "enum" || t.val == "struct") {
            return true
          }
        }
    }
    return false
  }

  **
  ** Parse any list of flags in any order, we will check invalid
  ** combinations in the CheckErrors step.
  **
  private Int flags()
  {
    loc := cur.loc
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

    def := EnumDef(cur.loc, doc, facets, consumeId, ordinal)

    // optional ctor args
    if (curt === Token.lparen)
    {
      consume(Token.lparen)
      if (curt != Token.rparen)
      {
        while (true)
        {
          texpr := expr
          //not support parse expr
          if (texpr != null) {
            def.ctorArgs.add( texpr )
          }
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
    while (deep > 0 && curt != Token.eof) {
      if (curt == Token.rbrace) --deep
      else if (curt == Token.lbrace) ++deep
      consume
    }
    return null
  }
  
  private Bool skipBracket(Bool brace := true) {
    success := false
    if (curt == Token.lparen) {
        consume
        deep := 1
        while (deep > 0 && curt != Token.eof) {
          if (curt == Token.rparen) --deep
          else if (curt == Token.lparen) ++deep
          consume
        }
        success = true
    }
    if (brace && curt == Token.lbrace) {
        consume
        deep := 1
        while (deep > 0 && curt != Token.eof) {
          if (curt == Token.rbrace) --deep
          else if (curt == Token.lbrace) ++deep
          consume
        }
        success = true
    }
    return success
  }
  
  private static Bool isExprValue(Token t) {
    switch (t) {
      case Token.identifier:
      case Token.intLiteral:
      case Token.strLiteral:
      case Token.durationLiteral:
      case Token.floatLiteral:
      case Token.trueKeyword:
      case Token.falseKeyword:
      case Token.thisKeyword:
      case Token.superKeyword:
      case Token.itKeyword:
      case Token.dsl:
      case Token.uriLiteral:
      case Token.decimalLiteral:
      case Token.nullKeyword:
        return true
    }
    return false
  }
  
  private static Bool isJoinToken(Token t) {
    switch (t) {
      case Token.dot://        ("."),
      case Token.colon://         (":"),
      case Token.doubleColon://   ("::"),
      case Token.plus://          ("+"),
      case Token.minus://         ("-"),
      case Token.star://          ("*"),
      case Token.slash://         ("/"),
      case Token.percent://       ("%"),
      case Token.pound://         ("#"),
      case Token.increment://     ("++"),
      case Token.decrement://     ("--"),
      case Token.isKeyword://,
      case Token.isnotKeyword://,
      case Token.asKeyword://,
      case Token.tilde://         ("~"),
      case Token.pipe://          ("|"),
      case Token.amp://           ("&"),
      case Token.caret://         ("^"),
      case Token.at://            ("@"),
      case Token.doublePipe://    ("||"),
      case Token.doubleAmp://     ("&&"),
      case Token.same://          ("==="),
      case Token.notSame://       ("!=="),
      case Token.eq://            ("=="),
      case Token.notEq://         ("!="),
      case Token.cmp://           ("<=>"),
      case Token.lt://            ("<"),
      case Token.ltEq://          ("<="),
      case Token.gt://            (">"),
      case Token.gtEq://          (">="),
      case Token.dotDot://        (".."),
      case Token.dotDotLt://      ("..<"),
      case Token.arrow://         ("->"),
      case Token.tildeArrow://    ("~>"),
      case Token.elvis://         ("?:"),
      case Token.safeDot://       ("?."),
      case Token.safeArrow://     ("?->"),
      case Token.safeTildeArrow://("?~>"),
        return true
    }
    return false
  }
  
  virtual Expr? expr() {
    while (curt != Token.eof) {
      if (isExprValue(curt)) {
        consume
        skipBracket
        if (isExprValue(curt)) break
        continue
      }
      
      if (isJoinToken(curt)) {
        consume
        if (skipBracket) {
          if (isExprValue(curt)) break
        }
        continue
      }
      break
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
      loc := cur.loc
      consume
      sInit := MethodDef.makeStaticInit(loc, parent, null)
      curSlot = sInit
      sInit.code = block
      curSlot = null
      return sInit
    }

    // all members start with facets, flags
    loc := cur.loc
    facets := facets()
    flags := flags()

    // check if this is a Java style constructor, log error and parse like Fantom sytle ctor
    if (curt === Token.identifier && cur.val == parent.name && peekt == Token.lparen)
    {
      err("Invalid constructor syntax - use new keyword")
      return methodDef(loc, parent, doc, facets, flags.or(FConst.Ctor), CType.voidType(loc), consumeId)
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
      returns := CType.voidType(loc)
      if (flags.and(FConst.Static) != 0) {
//        if (parent.isGeneric) {
//          TypeDef gp := parent.deref
//          params := gp.genericParameters
//          returns = ParameterizedType.create(parent, params)
//        }
        returns = parent.asRef()
      }
      return methodDef(loc, parent, doc, facets, flags, returns, name)
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
  private FieldDef fieldDef(Loc loc, TypeDef parent, DocDef? doc, FacetDef[]? facets, Int flags, CType? type, Str name)
  {
    // define field itself
    field := FieldDef(loc, parent)
    field.doc    = doc
    field.facets = facets
    field.flags  = flags
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

    // explicit getter or setter
    if (curt === Token.lbrace)
    {
      consume(Token.lbrace)
      getOrSet(field)
      getOrSet(field)
      consume(Token.rbrace)
    }

    endOfStmt
    endLoc(field)
    return field
  }

  static MethodDef defGet(FieldDef f)
  {
    // getter MethodDef
    loc := f.loc
    get := MethodDef(loc, f.parentDef)
    get.accessorFor = f
    get.flags = f.flags.or(FConst.Getter)
    get.name  = f.name
    get.ret   = f.fieldType
    f.get = get
    return get
  }

  static MethodDef defSet(FieldDef f)
  {
    // setter MethodDef
    loc := f.loc
    set := MethodDef(loc, f.parentDef)
    set.accessorFor = f
    set.flags = f.flags.or(FConst.Setter)
    set.name  = f.name
    set.ret   = CType.voidType(loc)
    set.params.add(ParamDef(loc, f.fieldType, "it"))
    f.set = set
    return set
  }

  private Void getOrSet(FieldDef f)
  {
    loc := cur.loc
    accessorFlags := flags()
    if (curt === Token.identifier)
    {
      // get or set
      idLoc := cur.loc
      id := consumeId

      if (id == "get") {
        defGet(f)
        curSlot = f.get
      }
      else {
        defSet(f)
        curSlot = f.set
      }
      // { ...block... }
      Block? block := null
      if (curt === Token.lbrace)
        block = this.block
      else
        endOfStmt
        
      endLoc(curSlot)

      // const field cannot have getter/setter
      if (f.isConst || f.isReadonly)
      {
        err("Const field '$f.name' cannot have ${id}ter", idLoc)
        //return
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
  private MethodDef methodDef(Loc loc, TypeDef parent, DocDef? doc, FacetDef[]? facets, Int flags, CType? ret, Str name)
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

    // if This is returned, then we configure inheritedRet
    // right off the bat (this is actual signature we will use)
    //if (ret.isThis) method.inheritedRet = parent.asRef

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
    }
    else {
        // ctor chain
        if ((flags.and(FConst.Ctor) != 0) && (curt === Token.colon))
          method.ctorChain = ctorChain(method);

        // body
        if (curt != Token.lbrace) {
          if (!parent.isNative) err("Expecting method body")
          //method.code = Block(loc)
        }
        else
          method.code = block
    }
    // exit scope
    curSlot = null
    endLoc(method)
    return method
  }

  private ParamDef paramDef()
  {
    param := ParamDef(cur.loc, typeRef, consumeId)
    if (curt === Token.defAssign || curt === Token.assign)
    {
      //if (curt === Token.assign) err("Must use := for parameter default");
      consume
      param.def = expr
    }
    endLoc(param)
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
      loc := cur.loc
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
          texpr := expr
          if (texpr != null)
            f.vals.add(texpr)
          endOfStmt
        }
        consume(Token.rbrace)
      }
      endLoc(f)
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
  protected CType typeRef()
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
  protected CType? tryType(Bool maybeCast := false)
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
      atype := ctype()
      if (curt === Token.identifier && !cur.newline) {
        //Int a
        type = atype
      }
      else if (curt === Token.pound) {
        //Int#
        type = atype
      }
      else if (curt === Token.dot && peekt === Token.superKeyword) {
        //Int.super
        type = atype
      }
      else if (curt === Token.dsl) {
        //Int<|..|>
        type = atype
      }
      else if (curt === Token.lbracket && !cur.newline
        //distinguish from slot[a]
        && atype.name[0].isUpper) {
        //Int[a, b]
        type = atype
      }
      else if (curt === Token.rparen && maybeCast &&
        (isExprValue(peekt) || peekt === Token.lparen) ) {
        //(Int)a
        type = atype
      }
      else if (this.tokens[pos>1?pos-1:0].kind == Token.gt) {
        //Int<X>
        type = atype
      }
      else if (atype.podName != "") {
        //sys::Int
        type = atype
      }
      else {
        //echo("is type? $atype")
      }
    }
    catch (CompilerErr e)
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
  protected CType ctype(Bool isTypeRef := false)
  {
    CType? t := null
    loc := cur.loc

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
        loc = consume(Token.lbracket).loc
        t = ctype(isTypeRef)
        // check for type?:type map (illegal)
        if (curt === Token.elvis && !cur.whitespace)
        {
          err("Map type cannot have nullable key type")
        }

        // check for ":" for map type
        if (curt === Token.colon)
        {
          if (t.isNullable) err("Map type cannot have nullable key type")
          consume(Token.colon)
          key := t
          val := ctype(isTypeRef)
          //throw err("temp test")
        //      t = MapType(key, val)
          t = CType.mapType(loc, key, val)
        }
        consume(Token.rbracket)
        //if (!(t is MapType)) err("Invalid map type", loc)
    }
    else if (curt === Token.pipe)
    {
      t = funcType(isTypeRef).typeRef
      if (curt === Token.lbrace) err("Expecting func type, not closure", loc)
    }
    else
    {
      e := err("Expecting type name not $cur", loc)
      if (curt == Token.eof) throw e
      consume
      t = CType.objType(loc)
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
      t = CType.listType(loc, valT)
      if (curt === Token.question && !cur.whitespace)
      {
        consume(Token.question)
        t = t.toNullable
      }
    }
    
    if (isTypeRef || t.name[0].isUpper) {
        // check for type?:type map (illegal)
        if (curt === Token.elvis && !cur.whitespace)
        {
          err("Map type cannot have nullable key type")
        }

        // check for ":" for map type
        if (curt === Token.colon)
        {
          if (t.isNullable) err("Map type cannot have nullable key type")
          consume(Token.colon)
          key := t
          val := ctype(isTypeRef)
          //throw err("temp test")
    //      t = MapType(key, val)
          t = CType.mapType(loc, key, val)
        }
    }

    // check for ? nullable
    if (curt === Token.question && !cur.whitespace)
    {
      consume(Token.question)
      t = t.toNullable
      if (curt === Token.question && !cur.whitespace)
        throw err("Type cannot have multiple '?'")
    }

    endLoc(t)
    return t
  }

  **
  ** Simple type signature:
  **   <simpleType>  :=  <id> ["::" <id>]
  **
  private CType simpleType(Bool allowDefaultParameterized := true)
  {
    loc := cur.loc
    id := consumeId

    CType? type
    // fully qualified
    if (curt === Token.doubleColon)
    {
      consume
//      return ResolveImports.resolveQualified(this, id, consumeId, loc) ?: ns.voidType
      type = CType.makeRef(loc, id, consumeId)
    }
    else {
      type = CType.makeRef(loc, null, id)
    }

    //generic param
    if (curt === Token.lt) {
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
      type.genericArgs = params
    }

    // got it
    endLoc(type)
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
  protected FuncTypeDef funcType(Bool isTypeRef)
  {
    params := CType[,]
    names  := Str[,]
    loc := cur.loc
    ret := CType.voidType(loc)

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

    ft := FuncTypeDef(loc, params, names, ret)
    ft.inferredSignature = inferred
    ft.unnamed = unnamed.first
    
    endLoc(ft)
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
      params.add(CType.objType(cur.loc).toNullable)
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
      loc := cur.loc
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
    if (loc == null) loc = cur.loc
    if (suppressErr) throw CompilerErr("SuppressedErr", loc)
    return log.err(msg, loc)
  }

//////////////////////////////////////////////////////////////////////////
// Tokens
//////////////////////////////////////////////////////////////////////////

  **
  ** Verify current is an identifier, consume it, and return it.
  **
  protected Str consumeId()
  {
    if (curt !== Token.identifier) {
      e := err("Expected identifier, not '$cur'", cur.loc)
      if (curt == Token.eof) throw e
      return ""
    }
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
  ** update loc.len field
  **
  protected Void endLoc(CNode node) {
    preToken := (pos>0)? tokens[pos-1] : cur
    lastEnd := preToken.loc.offset+preToken.len
    self := node.loc
    selfEnd := self.offset + node.len
    if (lastEnd == selfEnd) return
    if (lastEnd < selfEnd) return
    
    len := lastEnd-self.offset
    //loc := Loc.make(self.file, self.line, self.col, self.offset, lastEnd-self.offset)
    
    if (node is Node) {
      ((Node)node).len = len
    }
    else if (node is TypeDef) {
      ((TypeDef)node).len = len
    }
    else if (node is CType) {
      ((CType)node).len = len
    }
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
    err(errMsg, cur.loc)
    return false
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
  TokenVal[] tokens       // tokens all read in
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
//  protected Int? closureCount       // number of closures parsed inside curSlot
//  protected ClosureExpr[] closures  // list of all closures parsed
  protected Bool suppressErr := false    // throw SuppressedErr instead of CompilerErr
  
  CompilerLog log

}