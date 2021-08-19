#! /bin/sh
set -e

WORK_PATH=$(cd "$(dirname "$0")"; pwd)

export FANX_ENV_PATH=""
export FAN_ENV_PATH=""
export FANX_DEV_HOME=$WORK_PATH/../env/
export FAN_DEV_HOME=$FANX_DEV_HOME

fanc='../release/fanx-3.4.2/bin/fanb'

POD_DIR=$1

$fanc $POD_DIR/pod.props
