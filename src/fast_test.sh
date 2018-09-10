#! /bin/sh
set -e

fanc='../env/bin/fanb'
$fanc compiler/pod.props

../env/bin/fan compiler::Main baseTest/pod.props 
#$fanc baseTest/pod.props

#../env/bin/fan baseTest
#../env/bin/fanp -c baseTest

