
fan compiler/build.fan

NEW_FAN=../../../fantom/fan/bin/fan

$NEW_FAN compiler::Main sys/build.props
$NEW_FAN compiler::Main std/build.props
$NEW_FAN compiler::Main reflect/build.props
$NEW_FAN compiler::Main testlib/build.props
