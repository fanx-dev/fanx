

class FuncTest {

  const Str id

  new make() {
    id = "x"
  }

  new makeFunc(|This| f) {
    f(this)
  }

  Void fooR(Func f) {
    |FuncTest,Int| ff := f
    ff(this, 2)
  }

  Void fooV(|FuncTest t, Int i| f) {
    f(this, 2)
  }

  Void foo(|FuncTest t, Int i->Str| f) {
    x := f(this, 2)
    echo(x)
  }

  static Void testCallMake() {
    ins1 := FuncTest.makeFunc { id = "hi" }
    //ins2 := FuncTest.makeFunc { ins1.id = "hi" }
  }

  Void testArgsReduce() {
    foo |t| {
      return "$t"
    }
  }

  Void testCaputreVars() {
    i := 0
    foo |t| {
      i += 1
      return "$t, $i"
    }
  }
}