class Foo { Obj test() { list := [[30:1],[20:2],[10:3]];
 return list.max |Map a, Map b->Int| { a.vals[0] <=> b.vals[0] } } }