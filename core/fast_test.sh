#! /bin/sh
set -e

fanc='../env/bin/fanb'
$fanc compiler/pod.props
cp ../env/lib/compiler.pod ../env/lib/fan/
$fanc baseTest/pod.props

../env/bin/fan baseTest

#../env/bin/fanp -c baseTest::Main

