using concurrent
class Foo
{
  |->| c1 := |->| { s=\"c1\" };
  |Str x| c2 := |Str x| { s=x };
  |Str x| c3 := |Str x| { sets(x) };
  |Str x| c4 := |Str x| { this.sets(x) };
  //static const |->| sc1 := |->| { Actor.locals[\"testCompiler.closure\"] = \"sc1\" }
  //static const |Str x| sc2 := |Str x| { Actor.locals[\"testCompiler.closure\"] = x }
  Void sets(Str x) { s = x }
  Str? s
}