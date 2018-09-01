#! /bin/sh
set -e

##
## configure:
## env/etc/compiler/config.props
##   devHome=...
##

WORK_PATH=$(cd "$(dirname "$0")"; pwd)
echo "work path $WORK_PATH"
mkdir -p $WORK_PATH/../devEnv/lib/fan

#export FAN_ENV_PATH=$WORK_PATH/../devEnv/
export FAN_ENV_PATH=""

fanc='../env/bin/fanb'

echo 'build fanx java'
sh build_jar.sh

echo 'build sys and std'
$fanc sys/pod.props
$fanc std/pod.props

echo 'build compiler self'
$fanc compiler/pod.props
$fanc build/pod.props

#change current runtime env
export FAN_ENV_PATH=$WORK_PATH/../devEnv/

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


