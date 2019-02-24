
class CheckedDynamicTest {

  Int foo(Str bar) {
  	echo(bar)
  	return bar.toInt
  }

  Void main() {
    //foo(bar:"hi")
    Int i := this~>foo("0")
    echo(i+1)
  }
}