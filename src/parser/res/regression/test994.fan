class Foo {
 Str? x() { echo(3).toStr }
 Str? y() { echo(3)?.toStr }
 Str? z() { echo(3)->toStr }
}