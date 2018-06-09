set -e
fan compiler/build.fan

fanc='../../../fantom/fan/bin/fan compiler::Main'

$fanc sys/pod.props
$fanc std/pod.props
$fanc reflect/pod.props
$fanc baseTest/pod.props
$fanc testSys/pod.props

#../../../fantom/fan/bin/fanp -c sys::List