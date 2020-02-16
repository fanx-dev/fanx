class B : A
{
override public    Void a1() {} // ok
override protected Void a2() {}
override internal  Void a3() {}
override private   Void a4() {}

override public    Void b1() {} // ok
override protected Void b2() {} // ok
override internal  Void b3() {}
override private   Void b4() {}

override public    Void c1() {} // ok
override protected Void c2() {}
override internal  Void c3() {} // ok
override private   Void c4() {}

override public Void d() {}  // unknown
}

class A
{
virtual public Void a1() {}
virtual public Void a2() {}
virtual public Void a3() {}
virtual public Void a4() {}

virtual protected Void b1() {}
virtual protected Void b2() {}
virtual protected Void b3() {}
virtual protected Void b4() {}

virtual internal Void c1() {}
virtual internal Void c2() {}
virtual internal Void c3() {}
virtual internal Void c4() {}

private Void d() {}
}