#! /bin/sh
set -e

WORK_PATH=$(cd "$(dirname "$0")"; pwd)

export FANX_ENV_PATH=""
export FAN_ENV_PATH=""
export FANX_DEV_HOME=$WORK_PATH/../env/
export FAN_DEV_HOME=$FANX_DEV_HOME

fanc='../release/fanx-3.4.1/bin/fanb'

echo "bootstrap build from $fanc to $FANX_DEV_HOME"
mkdir -p $WORK_PATH/../env/lib/fan

POD_DIR=$1

$fanc $POD_DIR/pod.props
