class Foo
{
static Obj m03() { if (0) return 1; return 2; }
static Obj m04() { throw 3 }
static Str m05() { return 6 }
static Obj m06() { for (;"x";) m03(); return 2 }
static Obj m07() { while ("x") m03(); return 2 }
static Void m08() { break; continue }
static Void m09() { Str x := 4.0f }
static Void m10() { try { m03 } catch (Str x) {} }
static Void m11() { try { m03 } catch (IOErr x) {} catch (IOErr x) {} }
static Void m12() { try { m03 } catch (Err x) {} catch (IOErr x) {} }
static Void m13() { try { m03 } catch (Err x) {} catch {} }
static Void m14() { try { m03 } catch {} catch {} }
static Void m15() { switch (Weekday.sun) { case 4: return } }
static Void m16() { switch (2) { case 0: case 0: return } }
static Void m17() { switch (Weekday.sun) { case Weekday.sun: return; case Weekday.sun: return } }

static Void m19() { try { return } finally { return } }
static Int m20() { try { return 1 } finally { return 2 } }
static Obj m21() { try { try { return m03 } finally { return 8 } } finally { return 9 } }
static Obj m22() { try { try { return m03 } finally { return 8 } } finally {} }
static Obj m23() { try { try { return m03 } finally { } } finally { return 9 } }
static Void m24() { while (true) { try { echo(3) } finally { break } } }
static Void m25() { while (true) { try { echo(3) } finally { continue } } }
static Void m26() { for (;;) { try { try { m03 } finally { break } } finally { continue } } }

static Void m28() { try { } catch {} }

Void m30() { return 6 }
Obj m31() { return }
Obj m32(Bool b) { if (b) return; else return }

Obj m34(Obj? x) { x ?: throw "x" }
}