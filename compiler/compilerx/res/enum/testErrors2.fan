mixin X { static Int vals() {} abstract Str foo(); }
enum class A { a; Void vals() {} }
enum class B : X { a, b }
enum class C { foo;  Str foo() { return null } }
enum class D : X { foo }
enum class E { a, b;  new myMake() {} }
enum class F { a, b;  new make() {}  new make2() {} }
enum class G { a, b;  new make() {} }
enum class H { a, b;  private new make(Int o, Str n) : super(o, n) {} }