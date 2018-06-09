//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   3 Feb 10   Brian Frank  Creation
//

@Js facet class FacetM1 {}
@Js facet class FacetM2 {}

@Js facet class FacetS1
{
  const Str val := "alpha"
}

@Js facet class FacetS2
{
  const Bool b
  const Int i
  const Str? s
  const Version? v
  const Int[]? l
  const Type? type
  const Slot? slot
}