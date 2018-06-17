//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Sep 05  Brian Frank  Creation
//    3 Jun 06  Brian Frank  Ported from Java to Fantom - Megan's b-day!
//

**
** TypeDef models a type definition for a class, mixin or enum
**
class TypeDef : DefNode, CType
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  new make(CNamespace ns, Loc loc, CompilationUnit unit, Str name, Int flags := 0)
    : super(loc)
  {
    this.ns          = ns
    this.pod         = unit.pod
    this.unit        = unit
    this.name        = name
    this.qname       = pod.name + "::" + name
    this.flags       = flags
    //this.isVal       = CType.isValType(qname)
    this.mixins      = CType[,]
    this.enumDefs    = EnumDef[,]
    this.slotMap     = Str:CSlot[:]
    this.slotDefMap  = Str:SlotDef[:]
    this.slotDefList = SlotDef[,]
    this.closures    = ClosureExpr[,]
  }

//////////////////////////////////////////////////////////////////////////
// CType
//////////////////////////////////////////////////////////////////////////

  //override Str signature() { qname }
  override Str extName()   { "" }

  override Bool isNullable() { false }
  override once CType toNullable() { NullableType(this) }

  override Bool isGeneric := false
  override Bool isParameterized() { false }
  override Bool hasGenericParameter() { false }

  override once CType toListOf() { ListType(this) }

//////////////////////////////////////////////////////////////////////////
// Access
//////////////////////////////////////////////////////////////////////////

  **
  ** Return if this type is the anonymous class of a closure
  **
  Bool isClosure()
  {
    return closure != null
  }

//////////////////////////////////////////////////////////////////////////
// Slots
//////////////////////////////////////////////////////////////////////////

  **
  ** Return all the all slots (inherited and defined)
  **
  override Str:CSlot slots() { slotMap }

  **
  ** Cached COperators map
  **
  override once COperators operators() { COperators(this) }

  **
  ** Add a slot to the type definition.  The method is used to add
  ** SlotDefs declared by this type as well as slots inherited by
  ** this type.
  **
  Void addSlot(CSlot s, Int? slotDefIndex := null)
  {
    // if MethodDef
    m := s as MethodDef
    if (m != null)
    {
      // static initializes are just temporarily added to the
      // slotDefList but never into the name map - we just need
      // to keep them in declared order until they get collapsed
      // and removed in the Normalize step
      if (m.isStaticInit)
      {
        slotDefList.add(m)
        return
      }

      // field accessors are added only to slotDefList,
      // name lookup is always the field itself
      if (m.isFieldAccessor)
      {
        slotDefList.add(m)
        return
      }
    }

    // sanity check
    name := s.name
    if (hasSlot(name))
      throw Err("Internal error: duplicate slot $name [$loc.toLocStr]")

    // add to all slots table
    slotMap[name] = s

    // if my own SlotDef
    def := s as SlotDef
    if (def != null && def.parent === this)
    {
      // add to my slot definitions
      slotDefMap[name] = def
      if (slotDefIndex == null)
        slotDefList.add(def)
      else
        slotDefList.insert(slotDefIndex, def)

      // if non-const FieldDef, then add getter/setter methods
      if (s is FieldDef)
      {
        f := (FieldDef)s
        if (f.get != null) addSlot(f.get)
        if (f.set != null) addSlot(f.set)
      }
    }
  }

  **
  ** Replace oldSlot with newSlot in my slot tables.
  **
  Void replaceSlot(CSlot oldSlot, CSlot newSlot)
  {
    // sanity checks
    if (oldSlot.name != newSlot.name)
      throw Err("Internal error: not same names: $oldSlot != $newSlot [$loc.toLocStr]")
    if (slotMap[oldSlot.name] !== oldSlot)
      throw Err("Internal error: old slot not mapped: $oldSlot [$loc.toLocStr]")

    // remap in slotMap table
    name := oldSlot.name
    slotMap[name] = newSlot

    // if old is SlotDef
    oldDef := oldSlot as SlotDef
    if (oldDef != null && oldDef.parent === this)
    {
      slotDefMap[name] = oldDef
      slotDefList.remove(oldDef)
    }

    // if new is SlotDef
    newDef := newSlot as SlotDef
    if (newDef != null && newDef.parent === this)
    {
      slotDefMap[name] = newDef
      slotDefList.add(newDef)
    }
  }

  **
  ** Get static initializer if one is defined.
  **
  MethodDef? staticInit()
  {
    return slotDefMap["static\$init"]
  }

  **
  ** If during parse we added any static initializer methods,
  ** now is the time to remove them all and replace them with a
  ** single collapsed MethodDef (processed in Normalize step)
  **
  Void normalizeStaticInits(MethodDef m)
  {
    // remove any temps we had in slotDefList
    slotDefList = slotDefList.exclude |SlotDef s->Bool|
    {
      return MethodDef.isNameStaticInit(s.name)
    }

    // fix enclosingSlot of closures used in those temp statics
    closures.each |ClosureExpr c|
    {
      if (c.enclosingSlot is MethodDef && ((MethodDef)c.enclosingSlot).isStaticInit)
        c.enclosingSlot = m
    }

    // now we add into all slot tables
    slotMap[m.name] = m
    slotDefMap[m.name] = m
    slotDefList.add(m)
  }

