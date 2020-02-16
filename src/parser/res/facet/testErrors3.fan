@sys::Js @Js @NoDoc @NoDoc class Bar {}
class Foo
{
  @Transient @sys::Transient Int a
  @Str[] Int b
  @Foo Int c
  @A { a = 4; xyz = 5 } Int d
  @A { b = null } Int e
 }

facet class A
{
  const Str a := ""
  const Obj b := ""
}