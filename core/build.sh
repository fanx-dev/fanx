set -e
fan compiler/build.fan

fanc='../../../fantom/fan/bin/fan compiler::Main'

$fanc sys/pod.props
$fanc std/pod.props
$fanc reflect/pod.props
$fanc testlib/pod.props

#../../../fantom/fan/bin/fanp -c sys::List
