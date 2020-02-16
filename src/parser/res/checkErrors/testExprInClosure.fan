class Foo                                                // 1
{                                                        // 2
Void m00a() { |->| { x := this.make }.call }           // 3
Void m00b() { |->| { |->| { x := this.make }.call }.call } // 4
Void m01a() { |->| { this.m02a }.call }                // 5
Void m01b() { |->| { |->| { this.m02a }.call }.call }  // 6
static Void m02a() { |->| { m00a; Foo.m00a() }.call }  // 7
static Void m02b() { |->| { |->| { m00a; Foo.m00a() }.call }.call } // 8
Void m03a(Str x) { |->| { this.sf.size }.call }        // 9
Void m03b(Str x) { |->| { |->| { this.sf.size }.call }.call } // 10
static Void m04a(Str x) { |->| { f.size; Foo.f.size }.call }
static Void m04b(Str x) { |->| { |->| { f.size; Foo.f.size }.call }.call }

Str? f
const static Str? sf
}