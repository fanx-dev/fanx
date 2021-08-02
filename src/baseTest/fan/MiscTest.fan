
class MiscTest {
	static Void main() {
		testCast
		testBoxing
		testMap
		testStrBuf
		testStrBuf2
		testStackTrace
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

	static Void testMap() {
		map := [:]
		map["a"] = 1
		//map["b"] = 2

		echo(map)
	}

	static Void testStrBuf() {
		buf := StrBuf()
		buf.addChar('a')
		buf.addChar('b')

		i1 := buf[0]
		assert(i1 == 'a')
		i2 := buf[1]
		assert(i2 == 'b')

		str := buf.toStr
		assert(str == "ab")
	}

	static Void testStrBuf2() {
		a := "sys"
		b := [,]
		echo("addPod:$a $b")
	}

	static Void testStackTrace() {
		Err().trace
	}
}
