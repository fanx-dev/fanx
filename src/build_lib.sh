#! /bin/sh
set -e


#-------------build
export FAN_ENV_PATH=""
fanc='../env/bin/fanb'

echo 'build sys test'
#$fanc baseTest/pod.props
$fanc testSys/pod.props

echo 'build compiler test'
$fanc testCompiler/pod.props
$fanc testNative/pod.props
$fanc testJava/pod.props

echo 'build other libs'
$fanc concurrent/pod.props
$fanc util/pod.props


