

internal const class FacetData {
  const Str val
  const Str type

  new make(Str type, Str val) {
    this.type = type
    this.val = val
  }
}

internal class FacetList {
  private FacetData[] facetsData := [,]
  private Facet[]? _facets

  Void addFacet(Str type, Str val) {
    facetsData.add(FacetData(type, val))
  }

  Facet[] facets() {
    if (_facets != null) return _facets

    _facets = [,]
    facetsData.each |f| {
      try {
        _facets.add(decode(f))
      }
      catch (Err e) {
        e.trace
      }
    }
    return _facets
  }

  private Facet decode(FacetData f) {
    t := Type.find(f.type)    
    // if no string use make/defVal
    if (f.val.size == 0) {
      return t.make();
    }
    
    // decode using normal Fantom serialization
    return ObjDecoder.decode(f.val);
  }

  Facet? getFacet(Type type, Bool checked := true) {
    res := _facets.find |f|{ f.typeof == type }
    if (checked && res == null) {
      throw UnknownFacetErr(type.qname)
    }
    return res
  }

  **
  ** Return if this type has the specified facet defined.
  **
  Bool hasFacet(Type type) {
    getFacet(type, false) != null
  }
}