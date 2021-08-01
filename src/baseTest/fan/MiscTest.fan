
class MiscTest {
	static Void main() {
		testCast
		testBoxing
	}

	static Void testCast() {
		Int? i := null
		Obj? obj := i
		Str? s := obj

		StrBuf? castNull := (StrBuf?)obj
		Bool isInstanceOf := i is Int?

		echo(castNull)
		echo(isInstanceOf)
	}

	static Void testBoxing() {
		Int a := 1
		echo(a.toStr)

		Int? b := 2
		echo(b.toStr)

		c := a + b
		echo(c)

		d := b + a
		echo(d)
	}
}
