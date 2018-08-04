//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   12 Feb 10  Brian Frank  Creation
//

**
** AtomicTest
**
@Js
class AtomicTest : Test
{

  Void testBool()
  {
    // constructors
    verifyEq(AtomicBool().val, false)
    verifyEq(AtomicBool(true).val, true)

    // val
    a := AtomicBool()
    verifyEq(a.val, false)
    a.val = true
    verifyEq(a.val, true)

    // getAndSet
    verifyEq(a.getAndSet(false), true)
    verifyEq(a.val, false)

    // compareAndSet
    verifyEq(a.compareAndSet(true, true), false)
    verifyEq(a.val, false)
    verifyEq(a.compareAndSet(false, true), true)
    verifyEq(a.val, true)

    // toStr
    verifyEq(AtomicBool(true).toStr, "true")
  }

  Void testInt()
  {
    // constructors
    verifyEq(AtomicInt().val, 0)
    verifyEq(AtomicInt(-55).val, -55)

    // val field
    a := AtomicInt()
    verifyEq(a.val, 0)
    a.val = 0xabcd_01234_ddee
    verifyEq(a.val, 0xabcd_01234_ddee)

    // getAndSet
    verifyEq(a.getAndSet(1972), 0xabcd_01234_ddee)
    verifyEq(a.val, 1972)

    // compareAndSet
    verifyEq(a.compareAndSet(1973, 3), false)
    verifyEq(a.val, 1972)
    verifyEq(a.compareAndSet(1972, 3), true)
    verifyEq(a.val, 3)

    // increment/decrement
    verifyEq(a.getAndIncrement, 3); verifyEq(a.val, 4)
    verifyEq(a.incrementAndGet, 5); verifyEq(a.val, 5)
    verifyEq(a.addAndGet(3),    8); verifyEq(a.val, 8)
    verifyEq(a.getAndAdd(-3),   8); verifyEq(a.val, 5)
    verifyEq(a.decrementAndGet, 4); verifyEq(a.val, 4)
    verifyEq(a.getAndDecrement, 4); verifyEq(a.val, 3)

    a.increment; verifyEq(a.val, 4)
    a.increment; verifyEq(a.val, 5)
    a.add(4);    verifyEq(a.val, 9)
    a.decrement; verifyEq(a.val, 8)

    // toStr
    verifyEq(AtomicInt(-1234).toStr, "-1234")
  }

  Void testRef()
  {
    // constructors
    verifyEq(AtomicRef().val, null)
    verifySame(AtomicRef("foo").val, "foo")
    verifyErr(NotImmutableErr#) { x := AtomicRef(this) }

    // val field
    a := AtomicRef("foo")
    verifySame(a.val, "foo")
    dt := DateTime.now
    a.val = dt
    verifySame(a.val, dt)
    a.val = null
    verifyEq(a.val, null)
    verifyErr(NotImmutableErr#) { a.val = Env.cur.out }
    verifyEq(a.val, null)

    // getAndSet
    verifyEq(a.getAndSet(dt), null)
    ver := Version("2.0")
    verifySame(a.getAndSet(ver), dt)
    verifySame(a.val, ver)
    verifyErr(NotImmutableErr#) { a.getAndSet(this) }
    verifySame(a.val, ver)

    // compareAndSet
    num := 99
    verifyEq(a.compareAndSet(num, num), false)
    verifySame(a.val, ver)
    verifyEq(a.compareAndSet(ver, num), true)
    verifySame(a.val, num)
    verifyEq(a.compareAndSet(null, null), false)
    verifyErr(NotImmutableErr#) { a.compareAndSet(num, this) }
    verifySame(a.val, num)
    verifyEq(a.compareAndSet(num, null), true)
    verifyEq(a.val, null)
    verifyEq(a.compareAndSet("x", "x"), false)
    verifyEq(a.val, null)
    verifyEq(a.compareAndSet(null, "x"), true)
    verifySame(a.val, "x")

    // toStr
    verifyEq(AtomicRef("foo").toStr, "foo")
  }

}