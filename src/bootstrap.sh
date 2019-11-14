#! /bin/sh
set -e

WORK_PATH=$(cd "$(dirname "$0")"; pwd)

export FAN_ENV_PATH=""
export FAN_DEV_HOME=$WORK_PATH/../env/
fanc='../release/fanx-2.5.0/bin/fanb'

echo "bootstrap build from $fanc to $FAN_DEV_HOME"
mkdir -p $WORK_PATH/../env/lib/fan


echo 'build fanx java'
sh build_jar.sh

echo 'build sys and std'
$fanc sys/pod.props
$fanc std/pod.props

echo 'build compiler self'
$fanc compiler/pod.props
$fanc build/pod.props
$fanc compilerJava/pod.props
$fanc compilerJs/pod.props
