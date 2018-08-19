#! /bin/sh
set -e

jstub='../env/bin/jstub -d ../env/lib/java/stub'

$jstub sys
$jstub std
$jstub concurrent
$jstub baseTest

#javap -c -s -v -constants -l -p -sysinfo -cp ../env/lib/java/stub/basetTest.jar fan.baseTest.Main