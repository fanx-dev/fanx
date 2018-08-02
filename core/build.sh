set -e

#fan compiler/build.fan
#fanc='../../../fantom/fan/bin/fan compiler::Main'

fanc='../env/bin/fanc'
$fanc compiler/pod.props

$fanc sys/pod.props
$fanc std/pod.props
$fanc baseTest/pod.props
$fanc testSys/pod.props

#../../../fantom/fan/bin/fanp -c sys::List

