#! /bin/sh
set -e

WORK_PATH=$(cd "$(dirname "$0")"; pwd)
mkdir -p $WORK_PATH/../env/lib/fan

echo 'build fanx java'
sh build_javaEmit.sh

echo 'build sys and std'
sh bootstrap_build.sh ../library/sys
sh bootstrap_build.sh ../library/std

echo 'build compiler self'
sh bootstrap_build.sh compiler
sh bootstrap_build.sh compilerx
sh bootstrap_build.sh build
sh bootstrap_build.sh compilerJava
sh bootstrap_build.sh compilerJs
sh bootstrap_build.sh compilerxJs

export FAN_ENV_PATH=""
fanc='../env/bin/fanb'
echo 'build compiler test'
$fanc testCompiler/pod.props
$fanc testNative/pod.props
$fanc testJava/pod.props
