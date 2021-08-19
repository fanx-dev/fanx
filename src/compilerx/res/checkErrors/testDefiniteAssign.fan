abstract class Foo : Bar
 {
   new make()
   {
     ok02 = s
   }

   new make2()
   {
     ok02 = bad01 = s
   }

   new make3() : this.make() {}

   Str bad01
   virtual Str bad02

   Str ok00 := s        // init
   Int ok01             // value type
   Str ok02             // in ctor
   abstract Str ok03    // abstract
   override Str ok04    // override
   Str ok05 { get { s } set { } } // calculated
   Str? ok06            // nullable

   const static Str s := "x"
   const static Bool b
   const static Str sBad01
   const static Str sBad02; static { if (b) sBad02 = s }
   const static Str sOk00 := s
   const static Str sOk01; static { if (b) sOk01 = s; else sOk01 = s }
 }

 class Bar
 {
   virtual Str ok04 := "ok"
 }