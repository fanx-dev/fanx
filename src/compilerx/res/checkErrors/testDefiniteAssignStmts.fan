abstract class Foo
 {
   new m01() // ok
   {
     try { x = s } catch (IOErr e) { x = s } catch (CastErr e) { x = s }
   }

   new m02() // not ok
   {
     try { x = s } catch (IOErr e) { foo } catch (CastErr e) { x = s }
   }

   new m03() // not ok
   {
     try { foo }  catch (IOErr e) { foo }
   }

   new m04() { if (foo) x = s; else x = s } // ok

   new m05() { if (foo) x = s; else foo } // not ok

   new m06() { foo(x = s) } // ok

   new m07() { while (foo) x = s } // not-ok

   new m08() { while ((x = s).isEmpty) foo } // ok

   new m09(Int i)  // ok
   {
     switch(i) { case 0: x = s; default: x = s; }
   }

   new m10(Int i)  // not-ok
   {
     switch(i) { case 0: x = s; case 1: x = s; }
   }

   new m11(Int i)  // not-ok
   {
     switch(i) { case 0: x = s; default: foo; }
   }

   new m12(Int i)  // not-ok
   {
     switch(i) { case 0: x = s; case 1: foo; default: x = s; }
   }

   new m13() // ok
   {
     try { x = s } catch (IOErr e) { throw e }
   }

   new m14(Int v) // ok
   {
     if (v == 0) x = ""
     else throw Err()
   }

   static Bool foo(Str y := s) { false }
   const static Str s := "x"
   Str x
 }

 class Bar
 {
   virtual Str ok04 := "ok"
 }
 