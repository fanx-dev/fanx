//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Sep 05  Brian Frank  Creation
//    3 Jun 06  Brian Frank  Ported from Java to Fantom - Megan's b-day!
//

**
** CompilationUnit models the top level compilation unit of a source file.
**
class CompilationUnit : Node
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  new make(Loc loc, CPod pod)
    : super(loc)
  {
    this.pod    = pod
    this.usings = Using[,]
    this.types  = TypeDef[,]
  }

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  override Void print(AstWriter out)
  {
    out.nl
    usings.each |Using u| { u.print(out) }
    types.each |TypeDef t| { t.print(out) }
  }

  override Str toStr()
  {
    return loc.toStr
  }

  // get all imported extendsion methods
  //TODO: optimize to map
  once CMethod[] extensionMethods() {
    meths := CMethod[,]
    importedTypes.each |types|{
      types.each |type| {
        type.methods.each |m| {
          if (m.isStatic && (m.flags.and(FConst.Extension) != 0)) {
             meths.add(m)
          }
        }
      }
    }
    return meths
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  CPod pod                      // ctor
  TokenVal[]? tokens            // Tokenize
  Using[] usings                // ScanForUsingsAndTypes
  TypeDef[] types               // ScanForUsingsAndTypes + CompilerSupport.addTypeDef
  [Str:CType[]]? importedTypes  // ResolveImports (includes my pod)

}