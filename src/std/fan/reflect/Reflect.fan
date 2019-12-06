

native internal rtconst class Reflect {
  private Pod[] podList := [,]
  private [Str:Pod] podMap := [:]

  private const static Reflect cur := Reflect()

  new make() {}

  static Pod[] listPod() { Reflect.cur.podList }

  static Pod? findPod(Str name, Bool checked := true) {
    Reflect.cur.podMap.getChecked(name, checked)
  }
/*
  ** call in native
  internal static Type register(Ptr pod, Ptr typeName, Ptr signature, Int flags,
      Ptr baseStr, Ptr mixinArray, Int mixinLen) {
    base := find(Str.fromCStr(baseStr), false)
    mixins := Type[,]
    for (i:=0; i<mixinLen; ++i) {
      mix := mixinArray.get(i)
      mixins.add(find(Str.fromCStr(mix)))
    }

    //Pod pod, Str name, Str signature, Int flags, Type? base, Type[] mixins,Slot[] slots, Facet[] facets
    type := BaseType.privateMake(Str.fromCStr(pod), Str.fromCStr(typeName), Str.fromCStr(signature),
      flags, base, mixins)
    return type
  }
*/
}
