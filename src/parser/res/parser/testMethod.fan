class Foo
{
new make() {}
new makeA() : this.make() {}
new makeB() : super() {}
new makeC() : super.makeX() {}
Void a() {}
static Void b(Int x) {}
internal Bool c(Int x, Str y) {}
static {}
}