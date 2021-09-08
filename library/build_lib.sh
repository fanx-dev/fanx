#! /bin/sh
set -e

# echo 'build sys and std'
# cd ../compiler
# sh bootstrap_build.sh ../library/sys
# sh bootstrap_build.sh ../library/std
# cd -

#-------------build
export FAN_ENV_PATH=""
fanc='../env/bin/fanb'

echo 'build sys test'
#$fanc baseTest/pod.props
$fanc testSys/pod.props

echo 'build other libs'
$fanc concurrent/pod.props
$fanc util/pod.props


