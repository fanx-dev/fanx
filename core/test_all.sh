#! /bin/sh
set -e

fant='../env/bin/fant'

$fant testSys
$fant testCompiler
$fant testNative
$fant testJava

