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
class TypeDef : CTypeDef
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  new make(Loc loc, CompilationUnit unit, Str name, Int flags := 0)
  {
    this.loc = loc
//    this.ns          = ns
    this.pod         = unit.pod
    this.unit        = unit
    this.name        = name
    this.qname       = pod.name + "::" + name
    this.flags       = flags
    //this.isVal       = CType.isValType(qname)
    this.inheritances  = CType[,]
    this.enumDefs    = EnumDef[,]
//    this.slotMap     = Str:CSlot[:]
//    this.slotDefMap  = Str:SlotDef[:]
    this.slotDefList = SlotDef[,]
    this.closures    = ClosureExpr[,]
  }

  
  override Loc loc
  override Int flags
  override DocDef? doc
  override CFacet[]? facets
  
  Void addFacet(CType type, [Str:Obj]? vals := null)
  {
    if (facets == null) facets = FacetDef[,]
    loc := this.loc
    f := FacetDef(loc, type)
    vals?.each |v, n|
    {
      f.names.add(n)
      f.vals.add(Expr.makeForLiteral(loc, v))
    }
    facets.add(f)
  }
  
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
  ** Add a slot to the type definition.  The method is used to add
  ** SlotDefs declared by this type as well as slots inherited by
  ** this type.
  **
  Void addSlot(SlotDef s, Int? slotDefIndex := null)
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

      if (m.isOverload) {
        slotDefList.add(m)
        return
      }
    }

    // sanity check
    name := s.name
//    if (slotDefMap.containsKey(name))
//      throw Err("Internal error: duplicate slot $name [$loc.toLocStr]")

    // if my own SlotDef
    def := s as SlotDef
    if (def != null && def.parent === this)
    {
      // add to my slot definitions
      if (slotDefMapCache != null)
        slotDefMapCache[name] = def
      
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

//  **
//  ** Replace oldSlot with newSlot in my slot tables.
//  **
//  Void replaceSlot(SlotDef oldSlot, SlotDef newSlot)
//  {
//    // sanity checks
//    if (oldSlot.name != newSlot.name)
//      throw Err("Internal error: not same names: $oldSlot != $newSlot [$loc.toLocStr]")
//    if (slotMap[oldSlot.name] !== oldSlot)
//      throw Err("Internal error: old slot not mapped: $oldSlot [$loc.toLocStr]")
//
//    // remap in slotMap table
//    name := oldSlot.name
//    slotMap[name] = newSlot
//
//    // if old is SlotDef
//    oldDef := oldSlot as SlotDef
//    if (oldDef != null && oldDef.parent === this)
//    {
//      slotDefMap[name] = oldDef
//      slotDefList.remove(oldDef)
//    }
//
//    // if new is SlotDef
//    newDef := newSlot as SlotDef
//    if (newDef != null && newDef.parent === this)
//    {
//      slotDefMap[name] = newDef
//      slotDefList.add(newDef)
//    }
//  }

  **
  ** Get static initializer if one is defined.
  **
  MethodDef? staticInit()
  {
    return slots["static\$init"]
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
//    slotMap[m.name] = m
//    slotDefMap[m.name] = m
    slotDefList.add(m)
  }

//////////////////////////////////////////////////////////////////////////
// SlotDefs
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the SlotDefs declared within this TypeDef.
  **
  override SlotDef[] slotDefs()
  {
    return slotDefList
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
  
  override Void getChildren(CNode[] list, [Str:Obj]? options) {
    if (facets != null) {
      facets.each |FacetDef f| {
        list.add(f)
      }
    }
    
    this.inheritances.each |t| {
      list.add(t)
    }
    
    slotDefs.each |slot| {
      if (slot.isSynthetic) return
      list.add(slot)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Debug
//////////////////////////////////////////////////////////////////////////

  override Void print(AstWriter out)
  {
    super.print(out)
    
    if (isMixin)
      out.w("mixin $name")
    else if (isEnum)
      out.w("enum $name")
    else
      out.w("class $name")

//    if (base != null || !mixins.isEmpty)
//    {
//      out.w(" : ")
//      if (base != null) out.w(" $base")
//      if (!mixins.isEmpty) out.w(", ").w(mixins.join(", ")).nl
//    }
    if (!inheritances.isEmpty) out.w(" : ").w(inheritances.join(", ")).nl
    else out.nl

    out.w("{").nl
    out.indent
    enumDefs.each |EnumDef e| { e.print(out) }
    slotDefs.each |SlotDef s| { s.print(out) }
    out.unindent
    out.w("}").nl
  }
  
  override GenericParamDef[] genericParameters := [,]
  
  Void setBase(CType base) {
    if (inheritances.size > 0) inheritances[0] = base
    else inheritances.add(base)
  }
  
//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

//  override CNamespace ns           // compiler's namespace
  CompilationUnit unit             // parent unit
  override PodDef pod                // parent pod
  override const Str name          // simple class name
  override const Str qname         // podName::name
  //override const Bool isVal        // is this a value type (Bool, Int, etc)
  Bool baseSpecified := true       // was base assigned from source code
//  TypeRef? base             // extends class
//  TypeRef[] mixins          // mixin types
  
  override CType[] inheritances
  
  EnumDef[] enumDefs               // declared enumerated pairs (only if enum)
  ClosureExpr[] closures           // closures where I am enclosing type (Parse)
  ClosureExpr? closure             // if I am a closure anonymous class
  private SlotDef[] slotDefList    // declared slot definitions
  FacetDef[]? indexedFacets        // used by WritePod
}