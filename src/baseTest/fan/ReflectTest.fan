
class ReflectTest {
	Int a := 5

	Void foo(Int x) {
		echo(x)
		echo(a)
	}

	static Void main() {
		reflect
		testInvoke
	}

	static Void reflect() {
		i := 0
		echo(i.typeof)
		echo(i.typeof.methods)
	}

	static Void testInvoke() {
		m := ReflectTest()
		m->foo(3)
		m->a = 10
		m.foo(3)
	}
}
