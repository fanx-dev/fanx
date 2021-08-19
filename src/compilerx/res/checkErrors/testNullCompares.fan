class Foo
 {
   new make(Foo foo, |This| f)
   {
     if (s != null) return  // line 5 ok
     if (ni != null) return // line 6 ok
     if (j != null) return  // line 7 not ok
     if (this.f != null) return  // line 8 not ok
     if (foo.s != null) return  // line 9 not okay
     if (Env.cur.homeDir == null) return // 10 not okay
     x := s
     if (x != null) return // not okay
   }

   Void foo()
   {
     if (s != null) return // not okay
   }

   const Str s
   const Int? ni
   const Int j
   const Float f
 }