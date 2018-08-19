#! /bin/sh
set -e

fanc='../env/bin/fanb'

echo 'build fanx java'
cd fanx
sh build_jar.sh
cd ../

echo 'build compiler self'
$fanc compiler/pod.props
cp ../env/lib/compiler.pod ../env/lib/fan/
$fanc build/pod.props

echo 'build sys and std'
$fanc sys/pod.props
$fanc std/pod.props

echo 'build sys test'
$fanc baseTest/pod.props
$fanc testSys/pod.props

echo 'build compiler plugin'
$fanc compilerJs/pod.props
$fanc compilerJava/pod.props

echo 'build compiler test'
$fanc testCompiler/pod.props
$fanc testNative/pod.props
$fanc testJava/pod.props

echo 'build other libs'
$fanc concurrent/pod.props
$fanc util/pod.props


