virtual class A
 {
   new ctor() { return }
   Bool a() { return false }
   virtual Bool b() { return false }
   virtual Bool c() { return false }
   virtual Void d(Bool b) { }
   private Void e() {}
   virtual Int f () { return 9 }
   Bool g
   virtual Int h
   abstract Bool i
   virtual Int j
   virtual Void k() {}
 }

 class B : A
 {
   static B ctor() { return null } // ok
   Bool a() { return true }
   Bool b() { return true }
   override Int c() { return 0 }
   override Void d(Bool b, Int x) { }
   private Void e_(Int x, Int y) {} // ok
   override Str f
   override Str g
   Int h
   override Str i
   override final Int j
   override final Void k() {}
 }

 class C : B
 {
   override Int j
   override Void k() {}
 }

 class SubOut : OutStream
 {
   override Void close() { }
   This flush() { this }
   override This write() { return this }
   override This writeBool(Bool x) { return this }
 }

 mixin ConflictX
 {
   static Void a() {}
   virtual Int b() { return 3 }
   virtual Void c(Str q) { }
   virtual Void d(Str q) { }
 }
 mixin ConflictY
 {
   static Void a() {}
   virtual Bool b() { return true }
   virtual Void c(Str q, Int p) { }
   virtual Void d(Int q) { }
 }
 class Conflict : ConflictX, ConflictY {}

 mixin WhichX { virtual Str name() { return null } }
 mixin WhichY { virtual Str name() { return null } }
 class Which : WhichX, WhichY {}

 class Ouch
 {
   override Bool isImmutable() { return true }
   override Void figgle() {}
   override Str foogle
   virtual Obj returnObj() { return null }
   virtual Void returnVoid() {}
 }

 class SubOuch : Ouch
 {
   override Void returnObj() {}
   override Obj returnVoid() { return null }
 }