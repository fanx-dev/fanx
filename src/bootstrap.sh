#! /bin/sh
set -e

WORK_PATH=$(cd "$(dirname "$0")"; pwd)

export FANX_ENV_PATH=""
export FAN_ENV_PATH=""
export FANX_DEV_HOME=$WORK_PATH/../env/
export FAN_DEV_HOME=$FANX_DEV_HOME
 
fanc='../release/fanx-3.4/bin/fanb'

echo "bootstrap build from $fanc to $FANX_DEV_HOME"
mkdir -p $WORK_PATH/../env/lib/fan


echo 'build fanx java'
sh build_java.sh

echo 'build sys and std'
$fanc sys/pod.props
$fanc std/pod.props

echo 'build compiler self'
$fanc compiler/pod.props
$fanc build/pod.props
$fanc compilerJava/pod.props
$fanc compilerJs/pod.props
