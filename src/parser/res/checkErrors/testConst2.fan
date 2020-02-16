virtual const class Foo : Bar
{
  static Int a := 3

  const static Int b := 3
  static { b = 5 }
  static Void goop() { b = 7; b += 3; b++ }

  //const static Int c { get { return 3 } }
  //const static Int d { set {  } }  // 10
  //const static Int e { get { return 3 } set { } }

  const Int f := 3
  new make() { f = 5 }
  Void wow() { f = 7; f++; }
  static Void bow(Foo o) { o.f = 9; o.f += 2 }

  //const Int g { get { return 3 } }
  //const Int h { set {  } }
  //const Int i { get { return 3 } set { } } // 20

  private Str? j
  private const StrBuf? k
  const Buf[]? l              // ok
  const [Str:Buf]? m          // ok
  const [Buf:Int]? n          // ok
  const [Num:Duration]? ok1   // ok
  const [Num:Str[][]]? ok2    // ok

  once Int p() { return 3 }  // 30
}

virtual class Bar {}
class Roo : Foo {}
enum class Boo { none;  private Int x }

const class Outside : Foo
{
  Void something() { f = 99 }
  static { b++ }  // 40
}

class With
{
  static Foo fooFactory() { return Foo.make }
  static With withFactory() { return make }
  Obj a() { return Foo { it.f = 99 } }              // ok
  Obj b() { return Foo.make { it.f = 99 } }         // ok
  Obj c() { return With { it.xxx = [1,2] } }        // ok
  Obj d() { return make { it.xxx = [1,2] } }        // ok  line 50
  Obj e() { return fooFactory { it.f = 99 } }       // ok it-block
  Obj f() { return withFactory { it.xxx = [1,2] } } // ok it-block
  Obj g() { return make { it.xxx = [1,2] } }        // ok it-block
  Obj h(With s) { return s { it.xxx = [1,2] } }     // ok it-block
  Obj i() { return this { it.xxx = [1,2] } }        // ok it-block
  Obj j() { return make { it.goop = 99 } }
  static { Foo.b = 999 }

  const Int[] xxx := Int[,]
  static const Int goop := 9
}

const abstract class Ok
{
  abstract Int a
  native Str b
  Int c { get { return 3 } set {} }
  static const Obj? d
  static const Obj[]? e
  static const [Obj:Obj]? f
}