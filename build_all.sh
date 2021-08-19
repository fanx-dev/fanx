#! /bin/sh
set -e

cd compiler
sh bootstrap_all.sh
cd ../

cd library
sh build_lib.sh
cd ../

sh run_test.sh
