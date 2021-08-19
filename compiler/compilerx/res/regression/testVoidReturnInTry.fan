class Foo
 {
   Void a1() { return foo("a1") }

   Void a2() { bar("a2") }

   Void b1(Bool raise)
   {
     try
     {
       if (raise) throw Err()
       return foo("b1-try")
     }
     catch (Err e) return foo("b1-catch")
   }

   Void b2(Bool raise)
   {
     try
     {
       if (raise) throw Err()
       bar("b2-try")
       return
     }
     catch (Err e) { bar("b2-catch"); return }
   }

   Void c1(Bool raise)
   {
     try
     {
       if (raise) throw Err()
       return foo("c1-try")
     }
     catch (Err e) return foo("c1-catch")
     finally foo(" c1-finally")
   }

   Void c2(Bool raise)
   {
     try
     {
       if (raise) throw Err()
       bar("c2-try")
       return
     }
     catch (Err e) {bar("c2-catch"); return}
     finally bar(" c2-finally")
   }

   Void foo(Str r) { this.r += r }
   Str bar(Str r)  { this.r += r }
   Str r := ""
 }