//////////////////////////////////////////////////////////////////////////
// SlotDefs
//////////////////////////////////////////////////////////////////////////

  **
  ** Return if this class has a slot definition for specified name.
  **
  Bool hasSlotDef(Str name)
  {
    return slotDefMap.containsKey(name)
  }

  **
  ** Return SlotDef for specified name or null.
  **
  SlotDef? slotDef(Str name)
  {
    return slotDefMap[name]
  }

  **
  ** Return FieldDef for specified name or null.
  **
  FieldDef? fieldDef (Str name)
  {
    return (FieldDef)slotDefMap[name]
  }

  **
  ** Return MethodDef for specified name or null.
  **
  MethodDef? methodDef(Str name)
  {
    return (MethodDef)slotDefMap[name]
  }

  **
  ** Get the SlotDefs declared within this TypeDef.
  **
  SlotDef[] slotDefs()
  {
    return slotDefList
  }

  **
  ** Get the FieldDefs declared within this TypeDef.
  **
  FieldDef[] fieldDefs()
  {
    return (FieldDef[])slotDefList.findType(FieldDef#)
  }

  **
  ** Get the static FieldDefs declared within this TypeDef.
  **
  FieldDef[] staticFieldDefs()
  {
    return fieldDefs.findAll |FieldDef f->Bool| { f.isStatic }
  }

  **
  ** Get the instance FieldDefs declared within this TypeDef.
  **
  FieldDef[] instanceFieldDefs()
  {
    return fieldDefs.findAll |FieldDef f->Bool| { !f.isStatic }
  }

  **
  ** Get the MethodDefs declared within this TypeDef.
  **
  MethodDef[] methodDefs()
  {
    return (MethodDef[])slotDefList.findType(MethodDef#)
  }

  **
  ** Get the constructor MethodDefs declared within this TypeDef.
  **
  MethodDef[] ctorDefs()
  {
    return methodDefs.findAll |MethodDef m->Bool| { m.isCtor }
  }

//////////////////////////////////////////////////////////////////////////
// Enum
//////////////////////////////////////////////////////////////////////////

  **
  ** Return EnumDef for specified name or null.
  **
  public EnumDef? enumDef(Str name)
  {
    return enumDefs.find |EnumDef def->Bool| { def.name == name }
  }

//////////////////////////////////////////////////////////////////////////
// Tree
//////////////////////////////////////////////////////////////////////////

  Void walk(Visitor v, VisitDepth depth)
  {
    v.enterUnit(unit)
    v.enterTypeDef(this)
    walkFacets(v, depth)
    if (depth >= VisitDepth.slotDef)
    {
      slotDefs.each |SlotDef slot| { slot.walk(v, depth) }
    }
    v.visitTypeDef(this)
    v.exitTypeDef(this)
    v.exitUnit(unit)
  }

//////////////////////////////////////////////////////////////////////////
// Debug
//////////////////////////////////////////////////////////////////////////

  override Void print(AstWriter out)
  {
    out.nl
    printFacets(out)
    if (isMixin)
      out.w("mixin $qname").nl
    else if (isEnum)
      out.w("enum $qname").nl
    else
      out.w("class $qname").nl

    if (base != null || !mixins.isEmpty)
    {
      out.w(" : ")
      if (base != null) out.w(" $base")
      if (!mixins.isEmpty) out.w(", ").w(mixins.join(", ")).nl
    }

    out.w("{").nl
    out.indent
    enumDefs.each |EnumDef e| { e.print(out) }
    slotDefs.each |SlotDef s| { s.print(out) }
    out.unindent
    out.w("}").nl
  }

  override GenericParamType? getGenericParamType(Str name) {
    param := genericParameters.find { it.paramName == name }
    if (param != null) {
      return param
    }
    return null
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  override CNamespace ns           // compiler's namespace
  CompilationUnit unit             // parent unit
  override CPod pod                // parent pod
  override const Str name          // simple class name
  override const Str qname         // podName::name
  //override const Bool isVal        // is this a value type (Bool, Int, etc)
  Bool baseSpecified := true       // was base assigned from source code
  override CType? base             // extends class
  override CType[] mixins          // mixin types
  EnumDef[] enumDefs               // declared enumerated pairs (only if enum)
  ClosureExpr[] closures           // closures where I am enclosing type (Parse)
  ClosureExpr? closure             // if I am a closure anonymous class
  private Str:CSlot slotMap        // all slots
  private Str:SlotDef slotDefMap   // declared slot definitions
  private SlotDef[] slotDefList    // declared slot definitions
  FacetDef[]? indexedFacets        // used by WritePod

  //genericParameter
  GenericParamType[] genericParameters := [,]
}